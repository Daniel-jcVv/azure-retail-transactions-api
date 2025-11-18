# Azure Retail Analytics Pipeline - Project Checklist

Track your progress through the project implementation.

---

## 📋 Pre-requisites

- [x] Azure account created
- [x] Azure CLI installed
- [x] Azure CLI login completed
- [x] GitHub account available
- [ ] Basic PySpark knowledge
- [ ] Basic SQL knowledge

---

## 🎯 Phase 1: Planning & Setup

### Documentation
- [x] README.md created
- [x] IMPLEMENTATION_GUIDE.md created
- [x] LICENSE file added
- [x] .gitignore configured
- [x] .env template created
- [x] Azure CLI commands documented

### Repository Structure
- [x] Project directories created
- [x] Scripts folder with update-env.sh
- [x] Docs folder with guides
- [x] Data-source folder with JSON

---

## ☁️ Phase 2: Azure Infrastructure

### Resource Group
- [ ] Resource Group created in Central US
- [ ] Resource Group visible in Azure Portal

### Storage Account (ADLS Gen2)
- [ ] Storage Account created
- [ ] Hierarchical namespace enabled
- [ ] Containers created:
  - [ ] bronze
  - [ ] silver
  - [ ] gold

### Synapse Workspace
- [ ] Synapse Workspace created
- [ ] SQL Admin credentials saved
- [ ] Firewall rules configured
- [ ] Synapse Studio accessible

### Spark Pool
- [ ] Spark Pool created
- [ ] Auto-pause enabled (15 min)
- [ ] Small node size configured
- [ ] 3 nodes minimum set

### Verification
- [ ] All resources visible in Portal
- [ ] .env file updated with resource names
- [ ] Resource Group contains all expected resources

**Command to verify:**
```bash
az resource list --resource-group rg-retail-analytics --output table
```

---

## 📊 Phase 3: Data Source Setup

### GitHub Repository
- [ ] Create repository: `retail-transactions-api`
- [ ] Upload `retail_transactions_bronze.json`
- [ ] Repository set to public
- [ ] Get raw URL for JSON file
- [ ] Test URL in browser (should download JSON)

### Update Configuration
- [ ] Update .env with GitHub username
- [ ] Update .env with repository name
- [ ] Update .env with raw URL
- [ ] Verify URL is accessible

**Example URL format:**
```
https://raw.githubusercontent.com/YOUR_USERNAME/retail-transactions-api/main/retail_transactions_bronze.json
```

---

## 🥉 Phase 4: Bronze Layer (Data Ingestion)

### Synapse Studio Access
- [ ] Open Synapse Studio (https://web.azuresynapse.net)
- [ ] Select your workspace
- [ ] Navigate to Integrate section

### Create Pipeline
- [ ] Click Integrate → + → Pipeline
- [ ] Name: `Ingest_Bronze_Layer`
- [ ] Drag "Copy data" activity to canvas

### Configure Source
- [ ] Create HTTP dataset
- [ ] Create linked service for GitHub
- [ ] Set base URL: `https://raw.githubusercontent.com`
- [ ] Set relative URL with your path
- [ ] Test connection ✅
- [ ] Preview data ✅

### Configure Sink
- [ ] Create ADLS Gen2 dataset
- [ ] Create linked service for storage
- [ ] Select Parquet format
- [ ] Set path: bronze/transactions
- [ ] Test connection ✅

### Pipeline Execution
- [ ] Fix amount data type to Double
- [ ] Click Debug
- [ ] Pipeline runs successfully ✅
- [ ] Verify data in bronze container

---

## 🥈 Phase 5: Silver Layer (Data Transformation)

### Create Notebook
- [ ] Click Develop → + → Notebook
- [ ] Name: `Transform_Bronze_to_Silver`
- [ ] Attach to Spark Pool

### Develop Transformation
- [ ] Read Bronze parquet files
- [ ] Filter: Only purchase transactions
- [ ] Drop null values (customer_id, amount)
- [ ] Convert event_timestamp to date
- [ ] Lowercase payment_method
- [ ] Cast amount to float
- [ ] Select relevant columns

### Test & Execute
- [ ] Update storage account name in code
- [ ] Run notebook
- [ ] Spark session starts successfully
- [ ] Data loads from Bronze
- [ ] Transformations apply correctly
- [ ] Data written to Silver container
- [ ] Verify data in silver container

**Verification:**
- [ ] Silver container has parquet files
- [ ] Only purchase events in Silver
- [ ] No null values in key columns

---

## 🥇 Phase 6: Gold Layer (Aggregation)

### Create Aggregation Notebook
- [ ] Click Develop → + → Notebook
- [ ] Name: `Aggregate_Silver_to_Gold`
- [ ] Attach to Spark Pool

### Develop Aggregation
- [ ] Read Silver parquet files
- [ ] Group by event_date
- [ ] Calculate sum(amount) as daily_revenue
- [ ] Calculate count(*) as total_purchases
- [ ] Order by event_date

### Test & Execute
- [ ] Update storage account name in code
- [ ] Run notebook
- [ ] Data loads from Silver
- [ ] Aggregations calculated correctly
- [ ] Results displayed
- [ ] Data written to Gold container
- [ ] Verify data in gold container

**Verification:**
- [ ] Gold container has parquet files
- [ ] Daily aggregations present
- [ ] Revenue and purchase counts correct

---

## 📊 Phase 7: SQL Tables & Querying

### Create Database
- [ ] Click Develop → + → SQL script
- [ ] Connect to: Built-in (Serverless SQL)
- [ ] Execute: `CREATE DATABASE retail_analytics`
- [ ] Verify database created

### Create External Tables
- [ ] Update storage account name in SQL
- [ ] Create external data source
- [ ] Create external file format (Parquet)
- [ ] Create external table: daily_revenue
- [ ] Query table successfully

### Test Queries
- [ ] `SELECT * FROM daily_revenue`
- [ ] Results displayed correctly
- [ ] Date range looks correct
- [ ] Revenue values reasonable

**Example Query:**
```sql
SELECT
    event_date,
    daily_revenue,
    total_purchases,
    ROUND(daily_revenue / total_purchases, 2) as avg_transaction
FROM daily_revenue
ORDER BY event_date DESC;
```

---

## 🔄 Phase 8: Testing & Validation

### End-to-End Test
- [ ] Trigger Bronze pipeline manually
- [ ] Run Silver notebook
- [ ] Run Gold notebook
- [ ] Query SQL table
- [ ] Verify all data flows correctly

### Data Quality Checks
- [ ] Bronze has raw data (all event types)
- [ ] Silver has only purchases (filtered)
- [ ] Silver has no null values in key columns
- [ ] Gold has correct daily aggregations
- [ ] SQL queries return expected results

### Performance Check
- [ ] Pipeline completes in reasonable time
- [ ] Spark notebooks execute successfully
- [ ] No memory issues
- [ ] Auto-pause working correctly

---

## 📸 Phase 9: Documentation & Screenshots

### Screenshots to Take
- [ ] Azure Portal: Resource Group overview
- [ ] Synapse Studio: Pipeline view
- [ ] Synapse Studio: Pipeline running
- [ ] ADLS: Bronze container with data
- [ ] ADLS: Silver container with data
- [ ] ADLS: Gold container with data
- [ ] Synapse Notebook: Silver transformation running
- [ ] Synapse Notebook: Gold aggregation results
- [ ] SQL Query: Results from daily_revenue table
- [ ] Spark Pool: Configuration settings

### Create Architecture Diagram
- [ ] Draw.io or Lucidchart diagram
- [ ] Show: API → ADF → Bronze → Silver → Gold → SQL
- [ ] Include Azure services icons
- [ ] Add to docs folder
- [ ] Reference in README

### Update Documentation
- [ ] Update README with actual resource names
- [ ] Add screenshots to docs folder
- [ ] Update IMPLEMENTATION_GUIDE with learnings
- [ ] Add troubleshooting section if needed

---

## 🎓 Phase 10: Portfolio Preparation

### GitHub Repository
- [ ] All code committed
- [ ] No credentials in repository
- [ ] README is professional
- [ ] Screenshots included
- [ ] Architecture diagram added
- [ ] License file present

### LinkedIn Post Draft
- [ ] Write post about project
- [ ] Include key technologies
- [ ] Mention business value
- [ ] Add GitHub link
- [ ] Add relevant hashtags
- [ ] Review and edit

### Resume/CV Update
- [ ] Add project to experience/projects
- [ ] Highlight key technologies
- [ ] Quantify achievements
- [ ] Include GitHub link

**Example Resume Bullet:**
```
Azure Retail Analytics Pipeline | Data Engineering Project
• Designed end-to-end data pipeline processing 10K+ retail transactions
• Implemented Medallion Architecture (Bronze-Silver-Gold) on Azure Synapse
• Reduced reporting time from 4 hours to 30 minutes through automation
• Technologies: Azure Synapse, PySpark, ADLS Gen2, SQL, Azure Data Factory
```

---

## 💰 Phase 11: Cost Management

### Set Budget Alert
- [ ] Azure Portal → Cost Management
- [ ] Create budget: $50/month
- [ ] Set alert at 80% ($40)
- [ ] Add email notification

### Monitor Costs
- [ ] Check daily costs
- [ ] Verify Spark pool auto-pause working
- [ ] No unexpected charges

### Cleanup (When Done)
- [ ] Pause Spark Pool manually
- [ ] Stop any running queries
- [ ] Consider deleting Resource Group
- [ ] Save .env file for future reference

---

## 🎯 Final Checklist

### Project Completion
- [ ] All phases completed
- [ ] End-to-end pipeline working
- [ ] Documentation complete
- [ ] Screenshots captured
- [ ] GitHub repository ready
- [ ] LinkedIn post published
- [ ] Resume updated

### Interview Preparation
- [ ] Can explain Medallion Architecture
- [ ] Can explain each Azure service used
- [ ] Can discuss trade-offs made
- [ ] Can explain cost optimizations
- [ ] Can describe business value
- [ ] Prepared to demo live

### Knowledge Check
- [ ] Understand Bronze vs Silver vs Gold
- [ ] Know why ADLS Gen2 vs Blob Storage
- [ ] Can explain Synapse vs Data Factory
- [ ] Understand Spark Pool configuration
- [ ] Know security best practices
- [ ] Can estimate costs

---

## 📊 Project Metrics

Track these for interviews:

- **Data Volume:** ~10,000 transactions (sample)
- **Processing Time:** <5 minutes end-to-end
- **Cost:** ~$30-50/month (development)
- **Technologies:** 7 (Azure Synapse, ADLS, Spark, SQL, Python, ADF, Git)
- **Layers:** 3 (Bronze, Silver, Gold)
- **Code Files:** 3 notebooks + 1 SQL script
- **Documentation:** 5+ markdown files

---

## 🔗 Quick Links

- [Azure Portal](https://portal.azure.com)
- [Synapse Studio](https://web.azuresynapse.net)
- [GitHub Repo](https://github.com/YOUR_USERNAME/retail-transactions-api)
- [Project Repo](https://github.com/YOUR_USERNAME/az-RetailDataAnalyticsPipeline)

---

**Last Updated:** November 18, 2025
**Status:** Infrastructure setup in progress
**Next:** Complete Azure deployment, then GitHub setup
