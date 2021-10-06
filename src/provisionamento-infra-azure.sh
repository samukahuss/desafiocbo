#!/bin/bash

#---------------------------------------------------------------
#Variaveis:

RG='rg-desafio'
RG_LOCATION='eastus2'
DNS_ZONE='desafiocbo.labs'
NSG='nsg-desafio'
TAGS='ambiente=desafio'
VNET='vnet-desafio'
VNET_ADDRESS_PREFIX='10.1.0.0./16'

#Subnets
SN_MGMT='subnet-mgmt'
SN_MGMT_PREFIX='10.1.1.0/24'
SN_LB='subnet-lb'
SN_LB_PREFIX='10.1.2.0/24'
SN_FRONT='subnet-front'
SN_FRONT_PREFIX='10.1.3.0/24'
SN_BACK='subnet-back'
SN_BACK_PREFIX='10.1.4.0/24'
SN_DATA='subnet-back'
SN_DATA_PREFIX='10.1.5.0/24'

#Load balances
LB_SKU='Basic'
LB_FRONT='lb-front-priv'
LB_FRONT_SN=$SN_FRONT
LB_BACK='lb-back-priv'
LB_BACK_SN=$SN_BACK

#Backend pools
BP_FRONT='bpool-front'
BP_BACK='bpool-back'

#Entradas no dns
LB_FRONT="lb-priv-front"
LB_FRONT_IP='10.1.2.1'
LB_BACK="lb-priv-back"
LB_BACK_IP='10.1.2.2'
#---------------------------------------------------------------

#Criação do resource group
az group create \
--location $RG_LOCATION \
--resource-group $RG \
--tags $TAGS \
-o table --verbose

#Criação do Network Security Group
az network nsg create -g $RG \
-n $NSG \
--tags $TAGS \
-o table --verbose

#Criação do DNS
az network dns zone create -g $RG \
-n $DNS_ZONE \
--tags $TAGS \
-o table --verbose

#Adicionando entrada no DNS: load balance frontend
az network dns record-set a add-record \
-g $RG \
-z $DNS_ZONE \
-n $LB_FRONT \
-a $LB_FRONT_IP \
-o table --verbose

#Adicionando entrada no DNS: load balance backend
az network dns record-set a add-record \
-g $RG \
-z $DNS_ZONE \
-n $LB_BACK \
-a $LB_BACK_IP \
-o table --verbose

#Criação da Virtual Network
az network vnet create -n $VNET --resource-group $RG \
--address-prefixes $VNET_ADDRESS_PREFIX \
--subnet-name $SN_MGMT \
--subnet-prefixes $SN_MGMT_PREFIX \
--network-security-group $NSG \
--tags $TAGS -o table

#Criação da subnet de frontend
az network vnet subnet create -g $RG \
--vnet-name $VNET \
-n $SN_FRONT \
--address-prefixes $SN_FRONT_PREFIX \
--network-security-group $NSG \
-o table --verbose

#Criação  da subnet de backend
az network vnet subnet create -g $RG \
--vnet-name $VNET \
-n $SN_BACK \
--address-prefixes $SN_BACK_PREFIX \
--network-security-group $NSG\
-o table

#Criação da subnet de dados
az network vnet subnet create -g $RG \
--vnet-name $VNET \
-n $SN_DATA \
--address-prefixes $SN_DATA_PREFIX \
--network-security-group $NSG\
 -o table

#Criação do load Balancer front
az network lb create -g $RG -n $LB_FRONT \
--sku $LB_SKU \
--vnet-name $VNET \
--subnet $LB_FRONT_SN \
--tags $TAGS \
-o table --verbose

#Criação do load Balancer backend
az network lb create -g $RG -n $LB_BACK \
--sku $LB_SKU \
--vnet-name $VNET \
--subnet $LB_BACK_SN \
--tags $TAGS \
-o table --verbose

#Criação do backend pool
az network lb address-pool create -g $RG \
--lb-name $LB_FRONT \
-n $BP_FRONT \
-o table --verbose

#Criação do backend pool
az network lb address-pool create -g $RG \
--lb-name $LB_BACK \
-n $BP_BACK \
-o table --verbose
