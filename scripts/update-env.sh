#!/bin/bash

# Script to automatically update .env file with created resource names
# Run this after creating Azure resources

echo "Detecting created Azure resources..."

# Check if logged in
if ! az account show &> /dev/null; then
    echo "Not logged in to Azure CLI. Run 'az login' first."
    exit 1
fi

# Get resource group
RESOURCE_GROUP="rg-retail-analytics"

# Check if resource group exists
if ! az group show --name $RESOURCE_GROUP &> /dev/null; then
    echo "Resource group '$RESOURCE_GROUP' not found."
    echo "   Make sure you've created the resources first."
    exit 1
fi

echo "Found resource group: $RESOURCE_GROUP"

# Get Storage Account name
echo "Looking for storage account..."
STORAGE_ACCOUNT=$(az storage account list \
    --resource-group $RESOURCE_GROUP \
    --query "[?starts_with(name, 'stgretail')].name | [0]" \
    -o tsv)

if [ -z "$STORAGE_ACCOUNT" ]; then
    echo "Storage account not found"
else
    echo "Found storage account: $STORAGE_ACCOUNT"
fi

# Get Storage Key
if [ ! -z "$STORAGE_ACCOUNT" ]; then
    echo " Getting storage key..."
    STORAGE_KEY=$(az storage account keys list \
        --resource-group $RESOURCE_GROUP \
        --account-name $STORAGE_ACCOUNT \
        --query '[0].value' -o tsv)
    echo "Storage key retrieved"
fi

# Get Synapse Workspace name
echo " Looking for Synapse workspace..."
SYNAPSE_WORKSPACE=$(az synapse workspace list \
    --resource-group $RESOURCE_GROUP \
    --query "[?starts_with(name, 'synapseretail')].name | [0]" \
    -o tsv)

if [ -z "$SYNAPSE_WORKSPACE" ]; then
    echo "Synapse workspace not found"
else
    echo "Found Synapse workspace: $SYNAPSE_WORKSPACE"
fi

# Get Subscription info
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
SUBSCRIPTION_NAME=$(az account show --query name -o tsv)

# Prompt for SQL password (secure input)
echo ""
echo "Enter the SQL Admin password you used when creating Synapse:"
read -s SQL_PASSWORD
echo ""

# Update .env file
echo "Updating .env file..."

cat > .env << EOF
# Azure Retail Analytics Pipeline - Configuration
# IMPORTANT: This file contains sensitive information. NEVER commit to Git!
# Auto-generated on $(date)

# Azure Subscription
AZURE_SUBSCRIPTION_ID="$SUBSCRIPTION_ID"
AZURE_SUBSCRIPTION_NAME="$SUBSCRIPTION_NAME"

# Resource Configuration
RESOURCE_GROUP="$RESOURCE_GROUP"
LOCATION="centralus"

# Storage Account
STORAGE_ACCOUNT="$STORAGE_ACCOUNT"
STORAGE_KEY="$STORAGE_KEY"

# Synapse Workspace
SYNAPSE_WORKSPACE="$SYNAPSE_WORKSPACE"
SQL_ADMIN_USER="sqladminuser"
SQL_ADMIN_PASSWORD="$SQL_PASSWORD"

# Containers
CONTAINER_BRONZE="bronze"
CONTAINER_SILVER="silver"
CONTAINER_GOLD="gold"

# Spark Pool
SPARK_POOL_NAME="sparkpool"


EOF

echo ".env file updated successfully!"
echo ""
echo "=========================================="
echo " Resource Summary:"
echo "=========================================="
echo "Resource Group:    $RESOURCE_GROUP"
echo "Storage Account:   $STORAGE_ACCOUNT"
echo "Synapse Workspace: $SYNAPSE_WORKSPACE"
echo "Subscription:      $SUBSCRIPTION_NAME"
echo "=========================================="
echo ""

