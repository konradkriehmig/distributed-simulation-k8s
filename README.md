Aim of this project is to **improve the runtime of multiple parallel backtests** that take my laptop too long to run.

This project is about creating a high-performance infrastructure for large backtests, it is not about finding a great trading strategy. For this project, I am using simple ma crossover backtest on crypto data. I use crypto as a data source because it is freely available. The data can be replaced with other trading data anytime.

Running multiple backtests on my laptop:
15 mins

Running multiple backtests on my Azure infra across 2 VMs in a VM scale set (observe queue storage):
>30 mins --> more/more performant workers needed.

During the project I discovered that I was able to speed up the whole code with 1) vectorization and 2) parallelism (my Microsoft surface has 12 cores).

<img width="519" height="663.5" alt="image" src="https://github.com/user-attachments/assets/c69a2e32-5c29-45cb-a07d-1e817d816908" />

Architecture:

<img width="1818" height="700" alt="image" src="https://github.com/user-attachments/assets/747d9da8-4098-4333-ad98-9fb4647859dc" />

How to deploy this project:
1. Clone repo
2. Configure secrets in settings:
    AZURE_CREDENTIALS
    AZURE_SUBSCRIPTION_ID
    POSTGRES_NAME
    POSTGRES_PASSWORD
    SSH_PUBLIC_KEY
    STORAGE_ACCOUNT_NAME (only lowercase letter)
    VM_NAME
4. Deploy
5. Enable allow public access in storage account (environment config might be set to disabled by default)
6. Give yourself storage blob data contributor permissions
7. Upload raw data from this repo in storage account in raw data folder
8. Github actions: push jobs to queue
9. Give yourself permissions (storage queue data reader) to check whether jobs landed in queue storage


## Skills Demonstrated
- Infrastructure as Code (ARM templates)
- CI/CD with GitHub Actions
- Azure networking (VNet, NAT Gateway [for downloading pythobn packages from the internet without a public IP], subnets)
- Managed Identity / RBAC (no secrets in code)
- VMSS auto-scaling patterns
- Queue-based job distribution to VMSS

