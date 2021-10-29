#!/bin/bash

#Variaveis
VPC_CIDR='10.20.0.0/16'
SUBNET_VPN='10.20.0.0/24'
SUBNET_MGMT='10.20.1.0/24'
AZR_VPN_GW_PIP=$1
########################

#Criando a VPC
aws ec2 create-vpc \
--cidr-block $VPC_CIDR

#Obtendo o ID da VPC
VPC_ID=$(aws ec2 describe-vpcs --filters Name=cidr,Values=$VPC_CIDR --output text | grep ^VPCS | awk '{print $NF}')

#Criando a subnet da VPN
aws ec2 create-subnet \
--vpc-id $VPC_ID \
--cidr-block $SUBNET_VPN

#Criando a subnet de MGMT
aws ec2 create-subnet \
--vpc-id $VPC_ID \
--cidr-block $SUBNET_MGMT

aws ec2 create-customer-gateway \
--public-ip $AZR_VPN_GW_PIP \
--type ipsec.1 \
--bgp-asn 65000 \
--device-name 'cg-desafiocbo' 

aws ec2 create-vpn-gateway \
--type ipsec.1 

VPN_ID=$(aws ec2 describe-vpn-gateways --output text | awk '{print $NF}')

aws ec2 attach-vpn-gateway \
--vpc-id $VPC_ID \
--vpn-gateway-id $VPN_ID

#CUSTOMER_GW_ID=$(aws ec2 describe-customer-gateways --output text | grep 'available' | awk '{print $3}')