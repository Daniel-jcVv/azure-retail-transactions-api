#!/bin/bash

# Script para verificar que todos los recursos de Azure esten creados correctamente

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=================================================="
echo "Azure Resources Verification"
echo "=================================================="
echo ""

# Cargar configuracion si existe
if [ -f .env ]; then
    source .env
else
    echo -e "${YELLOW}Advertencia: .env no encontrado. Usando valores por defecto.${NC}"
    RESOURCE_GROUP="rg-retail-analytics"
fi

# Verificar login
if ! az account show &> /dev/null; then
    echo -e "${RED}Error: No autenticado en Azure${NC}"
    exit 1
fi

echo -e "${GREEN}Verificando recursos en: $RESOURCE_GROUP${NC}"
echo ""

# Contador de recursos
TOTAL=0
SUCCESS=0

# Verificar Resource Group
echo -n "Verificando Resource Group... "
TOTAL=$((TOTAL + 1))
if az group show --name $RESOURCE_GROUP &> /dev/null; then
    echo -e "${GREEN}OK${NC}"
    SUCCESS=$((SUCCESS + 1))
else
    echo -e "${RED}NO ENCONTRADO${NC}"
fi

# Listar todos los recursos
echo ""
echo "Recursos encontrados:"
az resource list --resource-group $RESOURCE_GROUP --output table

# Verificar Storage Account
echo ""
echo -n "Verificando Storage Account... "
TOTAL=$((TOTAL + 1))
STORAGE=$(az storage account list --resource-group $RESOURCE_GROUP --query "[?starts_with(name, 'stgretail')].name | [0]" -o tsv)
if [ ! -z "$STORAGE" ]; then
    echo -e "${GREEN}OK - $STORAGE${NC}"
    SUCCESS=$((SUCCESS + 1))

    # Verificar containers
    STORAGE_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE --query '[0].value' -o tsv)
    echo ""
    echo "Containers:"
    for container in bronze silver gold; do
        echo -n "  $container... "
        TOTAL=$((TOTAL + 1))
        if az storage container exists --name $container --account-name $STORAGE --account-key $STORAGE_KEY --query exists -o tsv | grep -q true; then
            echo -e "${GREEN}OK${NC}"
            SUCCESS=$((SUCCESS + 1))
        else
            echo -e "${RED}NO ENCONTRADO${NC}"
        fi
    done
else
    echo -e "${RED}NO ENCONTRADO${NC}"
fi

# Verificar Synapse Workspace
echo ""
echo -n "Verificando Synapse Workspace... "
TOTAL=$((TOTAL + 1))
SYNAPSE=$(az synapse workspace list --resource-group $RESOURCE_GROUP --query "[?starts_with(name, 'synapseretail')].name | [0]" -o tsv)
if [ ! -z "$SYNAPSE" ]; then
    echo -e "${GREEN}OK - $SYNAPSE${NC}"
    SUCCESS=$((SUCCESS + 1))
else
    echo -e "${RED}NO ENCONTRADO${NC}"
fi

# Verificar Spark Pool
echo -n "Verificando Spark Pool... "
TOTAL=$((TOTAL + 1))
if [ ! -z "$SYNAPSE" ]; then
    SPARK=$(az synapse spark pool list --workspace-name $SYNAPSE --resource-group $RESOURCE_GROUP --query "[?name=='sparkpool'].name | [0]" -o tsv)
    if [ ! -z "$SPARK" ]; then
        echo -e "${GREEN}OK - $SPARK${NC}"
        SUCCESS=$((SUCCESS + 1))
    else
        echo -e "${RED}NO ENCONTRADO${NC}"
    fi
else
    echo -e "${YELLOW}SKIP (Synapse no encontrado)${NC}"
fi

# Resumen
echo ""
echo "=================================================="
echo "Resumen de verificacion:"
echo "  Total de recursos esperados: $TOTAL"
echo "  Recursos encontrados: $SUCCESS"
echo "  Recursos faltantes: $((TOTAL - SUCCESS))"
echo ""

if [ $SUCCESS -eq $TOTAL ]; then
    echo -e "${GREEN}Todos los recursos estan correctamente configurados!${NC}"
    exit 0
else
    echo -e "${YELLOW}Algunos recursos faltan o no estan configurados correctamente.${NC}"
    exit 1
fi
