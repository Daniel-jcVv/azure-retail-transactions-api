# Azure CLI Commands Explained - Retail Analytics Pipeline

This document explains every Azure CLI command used to set up the infrastructure for the Retail Analytics Pipeline project.

---

## 📋 Table of Contents

1. [Prerequisites & Login](#prerequisites--login)
2. [Environment Variables](#environment-variables)
3. [Resource Group Creation](#resource-group-creation)
4. [Storage Account Setup](#storage-account-setup)
5. [Synapse Workspace Creation](#synapse-workspace-creation)
6. [Firewall Configuration](#firewall-configuration)
7. [Container Creation](#container-creation)
8. [Spark Pool Setup](#spark-pool-setup)

---

## 1. Prerequisites & Login

### Command: `az login`

```bash
az login
```

**What it does:**
- Opens your default web browser
- Authenticates you with Microsoft/Azure
- Retrieves your subscription information
- Sets up credentials for subsequent commands

**When to use:**
- First time using Azure CLI
- When your session expires
- When switching Azure accounts

**Output:**
- List of available subscriptions
- Default subscription marked with `*`
- Tenant and subscription IDs

---

## 2. Environment Variables

### Commands: `export` statements

```bash
export RESOURCE_GROUP="rg-retail-analytics"
export LOCATION="centralus"
export STORAGE_ACCOUNT="stgretail$(date +%s)"
export SYNAPSE_WORKSPACE="synapseretail$(date +%s)"
```

**What each variable means:**

| Variable | Purpose | Example Value |
|----------|---------|---------------|
| `RESOURCE_GROUP` | Name for the Azure Resource Group (container for all resources) | `rg-retail-analytics` |
| `LOCATION` | Azure region where resources will be created | `centralus` |
| `STORAGE_ACCOUNT` | Unique name for the storage account | `stgretail1731893456` |
| `SYNAPSE_WORKSPACE` | Unique name for Synapse workspace | `synapseretail1731893456` |

**Why use variables:**
- ✅ Reusability: Use the same name across multiple commands
- ✅ Consistency: Avoid typos
- ✅ Automation: Easy to script

**Special syntax: `$(date +%s)`**
- Generates a Unix timestamp (seconds since 1970)
- Ensures globally unique names
- Example: `1731893456`

---

## 3. Resource Group Creation

### Command: `az group create`

```bash
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION
```

**What it does:**
- Creates a **Resource Group** (logical container for Azure resources)
- All project resources will be placed inside this group

**Parameters explained:**

| Parameter | Value | Explanation |
|-----------|-------|-------------|
| `--name` | `rg-retail-analytics` | Name of the resource group |
| `--location` | `centralus` | Azure region (data center location) |

**Why Resource Groups:**
- 🗂️ **Organization:** Groups related resources together
- 💰 **Cost tracking:** See costs per project
- 🗑️ **Easy deletion:** Delete entire group = delete all resources inside
- 🔐 **Access control:** Set permissions at group level

**Output:**
```json
{
  "id": "/subscriptions/.../resourceGroups/rg-retail-analytics",
  "location": "centralus",
  "name": "rg-retail-analytics",
  "properties": {
    "provisioningState": "Succeeded"
  }
}
```

---

## 4. Storage Account Setup

### Command: `az storage account create`

```bash
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS \
  --kind StorageV2 \
  --hierarchical-namespace true
```

**What it does:**
- Creates an **Azure Storage Account**
- Enables **Data Lake Storage Gen2** (ADLS)
- This is where your data files will be stored (Bronze, Silver, Gold layers)

**Parameters explained:**

| Parameter | Value | Explanation |
|-----------|-------|-------------|
| `--name` | `stgretail1731893456` | Globally unique storage account name (3-24 chars, lowercase, numbers only) |
| `--resource-group` | `rg-retail-analytics` | Which resource group to place it in |
| `--location` | `centralus` | Physical data center location |
| `--sku` | `Standard_LRS` | **Locally Redundant Storage** (cheapest option, 3 copies in same datacenter) |
| `--kind` | `StorageV2` | General-purpose v2 (latest, recommended) |
| `--hierarchical-namespace` | `true` | **KEY:** Enables Data Lake Gen2 features (folder hierarchy like a file system) |

**SKU Options (Storage Redundancy):**

| SKU | Full Name | Copies | Cost | Use Case |
|-----|-----------|--------|------|----------|
| `Standard_LRS` | Locally Redundant | 3 copies in 1 datacenter | $ | Development, non-critical |
| `Standard_GRS` | Geo-Redundant | 6 copies across 2 regions | $$ | Production |
| `Standard_RAGRS` | Read-Access Geo-Redundant | 6 copies + read access | $$$ | High availability |

**Why `--hierarchical-namespace true` is critical:**
- ✅ Enables folder/directory structure (like Unix file system)
- ✅ Required for Azure Data Lake Gen2
- ✅ Better performance for big data workloads
- ✅ Atomic operations on directories
- ❌ Without it, only flat blob storage (no real folders)


---

## 5. Synapse Workspace Creation

### Command: `az synapse workspace create`

```bash
az synapse workspace create \
  --name $SYNAPSE_WORKSPACE \
  --resource-group $RESOURCE_GROUP \
  --storage-account $STORAGE_ACCOUNT \
  --file-system retail \
  --sql-admin-login-user sqladminuser \
  --sql-admin-login-password "RetailProject2025!" \
  --location $LOCATION
```

**What it does:**
- Creates an **Azure Synapse Analytics Workspace**
- This is your integrated analytics platform (PySpark, SQL, Data Pipelines)
- Automatically creates a **Serverless SQL Pool**

**Parameters explained:**

| Parameter | Value | Explanation |
|-----------|-------|-------------|
| `--name` | `synapseretail1731893456` | Globally unique workspace name |
| `--resource-group` | `rg-retail-analytics` | Which resource group to place it in |
| `--storage-account` | `stgretail1731893456` | Primary storage account for Synapse |
| `--file-system` | `retail` | Container name in storage account (auto-created if doesn't exist) |
| `--sql-admin-login-user` | `sqladminuser` | Admin username for Synapse SQL |
| `--sql-admin-login-password` | `RetailProject2025!` | Admin password (must be complex) |
| `--location` | `centralus` | Region for the workspace |



**What gets created automatically:**
- 🔹 Synapse Workspace
- 🔹 Serverless SQL Pool (built-in, no extra cost)
- 🔹 Managed Resource Group
- 🔹 Container `retail` in the storage account
- 🔹 System-assigned managed identity

**Time to create:** ~5-7 minutes (longest step)

**Why this takes time:**
- Provisioning compute resources
- Setting up managed identity
- Configuring networking
- Creating SQL endpoints

---

## 6. Firewall Configuration

### Command: `az synapse workspace firewall-rule create`

```bash
az synapse workspace firewall-rule create \
  --name AllowAll \
  --workspace-name $SYNAPSE_WORKSPACE \
  --resource-group $RESOURCE_GROUP \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 255.255.255.255
```

**What it does:**
- Creates a **firewall rule** to allow connections to Synapse
- Allows access from any IP address

**Parameters explained:**

| Parameter | Value | Explanation |
|-----------|-------|-------------|
| `--name` | `AllowAll` | Name of the firewall rule |
| `--workspace-name` | `synapseretail1731893456` | Which Synapse workspace |
| `--resource-group` | `rg-retail-analytics` | Which resource group |
| `--start-ip-address` | `0.0.0.0` | Starting IP address of range |
| `--end-ip-address` | `255.255.255.255` | Ending IP address of range |

**IP Range Meanings:**

| Range | Meaning | Security Level |
|-------|---------|----------------|
| `0.0.0.0` to `0.0.0.0` | Allow Azure services only | ⭐⭐⭐⭐ Secure |
| `Your.IP` to `Your.IP` | Allow only your IP | ⭐⭐⭐⭐⭐ Most secure |
| `0.0.0.0` to `255.255.255.255` | Allow all IPs | ⭐ Least secure (OK for learning) |

**⚠️ Security Note:**
- This configuration allows **ANY** IP to connect (for development/learning)
- For production, use specific IP ranges or Azure services only

**Better alternatives for production:**

```bash
# Option 1: Allow only Azure services
--start-ip-address 0.0.0.0 \
--end-ip-address 0.0.0.0

# Option 2: Allow only your IP
MY_IP=$(curl -s ifconfig.me)
--start-ip-address $MY_IP \
--end-ip-address $MY_IP
```

---

## 7. Container Creation

### Command: `az storage container create`

```bash
STORAGE_KEY=$(az storage account keys list \
  --resource-group $RESOURCE_GROUP \
  --account-name $STORAGE_ACCOUNT \
  --query '[0].value' -o tsv)

az storage container create --name bronze --account-name $STORAGE_ACCOUNT --account-key $STORAGE_KEY
az storage container create --name silver --account-name $STORAGE_ACCOUNT --account-key $STORAGE_KEY
az storage container create --name gold --account-name $STORAGE_ACCOUNT --account-key $STORAGE_KEY
```

**What it does:**
- First: Retrieves the storage account access key
- Then: Creates three containers for Medallion Architecture

### Step 1: Get Storage Key

```bash
STORAGE_KEY=$(az storage account keys list \
  --resource-group $RESOURCE_GROUP \
  --account-name $STORAGE_ACCOUNT \
  --query '[0].value' -o tsv)
```

**Breaking it down:**

| Part | Explanation |
|------|-------------|
| `az storage account keys list` | Lists all access keys for the storage account |
| `--resource-group` | Specifies which resource group |
| `--account-name` | Specifies which storage account |
| `--query '[0].value'` | Uses JMESPath to extract first key's value |
| `-o tsv` | Output format: Tab-Separated Values (plain text, no JSON) |
| `$(...)` | Command substitution: stores output in variable |
| `STORAGE_KEY=` | Stores the key in environment variable |

**Why we need the key:**
- Authentication to perform operations on storage account
- Alternative: Use `--auth-mode login` (uses your Azure identity)

### Step 2: Create Containers

```bash
az storage container create \
  --name bronze \
  --account-name $STORAGE_ACCOUNT \
  --account-key $STORAGE_KEY
```

**Parameters explained:**

| Parameter | Value | Explanation |
|-----------|-------|-------------|
| `--name` | `bronze` / `silver` / `gold` | Container name (like S3 bucket) |
| `--account-name` | `stgretail1731893456` | Storage account where container lives |
| `--account-key` | `<key>` | Authentication key |

**Medallion Architecture Containers:**

| Container | Purpose | Data Quality |
|-----------|---------|--------------|
|  **bronze** | Raw data from API (no transformations) | Low (as-is) |
|  **silver** | Cleaned, filtered data (purchases only) | Medium (validated) |
|  **gold** | Aggregated business metrics (daily reports) | High (ready for consumption) |

**Container vs Blob vs File System:**
- **Container** = Top-level folder in storage account
- **Blob** = File inside a container
- **File System** = With ADLS Gen2, containers support hierarchical folders

---

## 8. Spark Pool Setup

### Command: `az synapse spark pool create`

```bash
az synapse spark pool create \
  --name sparkpool \
  --workspace-name $SYNAPSE_WORKSPACE \
  --resource-group $RESOURCE_GROUP \
  --spark-version 3.3 \
  --node-count 3 \
  --node-size Small \
  --enable-auto-pause true \
  --delay 15
```

**What it does:**
- Creates an **Apache Spark Pool** for running PySpark code
- Configures cluster size and auto-scaling

**Parameters explained:**

| Parameter | Value | Explanation |
|-----------|-------|-------------|
| `--name` | `sparkpool` | Name of the Spark pool |
| `--workspace-name` | `synapseretail1731893456` | Which Synapse workspace |
| `--resource-group` | `rg-retail-analytics` | Which resource group |
| `--spark-version` | `3.3` | Apache Spark version |
| `--node-count` | `3` | Number of worker nodes (minimum is 3) |
| `--node-size` | `Small` | VM size per node |
| `--enable-auto-pause` | `true` | Automatically pause when idle (saves money) |
| `--delay` | `15` | Minutes of inactivity before auto-pause |

**Node Size Options:**

| Size | vCores | Memory | Cost/hour | Use Case |
|------|--------|--------|-----------|----------|
| **Small** | 4 | 32 GB | $ | Development, learning, small datasets |
| **Medium** | 8 | 64 GB | $$ | Testing, medium workloads |
| **Large** | 16 | 128 GB | $$$ | Production, large datasets |
| **XLarge** | 32 | 256 GB | $$$$ | Big data, heavy processing |

**Why 3 nodes minimum:**
- 1 **Driver node**: Coordinates the work
- 2+ **Worker nodes**: Execute parallel tasks
- Spark requires at least 1 driver + 2 workers

**Auto-pause explained:**
-  Saves money: Pauses when not in use
-  Automatic: No manual intervention needed
-  Fast resume: Starts in ~2-3 minutes when needed
-  Cost: Only pay when running (not when paused)

**Example cost calculation (Small nodes):**
- Cost: ~$0.50/hour when running
- With auto-pause (15 min idle): ~$20-40/month for development
- Without auto-pause: ~$360/month (24/7 running)

**Time to create:** ~3-5 minutes

---

## 📊 Complete Command Flow Summary

```
1. az login                          → Authenticate
2. export variables                  → Set configuration
3. az group create                   → Create Resource Group (container)
4. az storage account create         → Create Storage + ADLS Gen2
5. az synapse workspace create       → Create Synapse (longest step)
6. az synapse firewall-rule create   → Allow access
7. az storage account keys list      → Get storage key
8. az storage container create (x3)  → Create bronze/silver/gold
9. az synapse spark pool create      → Create Spark cluster
```

**Total time:** ~8-10 minutes
**Total cost:** ~$30-50/month (with auto-pause enabled)

---

## Verification Commands

After setup, verify everything was created:

```bash
# List all resources in the resource group
az resource list \
  --resource-group $RESOURCE_GROUP \
  --output table

# Check Synapse workspace status
az synapse workspace show \
  --name $SYNAPSE_WORKSPACE \
  --resource-group $RESOURCE_GROUP

# List storage containers
az storage container list \
  --account-name $STORAGE_ACCOUNT \
  --account-key $STORAGE_KEY \
  --output table

# Check Spark pool
az synapse spark pool show \
  --name sparkpool \
  --workspace-name $SYNAPSE_WORKSPACE \
  --resource-group $RESOURCE_GROUP
```

---

## Cleanup Commands

When you're done with the project:

```bash
# Delete everything (WARNING: Cannot be undone!)
az group delete \
  --name $RESOURCE_GROUP \
  --yes \
  --no-wait

# Check deletion status
az group exists --name $RESOURCE_GROUP
# Output: false (when deleted)
```

---

##  Pro Tips

### 1. Save Configuration

Create a file to remember your resource names:

```bash
cat > .env << EOF
RESOURCE_GROUP="$RESOURCE_GROUP"
STORAGE_ACCOUNT="$STORAGE_ACCOUNT"
SYNAPSE_WORKSPACE="$SYNAPSE_WORKSPACE"
LOCATION="$LOCATION"
SQL_ADMIN_USER="sqladminuser"
SQL_ADMIN_PASSWORD="Password123!"
EOF
```

### 2. Cost Management

```bash
# Set budget alert
az consumption budget create \
  --amount 50 \
  --budget-name "retail-analytics-budget" \
  --category Cost \
  --time-grain Monthly

# Check current costs
az consumption usage list \
  --start-date 2024-11-01 \
  --end-date 2024-11-30
```

### 3. Pause Spark Pool Manually

```bash
# Pause to save money
az synapse spark pool update \
  --name sparkpool \
  --workspace-name $SYNAPSE_WORKSPACE \
  --resource-group $RESOURCE_GROUP \
  --enable-auto-pause true
```

---

## Additional Resources

- [Azure CLI Documentation](https://docs.microsoft.com/cli/azure/)
- [Azure Synapse Documentation](https://docs.microsoft.com/azure/synapse-analytics/)
- [ADLS Gen2 Documentation](https://docs.microsoft.com/azure/storage/blobs/data-lake-storage-introduction)
- [Spark Pool Pricing](https://azure.microsoft.com/pricing/details/synapse-analytics/)

---

**Last Updated:** November 2025
**Project:** Azure Retail Data Analytics Pipeline
