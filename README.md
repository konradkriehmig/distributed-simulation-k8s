## ETF Fair Value Monte Carlo Engine

Estimates the **fair value of the XLK ETF** by running correlated Geometric
Brownian Motion (GBM) simulations across all ~70 stocks using a
Cholesky-decomposed covariance matrix.  Designed to run at scale in parallel on a
Kubernetes (AKS) cluster via Indexed Job pattern, where the number of simulated NAVs equals the number of pos times the number of paths on each pod.

### Workflow

1) fetch XLK constituents data locally from yahoo finance api
2) run the jobs on worker containers and receive a parquet as output
3) aggregate NAVs and evaluate with summary stats and plots

Got to the setup guide:

### Key constants

| Constant | Value |
|---|---|
| `TRADING_DAYS_PER_YEAR` | 252 |
| Default `horizon_days` | 5 trading days |
| Default `num_paths` per worker | 10,000 |
| Default number of workers | 100 |
| Total paths | 1,000,000 |
