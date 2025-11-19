#!/bin/bash

# Script para eliminar TODOS los recursos de Azure del proyecto
# ADVERTENCIA: Esta accion es IRREVERSIBLE

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=================================================="
echo -e "${RED}ADVERTENCIA: Eliminacion de Recursos${NC}"
echo "=================================================="
echo ""

# Cargar configuracion
if [ -f .env ]; then
    source .env
else
    RESOURCE_GROUP="rg-retail-analytics"
fi

# Verificar login
if ! az account show &> /dev/null; then
    echo -e "${RED}Error: No autenticado en Azure${NC}"
    exit 1
fi

# Verificar que el resource group existe
if ! az group show --name $RESOURCE_GROUP &> /dev/null; then
    echo -e "${YELLOW}Resource Group '$RESOURCE_GROUP' no existe. Nada que eliminar.${NC}"
    exit 0
fi

# Mostrar recursos que se eliminaran
echo "Recursos que se eliminaran:"
echo ""
az resource list --resource-group $RESOURCE_GROUP --output table
echo ""

# Confirmacion multiple
echo -e "${RED}Esta accion eliminara TODOS los recursos mostrados arriba.${NC}"
echo -e "${RED}Esta accion es IRREVERSIBLE.${NC}"
echo ""
read -p "Estas seguro? Escribe 'DELETE' para confirmar: " CONFIRM

if [ "$CONFIRM" != "DELETE" ]; then
    echo "Operacion cancelada."
    exit 0
fi

echo ""
read -p "Segunda confirmacion - Escribe el nombre del Resource Group ($RESOURCE_GROUP): " CONFIRM_RG

if [ "$CONFIRM_RG" != "$RESOURCE_GROUP" ]; then
    echo "Nombre incorrecto. Operacion cancelada."
    exit 0
fi

# Eliminar
echo ""
echo -e "${YELLOW}Eliminando recursos...${NC}"
az group delete \
    --name $RESOURCE_GROUP \
    --yes \
    --no-wait

echo ""
echo -e "${GREEN}Solicitud de eliminacion enviada.${NC}"
echo ""
echo "El proceso de eliminacion puede tomar varios minutos."
echo "Verifica el estado en Azure Portal."
echo ""
echo "Para verificar si se completo:"
echo "  az group exists --name $RESOURCE_GROUP"
echo ""
