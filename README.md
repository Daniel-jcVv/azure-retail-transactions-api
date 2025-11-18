# Retail Data Analytics Pipeline - Azure Data Engineering Project

## 🎯 Project Overview

End-to-end data engineering pipeline built on Azure that processes retail transactions to generate daily purchase and revenue reports, implementing the **Medallion Architecture** (Bronze-Silver-Gold).

## 🏗️ Architecture

```
REST API → ADF → ADLS (Bronze) → PySpark (Silver) → Aggregation (Gold) → Synapse SQL → Power BI/Reports
```

### Data Layers (Medallion Architecture)

- **🥉 Bronze (Raw Data)**: Raw data from REST API with no transformations
- **🥈 Silver (Cleaned Data)**: Cleaned, filtered and validated data (purchase transactions only)
- **🥇 Gold (Aggregated Data)**: Aggregated data ready for consumption (daily reports)

## 🛠️ Technology Stack

- **Azure Data Factory (ADF)**: Data orchestration and ingestion
- **Azure Data Lake Storage Gen2 (ADLS)**: Layered data storage
- **Azure Synapse Analytics**: PySpark processing and SQL Analytics
- **PySpark**: Data transformation and cleansing
- **Azure Synapse SQL Pool**: Queries and reporting
- **Python**: Processing scripts
- **Azure Key Vault**: Secrets management (optional)

## 📊 Business Use Case

**Client**: Retail Company
**Requirement**: Automated daily reports showing:
- Total purchases made
- Daily revenue generated
- Transaction trend analysis

## 🚀 Pipeline Components

### 1. Data Ingestion (Bronze Layer)
- Source: REST API with transactions
- Frequency: Daily
- Captured fields:
  - `customer_id`
  - `order_id`
  - `transaction_amount`
  - `transaction_type`
  - `transaction_date`
  - `product_id`

### 2. Transformation (Silver Layer)
- Data cleansing:
  - Null value removal
  - Data type validation
  - Transaction filtering (purchases only)
- Format standardization
- Deduplication

### 3. Aggregation (Gold Layer)
- Calculated metrics:
  - Total purchases per day
  - Total revenue per day
  - Unique transaction count
  - Unique customers per day

## 📁 Project Structure

```
az-RetailDataAnalyticsPipeline/
├── README.md
├── docs/
│   ├── architecture-diagram.png
│   ├── setup-guide.md
│   └── api-documentation.md
├── adf/
│   ├── pipelines/
│   └── datasets/
├── synapse/
│   ├── notebooks/
│   │   ├── bronze-to-silver.ipynb
│   │   └── silver-to-gold.ipynb
│   ├── sql-scripts/
│   │   └── create-gold-tables.sql
│   └── spark-jobs/
├── scripts/
│   ├── setup-infrastructure.sh
│   └── generate-sample-data.py
├── data-samples/
│   └── sample-transactions.json
└── tests/
    └── unit-tests/
```

## 🔧 Pre-requisites

- Active Azure subscription
- Azure CLI installed
- Python 3.8+
- Basic knowledge of:
  - PySpark
  - SQL
  - Azure Portal

## 📦 Installation and Setup

See [docs/setup-guide.md](docs/setup-guide.md) for detailed instructions.

## 🎓 Skills Demonstrated

- ✅ Data Lake architecture design and implementation
- ✅ ETL/ELT pipeline development
- ✅ PySpark for distributed processing
- ✅ Azure Data Factory orchestration
- ✅ Data quality and validation
- ✅ SQL analytics and reporting
- ✅ Medallion Architecture implementation
- ✅ Cloud cost optimization

## 📈 Expected Results

- Automated pipeline running daily
- Reporting time reduced from 4 hours to 30 minutes
- Data available for near-real-time analysis
- Scalability to process millions of transactions

## 🔗 Links

- [LinkedIn Profile](your-linkedin)
- [Portfolio Website](your-website)
- [Architecture Diagram](docs/architecture-diagram.png)

## 📄 License

This project is part of my professional portfolio.

---

**Developed by**: [Your Name]
**Date**: November 2025
**Contact**: [your-email]
