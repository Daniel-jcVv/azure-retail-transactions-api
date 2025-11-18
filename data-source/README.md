# Retail Transactions Data Source

This folder contains the sample data file for the Azure Retail Analytics Pipeline project.

## 📄 File

- **retail_transactions_bronze.json** - Sample retail transaction data

## 🎯 Purpose

This JSON file simulates a REST API data source containing retail transactions. It includes:
- Purchase transactions
- Refund transactions
- Cancellation events

## 📊 Data Schema

```json
{
  "event_id": "string",
  "event_type": "string (purchase|refund|cancel)",
  "customer_id": "string",
  "order_id": "string",
  "event_timestamp": "ISO 8601 datetime",
  "payment_method": "string",
  "product_category": "string",
  "product_id": "string",
  "amount": "number (decimal)",
  "location": "string",
  "status": "string"
}
```

## 🚀 Usage for Project

### Step 1: Create GitHub Repository

Create a separate GitHub repository named `retail-transactions-api` (or your preferred name).

### Step 2: Upload File

1. Upload `retail_transactions_bronze.json` to the root of that repository
2. Make the repository public
3. Click on the file → Click "Raw" button
4. Copy the Raw URL

### Step 3: Use in Pipeline

The Raw URL will be used in Azure Data Factory pipeline as the data source:

```
https://raw.githubusercontent.com/YOUR_USERNAME/retail-transactions-api/main/retail_transactions_bronze.json
```

### Step 4: Update .env

Add to your `.env` file:
```bash
GITHUB_USERNAME="your-username"
GITHUB_REPO="retail-transactions-api"
GITHUB_RAW_URL="https://raw.githubusercontent.com/..."
```

## 📝 Notes

- This file is for **demonstration purposes** only
- In a real production scenario, this would be a live API endpoint
- The data contains ~500 sample transactions spanning multiple days
- File size: ~40KB (small enough for GitHub, quick to process)

---

**Last Updated:** November 2025
