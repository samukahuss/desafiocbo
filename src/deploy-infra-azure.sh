#!/bin/bash

#---------------------------------------------------------------
#Variaveis:
LOG_DIR='/repos/github/desafiocbo/src/.logs'
DATE=$(date +%d%m%y_%H%M%S)
LOG_FILE="$LOG_DIR/$DATE.log"
OUTPUT="-o table --verbose"

RG='rg-desafiocbo'
RG_LOCATION='eastus2'
DNS_ZONE='private.desafiocbo.corp'
DNS_LINK_NAME='desafiocbo-dnslink'
NSG='nsg-desafiocbo'
TAGS='ambiente=desafiocbo'
VNET='vnet-desafiocbo'
VNET_ADDRESS_PREFIX='10.1.0.0/16'
AS_FRONT_NAME="as-front-eastus2"

#Subnets
SN_VPN='GatewaySubnet'
SN_VPN_PREFIX='10.1.0.0/24'
SN_MGMT='subnet-mgmt'
SN_MGMT_PREFIX='10.1.1.0/24'
SN_APPGW='subnet-appgw'
SN_APPGW_PREFIX='10.1.2.0/24'
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

#App service 
BACK_APP_PATH='/repos/github/desafiocbo-app'
BACK_APP_SKU='B1'
#"P1V2"
#'S1'
BACK_APP_NAME='app-desafiocbo'
BACK_APP_FQDN="$BACK_APP_NAME.azurewebsites.net"
BACK_APP_LOCATION='eastus2'
BACK_APP_SP='app-serviceplan-desafiocbo'

#Application Gateway
APPGW_NAME='appgw-desafiocbo'
APPGW_PUBLIC_IP='appgw-desafiocbo-pip'
APPGW_PRIVATE_IP='10.1.2.10'
APPGW_LOCATION='eastus2'
APPGW_SKU='Standard_Medium'
APPGW_RT_RULE='PathBasedRouting'
APPGW_BPOOL_FRONT='bpool-front'
APPGW_BPOOL_BACK='bpool-back'
APPGW_DEFAULT_RULE='Rule1'

#Application Gateway Rule
AGR_NAME_FRONT='rule-http-front'
AGR_NAME_PATH='/front'
AGR_NAME_BACK='rule-http-back'

#Http-settings
HS_NAME='appGatewayBackendHttpSettings'

#url-path-map
UPM_NAME='url-map-http'

#url-path-map rule
UPMR_NAME='rule-http-back'
UPMR_NAME_PATH='/back'

#probe
PROBE_NAME='probe-http'

#MariaDB
DB_NAME='dbdesafiocbo'
DB_USER='dbadmin'
DB_PASS='ASD.asdf2021'
DB_STG_SIZE='5120'
DB_SKU='GP_Gen5_2'

#Data private endpoint
DATA_PRIVATE_ENDPOINT_NAME='data-private-endpoint'
PRIVATE_ENDPOINT_CONNECTION_NAME='data-connection'

#App private endpoint
WEB_PRIVATE_ENDPOINT='webapp-private-endpoint' 
WEB_CONNECTION_NAME='webapp-connection'

#VPN
VIRTUAL_NETWORK_GW_NAME='vng-desafiocbo'
VIRTUAL_NETWORK_GW_PIP="$VIRTUAL_NETWORK_GW_NAME'_pip'"
VIRTUAL_NETWORK_GW_REGION='eastus2'

#---------------------------------------------------------------

#Criação do resource group
echo "Criação do resource group"
az group create \
--location $RG_LOCATION \
--resource-group $RG \
--tags $TAGS \
$OUTPUT

#Criação do Network Security Group
echo "Criação do Network Security Group"
az network nsg create -g $RG \
-n $NSG \
--tags $TAGS \
$OUTPUT

#Criação do DNS
echo "Criação do DNS"
az network private-dns zone create \
-g $RG \
-n $DNS_ZONE \
--tags $TAGS \
$OUTPUT

#Criação do availability-set das vms de front
echo "Criação do availability-set das vms de front"
az vm availability-set create \
-n $AS_FRONT_NAME \
-g $RG \
--platform-fault-domain-count 2 \
--platform-update-domain-count 2 \
--tags $TAGS \
$OUTPUT

#Adicionando entrada no DNS: vm front1
echo "Adicionando entrada no DNS: vm front1"
az network private-dns record-set a add-record \
-g $RG \
-z $DNS_ZONE \
-n $VM_FRONT_NAME1 \
-a $VM_FRONT_IP1 \
$OUTPUT

#Adicionando entrada no DNS: vm front2
echo "Adicionando entrada no DNS: vm front2"
az network private-dns record-set a add-record \
-g $RG \
-z $DNS_ZONE \
-n $VM_FRONT_NAME2 \
-a $VM_FRONT_IP2 \
$OUTPUT

#Adicionando entrada no DNS: vm de gerencia
echo "Adicionando entrada no DNS: vm de gerencia"
az network private-dns record-set a add-record \
-g $RG \
-z $DNS_ZONE \
-n $VM_MGMT_NAME \
-a $VM_MGMT_IP \
$OUTPUT

#Criação da Virtual Network
echo "Criação da Virtual Network"
az network vnet create -n $VNET --resource-group $RG \
--address-prefixes $VNET_ADDRESS_PREFIX \
--subnet-name $SN_MGMT \
--subnet-prefixes $SN_MGMT_PREFIX \
--network-security-group $NSG \
--tags $TAGS \
$OUTPUT

#link do DNS privado à vnet
echo "link do DNS privado à vnet"
az network private-dns link vnet create \
-g $RG \
-n $DNS_LINK_NAME \
-z $DNS_ZONE \
-v $VNET \
-e False \
$OUTPUT

#Criação da subnet de frontend
echo "Criação da subnet de frontend"
az network vnet subnet create -g $RG \
--vnet-name $VNET \
-n $SN_FRONT \
--address-prefixes $SN_FRONT_PREFIX \
--network-security-group $NSG \
$OUTPUT

#Criação  da subnet de backend
echo "Criação  da subnet de backend"
az network vnet subnet create -g $RG \
--vnet-name $VNET \
-n $SN_BACK \
--address-prefixes $SN_BACK_PREFIX \
--network-security-group $NSG \
$OUTPUT

#Criação da subnet de dados
echo "Criação da subnet de dados"
az network vnet subnet create -g $RG \
--vnet-name $VNET \
-n $SN_DATA \
--address-prefixes $SN_DATA_PREFIX \
--network-security-group $NSG \
 $OUTPUT

#Criação da subnet dp app-gw
echo "Criação da subnet de dados"
az network vnet subnet create -g $RG \
--vnet-name $VNET \
-n $SN_APPGW \
--address-prefixes $SN_APPGW_PREFIX \
--network-security-group $NSG \
$OUTPUT

#Criação da subnet de VPN
echo "Criação da subnet de VPN"
az network vnet subnet create -g $RG \
--vnet-name $VNET \
-n $SN_VPN \
--address-prefixes $SN_VPN_PREFIX \
--network-security-group $NSG \
$OUTPUT

##Criação do load Balancer front
#echo "Criação do load Balancer front"
#az network lb create -g $RG -n $LB_FRONT \
#--sku $LB_SKU \
#--vnet-name $VNET \
#--subnet $LB_FRONT_SN \
#--tags $TAGS \
#$OUTPUT

##Criação do load Balancer backend
#echo "Criação do load Balancer backend"
#az network lb create -g $RG -n $LB_BACK \
#--sku $LB_SKU \
#--vnet-name $VNET \
#--subnet $LB_BACK_SN \
#--tags $TAGS \
#$OUTPUT

#Aceitando as licencas das imagens do nginx
echo "Aceitando as licencas das imagens do nginx"
az vm image terms accept \
--urn $VM_FRONT_IMAGE \
$OUTPUT

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
$OUTPUT

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
$OUTPUT

##Criação do frontend pool
#echo "Criação do frontend pool"
#az network lb address-pool create \
#-g $RG \
#--lb-name $LB_FRONT \
#-n $BP_FRONT \
#--backend-address name=$VM_FRONT_NAME1 ip-address=$VM_FRONT_IP1 \
#--backend-address name=$VM_FRONT_NAME2 ip-address=$VM_FRONT_IP2 \
#$OUTPUT

##Criação do backend pool
#echo "Criação do backend pool"
#az network lb address-pool create \
#-g $RG \
#--lb-name $LB_BACK \
#-n $BP_BACK \
#$OUTPUT

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
$OUTPUT

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
$OUTPUT

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
$OUTPUT

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
$OUTPUT

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
$OUTPUT

az network nsg rule create \
--name "Allow-tcp-from-appgw-to-front-and-back" \
--nsg-name $NSG \
--priority 1500 \
--description "Tcp from subnet-appgw to subnet-front and subnet-back" \
-g $RG \
--access "Allow" \
--protocol "Tcp" \
--direction "Inbound" \
--source-address-prefixes $SN_APPGW_PREFIX \
--destination-port-ranges "*" \
--destination-address-prefixes $SN_FRONT_PREFIX $SN_BACK_PREFIX \
$OUTPUT

az network nsg rule create \
--name "Allow-tcp-from-internet-to-appgw" \
--nsg-name $NSG \
--priority 1600 \
--description "Tcp from subnet-appgw to subnet-front and subnet-back" \
-g $RG \
--access "Allow" \
--protocol "Tcp" \
--direction "Inbound" \
--source-address-prefixes "Internet" \
--destination-port-ranges "80" "443" "8080" \
--destination-address-prefixes $SN_APPGW_PREFIX \
$OUTPUT

#Lembrar de informar essa parte no readme
cd $BACK_APP_PATH

az webapp up \
--sku $BACK_APP_SKU \
--name $BACK_APP_NAME \
--location $BACK_APP_LOCATION \
--resource-group $RG \
--plan $BACK_APP_SP \
$OUTPUT

cd -

#desabilitando private endpoint policy: subnet-back
#echo "desabilitando private endpoint policy: subnet-back"
#az network vnet subnet update \
#--name $SN_BACK \
#--resource-group $RG \
#--vnet-name $VNET \
#--disable-private-endpoint-network-policies true

#WEBAPP_PRIVATE_CONNECTION_RESOURCE_ID=$(az resource show -g $RG -n $BACK_APP_NAME --resource-type "Microsoft.Web/sites" --query "id" -o tsv)

#Criacao do private-endpoint para o webapp
#echo "Criacao do private-endpoint para o webapp"
#az network private-endpoint create \
#--name $WEB_PRIVATE_ENDPOINT \
#--resource-group $RG \
#--vnet-name $VNET \
#--subnet $SN_BACK \
#--connection-name $WEB_CONNECTION_NAME \
#--private-connection-resource-id $WEBAPP_PRIVATE_CONNECTION_RESOURCE_ID \
#--group-id 'sites'

#WEBAPP_PRIVATE_IP=$(az resource show --ids $WEBAPP_PRIVATE_CONNECTION_RESOURCE_ID  --query 'properties.privateEndpointConnections[0].properties.ipAddresses[0]' -o tsv)

#adcição da entrada no DNS: app-desafiocbo
#echo "adcição da entrada no DNS: app-desafiocbo"
#az network private-dns record-set a create \
#--name $BACK_APP_NAME \
#--zone-name $RG \
#--resource-group $RG

#az network private-dns record-set a add-record \
#--record-set-name $BACK_APP_NAME \
#--zone-name $DNS_ZONE \
#--resource-group $RG \
#-a $WEBAPP_PRIVATE_IP

#Criando o application gateway
echo "Criando o application gateway"
az network application-gateway create \
--capacity 1 \
--frontend-port 80 \
--http-settings-cookie-based-affinity Disabled \
--http-settings-port 80 \
--http-settings-protocol Http \
--location $APPGW_LOCATION \
--name $APPGW_NAME \
--public-ip-address $APPGW_PUBLIC_IP \
--private-ip-address $APPGW_PRIVATE_IP \
--resource-group $RG \
--sku $APPGW_SKU \
--subnet $SN_APPGW \
--vnet-name $VNET \
--tags $TAGS \
$OUTPUT

#Criando e adicionando o address-pool bpool-front ao appgw
echo "Criando e adicionando o address-pool bpool-front ao appgw"
az network application-gateway address-pool create \
-g $RG \
--gateway-name $APPGW_NAME \
-n $APPGW_BPOOL_FRONT \
--servers $VM_FRONT_IP1 $VM_FRONT_IP2 \
$OUTPUT

#Criando e adicionando o address-pool bpool-back ao appgw
echo "Criando e adicionando o address-pool bpool-back ao appgw"
az network application-gateway address-pool create \
-g $RG \
--gateway-name $APPGW_NAME \
-n $APPGW_BPOOL_BACK \
--servers $BACK_APP_FQDN \
$OUTPUT

#Criando url-path-map
echo "Criando url-path-map"
az network application-gateway url-path-map create \
-g $RG \
--gateway-name $APPGW_NAME \
-n $UPM_NAME \
--rule-name $AGR_NAME_FRONT \
--paths $AGR_NAME_PATH \
--address-pool $APPGW_BPOOL_FRONT \
--default-address-pool $APPGW_BPOOL_FRONT \
--http-settings $HS_NAME \
--default-http-settings $HS_NAME \
$OUTPUT

#criando uma nova probe http
echo "criando uma nova probe"
az network application-gateway probe create \
-g $RG \
--gateway-name $APPGW_NAME \
-n $PROBE_NAME \
--protocol 'http' \
--interval '10' \
--timeout '10' \
--threshold '3' \
--host-name-from-http-settings 'true' \
--path '/' \
$OUTPUT

#Habilitando o override no http-settings: '/'
echo "Habilitando o override no http-settings: '/'"
az network application-gateway http-settings update \
-g $RG \
--gateway-name $APPGW_NAME \
-n $HS_NAME \
--path '/' \
--host-name-from-backend-pool 'true' \
--probe $PROBE_NAME \
$OUTPUT

#Atualizando a regra default: 'Rule1'
echo "Atualizando a regra default: 'Rule1'"
az network application-gateway rule update \
-g $RG \
--gateway-name $APPGW_NAME \
-n $APPGW_DEFAULT_RULE \
--rule-type $APPGW_RT_RULE \
--address-pool $APPGW_BPOOL_FRONT \
--url-path-map $UPM_NAME \
$OUTPUT

#az network application-gateway http-settings create \
#-g $RG \
#--gateway-name $APPGW_NAME \
#-n 'appGatewayBackendHttpsSettings' \
#--port 443 \
#--protocol Https \
#--cookie-based-affinity Disabled \
#--timeout 20 \
#--path '/' \
#$OUTPUT

#Criando a regra para o path do backend
echo "Criando a regra para o path do backend"
az network application-gateway url-path-map rule create \
-g $RG \
--gateway-name $APPGW_NAME \
-n $UPMR_NAME \
--path-map-name $UPM_NAME \
--paths $UPMR_NAME_PATH \
--address-pool $APPGW_BPOOL_BACK \
--http-settings $HS_NAME \
$OUTPUT

#Obtendo o ip publico da vmmgmt01
echo "Obtendo o ip publico da vmmgmt01"
VMMGMT01_PIP=$(az vm show -d -g rg-desafio -n vmmgmt01 --query publicIps -o tsv)

#Adcionando entrada no DNS: VMMGMT01_PIP
echo "Adcionando entrada no DNS: vmmgmt01-pip"
az network private-dns record-set a add-record \
-g $RG \
-z $DNS_ZONE \
-n 'vmmgmt01-pip' \
-a $VMMGMT01_PIP \
$OUTPUT

#Desabilitando o alerta de endpoint-policy
echo "Desabilitando o alerta de endpoint-policy"
az network vnet subnet update \
 --name $SN_DATA \
 --resource-group $RG \
 --vnet-name $VNET \
 --disable-private-endpoint-network-policies true \
 $OUTPUT

# Criando database: mariadb
echo "Criando database: mariadb"
az mariadb server create \
--name $DB_NAME \
--resource-group $RG \
--location $RG_LOCATION \
--admin-user $DB_USER \
--admin-password $DB_PASS \
--auto-grow 'Disabled' \
--public-network-access 'Disabled' \
--storage-size $DB_STG_SIZE \
--sku-name $DB_SKU \
--tags ambiente=desafio \
$OUTPUT

#Obtendo private connection resource id:
echo "Obtendo private connection resource id"
PRIVATE_CONNECTION_RESOURCE_ID=$(az resource show -g $RG -n $DB_NAME --resource-type "Microsoft.DBforMariaDB/servers" --query "id" -o tsv)

#criando o private-endpoint para a $SN_DATA e mariadb
echo "criando o private-endpoint para a $SN_DATA e mariadb"
az network private-endpoint create \
--name $DATA_PRIVATE_ENDPOINT_NAME \
--resource-group $RG \
--vnet-name $VNET  \
--subnet $SN_DATA \
--private-connection-resource-id $PRIVATE_CONNECTION_RESOURCE_ID \
--group-id 'mariadbServer' \
--connection-name $PRIVATE_ENDPOINT_CONNECTION_NAME \
$OUTPUT

#Obtendo Network Interface Id
echo "Obtendo Network Interface Id"
NETWORK_INTERFACE_ID=$(az network private-endpoint show --name $DATA_PRIVATE_ENDPOINT_NAME --resource-group $RG --query 'networkInterfaces[0].id' -o tsv)

#Obtendo o private ip da database
echo "Obtendo o private ip da database"
DB_PRIVATE_IP=$(az resource show --ids $NETWORK_INTERFACE_ID --api-version 2019-04-01 --query 'properties.ipConfigurations[].properties.privateIPAddress' -o tsv)

#Adicionando a entrada no DNS: $DB_NAME $DB_PRIVATE_IP
echo "Adicionando a entrada no DNS: $DB_NAME $DB_PRIVATE_IP" 
az network private-dns record-set a create \
--name $DB_NAME \
--zone-name $DNS_ZONE \
--resource-group $RG \
$OUTPUT

az network private-dns record-set a add-record \
--record-set-name $DB_NAME \
--zone-name $DNS_ZONE \
--resource-group $RG \
-a $DB_PRIVATE_IP \
$OUTPUT

#RTE
echo "atualizando tabela de hosts"
sudo cp -p /etc/hosts /etc/hosts.bak
az network public-ip list -o table | tail -2 | awk '{print $4, $1, $1".private.desafiocbo.com"}' > hosts.tmp
cat hosts.tmp | sudo tee -a /etc/hosts

#Criando o public IP para o VNG
az network public-ip create \
-n $VIRTUAL_NETWORK_GW_PIP \
-g $RG \
--allocation-method 'Dynamic' \
--tags $TAGS \
-o table --verbose

#Criando o VNG
az network vnet-gateway create \
-n $VIRTUAL_NETWORK_GW_NAME \
-l $VIRTUAL_NETWORK_GW_REGION \
--public-ip-address $VIRTUAL_NETWORK_GW_PIP \
-g $RG \
--vnet 'vnet-desafiocbo' \
--gateway-type 'Vpn' \
--sku 'VpnGw1' \
--vpn-type 'RouteBased' \
--tags $TAGS \
-o table --verbose

#Da um tempo pro azure liberar meu ip
sleep 10 

VNG_PIP=$(az network public-ip show -g $RG -n $VIRTUAL_NETWORK_GW_PIP --query "ipAddress" -o tsv)

./deploy-infra-aws.sh $VNG_PIP
