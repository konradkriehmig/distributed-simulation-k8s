FROM python:3.11-slim
WORKDIR /app
COPY requirements-etf.txt .
RUN pip install --no-cache-dir -r requirements-etf.txt
COPY etf_fairvalue/ etf_fairvalue/
ENTRYPOINT ["python", "-m", "etf_fairvalue.worker"]