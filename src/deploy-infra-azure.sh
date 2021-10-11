#!/bin/bash

#---------------------------------------------------------------
#Variaveis:

RG='rg-desafio'
RG_LOCATION='eastus2'
DNS_ZONE='desafiocbo.labs'
NSG='nsg-desafio'
TAGS='ambiente=desafio'
VNET='vnet-desafio'
VNET_ADDRESS_PREFIX='10.1.0.0/16'
AS_FRONT_NAME="as-front-eastus2"

#Subnets
SN_MGMT='subnet-mgmt'
SN_MGMT_PREFIX='10.1.1.0/24'
SN_LB='subnet-lb'
SN_LB_PREFIX='10.1.2.0/24'
SN_FRONT='subnet-front'
SN_FRONT_PREFIX='10.1.3.0/24'
SN_BACK='subnet-back'
SN_BACK_PREFIX='10.1.4.0/24'
SN_DATA='subnet-data'
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
LB_FRONT_IP='10.1.2.10'
LB_BACK="lb-priv-back"
LB_BACK_IP='10.1.2.20'

#VMs front
VM_FRONT_IMAGE='cognosys:nginx-with-centos-7-9:nginx-with-centos-7-9:1.2019.1009'
VM_FRONT_SIZE='Standard_B1s'

VM_FRONT_NAME1='vmfront01'
VM_FRONT_IP1='10.1.3.10'
VM_FRONT_OS_DISK_NAME1="$VM_FRONT_NAME1-os-disk"
VM_FRONT_OS_DISK_SIZE1='15'
VM_FRONT_OS_DISK_SKU1='StandardSSD_LRS'
VM_FRONT_OS_TYPE1='linux'

VM_FRONT_NAME2='vmfront02'
VM_FRONT_IP2='10.1.3.20'
VM_FRONT_OS_DISK_NAME2="$VM_FRONT_NAME2-os-disk"
VM_FRONT_OS_DISK_SIZE2='15'
VM_FRONT_OS_DISK_SKU2='StandardSSD_LRS'
VM_FRONT_OS_TYPE2='linux'

VMSS_BACK_IMAGE=''
VMSS_BACK_SIZE='Standard_B1s'

VM_MGMT_NAME='vmmgmt01'
VM_MGMT_IP='10.1.1.10'
VM_MGMT_IMAGE='OpenLogic:CentOS:7.5:latest'
VM_MGMT_SIZE='Standard_B1s'
VM_MGMT_PIP_NAME="$VM_MGMT_NAME-pip"
VM_MGMT_PIP_SKU="Basic"
VM_MGMT_OS_DISK_NAME="$VM_MGMT_NAME-os-disk"
VM_MGMT_OS_DISK_SIZE='10'
VM_MGMT_OS_DISK_SKU='StandardSSD_LRS'
VM_MGMT_OS_TYPE='linux'

#NSG rules

#---------------------------------------------------------------

#Criação do resource group
echo "Criação do resource group"
az group create \
--location $RG_LOCATION \
--resource-group $RG \
--tags $TAGS \
-o table --verbose

#Criação do Network Security Group
echo "Criação do Network Security Group"
az network nsg create -g $RG \
-n $NSG \
--tags $TAGS \
-o table --verbose

#Criação do DNS
echo "Criação do DNS"
az network dns zone create -g $RG \
-n $DNS_ZONE \
--tags $TAGS \
-o table --verbose

#Criação do availability-set das vms de front
echo "Criação do availability-set das vms de front"
az vm availability-set create \
-n $AS_FRONT_NAME \
-g $RG \
--platform-fault-domain-count 2 \
--platform-update-domain-count 2 \
--tags $TAGS \
-o table --verbose

#Adicionando entrada no DNS: load balance frontend
echo "Adicionando entrada no DNS: load balance frontend"
az network dns record-set a add-record \
-g $RG \
-z $DNS_ZONE \
-n $LB_FRONT \
-a $LB_FRONT_IP \
-o table --verbose

#Adicionando entrada no DNS: load balance backend
echo "Adicionando entrada no DNS: load balance backend"
az network dns record-set a add-record \
-g $RG \
-z $DNS_ZONE \
-n $LB_BACK \
-a $LB_BACK_IP \
-o table --verbose

#Adicionando entrada no DNS: vm front1
echo "Adicionando entrada no DNS: vm front1"
az network dns record-set a add-record \
-g $RG \
-z $DNS_ZONE \
-n $VM_FRONT_NAME1 \
-a $VM_FRONT_IP1 \
-o table --verbose

#Adicionando entrada no DNS: vm front2
echo "Adicionando entrada no DNS: vm front2"
az network dns record-set a add-record \
-g $RG \
-z $DNS_ZONE \
-n $VM_FRONT_NAME2 \
-a $VM_FRONT_IP2 \
-o table --verbose

#Adicionando entrada no DNS: vm de gerencia
echo "Adicionando entrada no DNS: vm de gerencia"
az network dns record-set a add-record \
-g $RG \
-z $DNS_ZONE \
-n $VM_MGMT_NAME \
-a $VM_MGMT_IP \
-o table --verbose

#Criação da Virtual Network
echo "Criação da Virtual Network"
az network vnet create -n $VNET --resource-group $RG \
--address-prefixes $VNET_ADDRESS_PREFIX \
--subnet-name $SN_MGMT \
--subnet-prefixes $SN_MGMT_PREFIX \
--network-security-group $NSG \
--tags $TAGS \
-o table --verbose

#Criação da subnet de frontend
echo "Criação da subnet de frontend"
az network vnet subnet create -g $RG \
--vnet-name $VNET \
-n $SN_FRONT \
--address-prefixes $SN_FRONT_PREFIX \
--network-security-group $NSG \
-o table --verbose

#Criação  da subnet de backend
echo "Criação  da subnet de backend"
az network vnet subnet create -g $RG \
--vnet-name $VNET \
-n $SN_BACK \
--address-prefixes $SN_BACK_PREFIX \
--network-security-group $NSG \
-o table --verbose

#Criação da subnet de dados
echo "Criação da subnet de dados"
az network vnet subnet create -g $RG \
--vnet-name $VNET \
-n $SN_DATA \
--address-prefixes $SN_DATA_PREFIX \
--network-security-group $NSG \
 -o table --verbose

#Criação do load Balancer front
echo "Criação do load Balancer front"
az network lb create -g $RG -n $LB_FRONT \
--sku $LB_SKU \
--vnet-name $VNET \
--subnet $LB_FRONT_SN \
--tags $TAGS \
-o table --verbose

#Criação do load Balancer backend
echo "Criação do load Balancer backend"
az network lb create -g $RG -n $LB_BACK \
--sku $LB_SKU \
--vnet-name $VNET \
--subnet $LB_BACK_SN \
--tags $TAGS \
-o table --verbose

#Aceitando as licencas das imagens do nginx
echo "Aceitando as licencas das imagens do nginx"
az vm image terms accept \
--urn $VM_FRONT_IMAGE \
-o table --verbose

#Criação das VMs de front
echo "Criação das VMs de front: front1"
az vm create -n $VM_FRONT_NAME1 \
-g $RG \
--nsg $NSG \
--availability-set $AS_FRONT_NAME \
--vnet-name $VNET \
--subnet $SN_FRONT \
--image $VM_FRONT_IMAGE \
--storage-sku $VM_FRONT_OS_DISK_SKU1 \
--private-ip-address $VM_FRONT_IP1 \
--public-ip-address "" \
--generate-ssh-keys \
--size $VM_FRONT_SIZE \
--tags $TAGS \
-o table --verbose

#Criação das VMs de front: front2
echo "Criação das VMs de front: front2"
az vm create -n $VM_FRONT_NAME2 \
-g $RG \
--nsg $NSG \
--availability-set $AS_FRONT_NAME \
--vnet-name $VNET \
--subnet $SN_FRONT \
--image $VM_FRONT_IMAGE \
--storage-sku $VM_FRONT_OS_DISK_SKU2 \
--private-ip-address $VM_FRONT_IP2 \
--public-ip-address "" \
--generate-ssh-keys \
--size $VM_FRONT_SIZE \
--tags $TAGS \
-o table --verbose

#Criação do frontend pool
echo "Criação do frontend pool"
az network lb address-pool create \
-g $RG \
--lb-name $LB_FRONT \
-n $BP_FRONT \
--backend-address name=$VM_FRONT_NAME1 ip-address=$VM_FRONT_IP1 \
--backend-address name=$VM_FRONT_NAME2 ip-address=$VM_FRONT_IP2 \
-o table --verbose

#Criação do backend pool
echo "Criação do backend pool"
az network lb address-pool create \
-g $RG \
--lb-name $LB_BACK \
-n $BP_BACK \
-o table --verbose

#Criação da vm de mgmt
echo "Criação da vm de mgmt"
az vm create -n $VM_MGMT_NAME \
-g $RG \
--nsg $NSG \
--vnet-name $VNET \
--subnet $SN_MGMT \
--image $VM_MGMT_IMAGE \
--storage-sku $VM_MGMT_OS_DISK_SKU \
--private-ip-address $VM_MGMT_IP \
--public-ip-address $VM_MGMT_PIP_NAME \
--public-ip-sku $VM_MGMT_PIP_SKU \
--generate-ssh-keys \
--size $VM_MGMT_SIZE \
--tags $TAGS \
-o table --verbose

#Criando regras do nsg
echo "Criando regras do nsg"
az network nsg rule create \
--name "Allow-ssh-from-Internet" \
--nsg-name $NSG \
--priority 1000 \
--description "SSH from Internet to subnet-mgmt" \
-g $RG \
--access "Allow" \
--protocol "Tcp" \
--direction "Inbound" \
--source-address-prefixes "Internet" \
--destination-port-ranges "22" \
--destination-address-prefixes $SN_MGMT_PREFIX \
-o table --verbose

az network nsg rule create \
--name "Allow-ssh-from-subnet-mgmt" \
--nsg-name $NSG \
--priority 1100 \
--description "SSH from subnet-mgmt to all subnets" \
-g $RG \
--access "Allow" \
--protocol "Tcp" \
--direction "Inbound" \
--source-address-prefixes "Internet" \
--destination-port-ranges "22" \
--destination-address-prefixes $SN_MGMT_PREFIX $SN_BACK_PREFIX $SN_DATA_PREFIX $SN_FRONT_PREFIX \
-o table --verbose

az network nsg rule create \
--name "Allow-http-from-any" \
--nsg-name $NSG \
--priority 1200 \
--description "Http from any to subnet-front and subnet-back" \
-g $RG \
--access "Allow" \
--protocol "Tcp" \
--direction "Inbound" \
--source-address-prefixes "*" \
--destination-port-ranges "80" \
--destination-address-prefixes $SN_FRONT_PREFIX $SN_BACK_PREFIX \
-o table --verbose

az network nsg rule create \
--name "Allow-tcp-from-internal-to-mysql" \
--nsg-name $NSG \
--priority 1400 \
--description "Tcp from any internal to subnet-data" \
-g $RG \
--access "Allow" \
--protocol "Tcp" \
--direction "Inbound" \
--source-address-prefixes $SN_FRONT_PREFIX $SN_BACK_PREFIX $SN_MGMT_PREFIX \
--destination-port-ranges "3306" \
--destination-address-prefixes $SN_DATA_PREFIX \
-o table --verbose