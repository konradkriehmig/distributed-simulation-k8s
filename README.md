## ETF Fair Value Monte Carlo Engine

Estimates the **fair value of the XLK ETF** by running correlated Geometric
Brownian Motion (GBM) simulations across all ~70 stocks using a
Cholesky-decomposed covariance matrix.  Designed to run at scale in parallel on a
Kubernetes (AKS) cluster via Indexed Job pattern, where the number of simulated NAVs equals the number of pos times the number of paths on each pod.

### Workflow

1) fetch XLK constituents data locally from yahoo finance api
2) run the jobs on worker containers and receive a parquet as output
3) aggregate NAVs and evaluate with summary stats and plots

### Installation

```bash
pip install -r requirements-etf.txt
```

### Step 1 — Fetch data & build config bundle (run once locally)

```bash
python -m etf_fairvalue.fetch
```

This pulls XLK holdings from yfinance (falls back to `data/xlk_holdings.csv`
if unavailable), downloads 1 year of daily adjusted closes for all
constituents, computes the annualised covariance matrix / drift / volatility
and saves:

- `config/config_bundle.npz` — numpy arrays (weights, prices, μ, σ, Σ)
- `config/config_meta.json`  — metadata (tickers, XLK market price, timestamp)

### Step 2 — Run a local simulation worker (single batch)

```bash
python -m etf_fairvalue.worker \
    --batch-id 0 \
    --num-paths 10000 \
    --horizon-days 5 \
    --seed 42
```

Output: `results/batch_0.parquet` (10,000 simulated NAV values).

### Step 3 — Aggregate results

```bash
python -m etf_fairvalue.aggregate
```

Reads all `results/batch_*.parquet` files and produces:

- `results/summary_stats.json`      — mean, median, std, percentiles, premium/discount
- `results/nav_distribution.png`    — histogram + KDE with mean / market-price lines

### Deploy to Kubernetes (AKS)

1. **Build & push the Docker image**

   ```bash
   docker build -f etf_fairvalue/Dockerfile -t <YOUR_REGISTRY>/etf-mc-worker:latest .
   docker push <YOUR_REGISTRY>/etf-mc-worker:latest
   ```

2. **Copy the config bundle onto the shared PVC** (e.g. via a `kubectl cp` or
   an init container that runs `fetch.py`).

3. **Submit the Indexed Job**

   ```bash
   kubectl apply -f etf_fairvalue/k8s/worker-job.yaml
   ```

   This launches 100 pods (20 in parallel), each processing 10,000 paths.
   Results land in `results/` on the shared PVC.

4. **Aggregate** once all pods complete:

   ```bash
   python -m etf_fairvalue.aggregate
   ```

### Key constants

| Constant | Value |
|---|---|
| `TRADING_DAYS_PER_YEAR` | 252 |
| Default `horizon_days` | 5 trading days |
| Default `num_paths` per worker | 10,000 |
| Default number of workers | 100 |
| Total paths | 1,000,000 |
