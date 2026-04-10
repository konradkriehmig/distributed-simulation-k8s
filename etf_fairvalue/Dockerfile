# ── Stage 1: build ──────────────────────────────────────────────────────────
FROM python:3.12-slim AS builder

# Build tools needed for numpy / scipy C extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
        gcc \
        g++ \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Copy dependency list first (better layer caching)
COPY requirements-etf.txt .
RUN pip install --no-cache-dir --upgrade pip \
 && pip install --no-cache-dir -r requirements-etf.txt

# ── Stage 2: runtime ─────────────────────────────────────────────────────────
FROM python:3.12-slim

WORKDIR /app

# Copy installed packages from the builder stage
COPY --from=builder /usr/local/lib/python3.12 /usr/local/lib/python3.12
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy the etf_fairvalue package
COPY etf_fairvalue/ /app/etf_fairvalue/

# Non-root user for security
RUN useradd --create-home --shell /bin/bash worker
USER worker

# Default entrypoint — CLI args (--batch-id, --seed, etc.) are passed at runtime
ENTRYPOINT ["python", "-m", "etf_fairvalue.worker"]
