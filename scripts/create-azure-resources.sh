#!/bin/bash

# Script para crear todos los recursos de Azure necesarios para el proyecto
# Retail Analytics Pipeline con Medallion Architecture

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=================================================="
echo "Azure Retail Analytics Pipeline - Setup Script"
echo "=================================================="
echo ""

# Verificar login en Azure
if ! az account show &> /dev/null; then
    echo -e "${RED}Error: No estas autenticado en Azure${NC}"
    echo "Ejecuta: az login"
    exit 1
fi

# Configuracion del proyecto
RESOURCE_GROUP="rg-retail-analytics"
LOCATION="centralus"
STORAGE_ACCOUNT="stgretail$(date +%s)"
SYNAPSE_WORKSPACE="synapseretail$(date +%s)"
SPARK_POOL="sparkpool"

# Solicitar password de SQL
echo -e "${YELLOW}Ingresa el password para SQL Admin (minimo 8 caracteres, mayuscula, minuscula, numero, caracter especial):${NC}"
read -s SQL_PASSWORD
echo ""

echo "Configuracion:"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Location: $LOCATION"
echo "  Storage Account: $STORAGE_ACCOUNT"
echo "  Synapse Workspace: $SYNAPSE_WORKSPACE"
echo ""
read -p "Continuar? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Crear Resource Group
echo -e "${GREEN}[1/6] Creando Resource Group...${NC}"
az group create \
    --name $RESOURCE_GROUP \
    --location $LOCATION \
    --output none

# Crear Storage Account con ADLS Gen2
echo -e "${GREEN}[2/6] Creando Storage Account con ADLS Gen2...${NC}"
az storage account create \
    --name $STORAGE_ACCOUNT \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --sku Standard_LRS \
    --kind StorageV2 \
    --hierarchical-namespace true \
    --output none

# Crear Synapse Workspace
echo -e "${GREEN}[3/6] Creando Synapse Workspace (esto toma 5-7 minutos)...${NC}"
az synapse workspace create \
    --name $SYNAPSE_WORKSPACE \
    --resource-group $RESOURCE_GROUP \
    --storage-account $STORAGE_ACCOUNT \
    --file-system retail \
    --sql-admin-login-user sqladminuser \
    --sql-admin-login-password "$SQL_PASSWORD" \
    --location $LOCATION \
    --output none

# Configurar Firewall
echo -e "${GREEN}[4/6] Configurando Firewall...${NC}"
az synapse workspace firewall-rule create \
    --name AllowAll \
    --workspace-name $SYNAPSE_WORKSPACE \
    --resource-group $RESOURCE_GROUP \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 255.255.255.255 \
    --output none

# Crear containers
echo -e "${GREEN}[5/6] Creando containers (bronze, silver, gold)...${NC}"
STORAGE_KEY=$(az storage account keys list \
    --resource-group $RESOURCE_GROUP \
    --account-name $STORAGE_ACCOUNT \
    --query '[0].value' -o tsv)

az storage container create --name bronze --account-name $STORAGE_ACCOUNT --account-key $STORAGE_KEY --output none
az storage container create --name silver --account-name $STORAGE_ACCOUNT --account-key $STORAGE_KEY --output none
az storage container create --name gold --account-name $STORAGE_ACCOUNT --account-key $STORAGE_KEY --output none

# Crear Spark Pool
echo -e "${GREEN}[6/6] Creando Spark Pool...${NC}"
az synapse spark pool create \
    --name $SPARK_POOL \
    --workspace-name $SYNAPSE_WORKSPACE \
    --resource-group $RESOURCE_GROUP \
    --spark-version 3.3 \
    --node-count 3 \
    --node-size Small \
    --enable-auto-pause true \
    --delay 15 \
    --output none

# Guardar configuracion
echo -e "${GREEN}Guardando configuracion en .env...${NC}"
cat > .env << EOF
# Azure Retail Analytics Pipeline - Configuration
# Auto-generated on $(date)

AZURE_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
RESOURCE_GROUP="$RESOURCE_GROUP"
LOCATION="$LOCATION"
STORAGE_ACCOUNT="$STORAGE_ACCOUNT"
STORAGE_KEY="$STORAGE_KEY"
SYNAPSE_WORKSPACE="$SYNAPSE_WORKSPACE"
SQL_ADMIN_USER="sqladminuser"
SQL_ADMIN_PASSWORD="$SQL_PASSWORD"
CONTAINER_BRONZE="bronze"
CONTAINER_SILVER="silver"
CONTAINER_GOLD="gold"
SPARK_POOL_NAME="$SPARK_POOL"
EOF

echo ""
echo "=================================================="
echo -e "${GREEN}Setup completado exitosamente!${NC}"
echo "=================================================="
echo ""
echo "Recursos creados:"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Storage Account: $STORAGE_ACCOUNT"
echo "  Synapse Workspace: $SYNAPSE_WORKSPACE"
echo "  Spark Pool: $SPARK_POOL"
echo ""
echo "Configuracion guardada en: .env"
echo ""
echo "Siguientes pasos:"
echo "  1. Subir datos a GitHub"
echo "  2. Crear pipeline en Synapse Studio"
echo "  3. Ejecutar notebooks de transformacion"
echo ""
echo "Synapse Studio: https://web.azuresynapse.net"
echo "=================================================="
