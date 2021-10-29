#!/bin/bash

VPC_CIDR='10.20.0.0/16'
VPC_ID=$(aws ec2 describe-vpcs --filters Name=cidr,Values=$VPC_CIDR --output text | grep ^VPCS | awk '{print $NF}')
VPN_GW_ID=$(aws ec2 describe-vpn-gateways --output text | grep available | awk '{print $NF}')
CUSTOMER_GW_ID=$(aws ec2 describe-customer-gateways --output text | grep 'available' | awk '{print $3}')
VPN_ID=$(aws ec2 describe-vpn-connections --output text | grep "available" | grep vpn | awk '{print $5}')

#Delete vpn connection
echo "Delete vpn connection"
aws ec2 delete-vpn-connection \
--vpn-connection-id $VPN_ID

#Detach vpn gateway
echo "Detach vpn gateway"
aws ec2 detach-vpn-gateway \
--vpc-id $VPC_ID \
--vpn-gateway-id $VPN_GW_ID

#Delete vpn gateway
echo "Delete vpn gateway"
aws ec2 delete-vpn-gateway \
--vpn-gateway-id $VPN_GW_ID

#Delete customer gateway
echo "Delete customer gateway"
aws ec2 delete-customer-gateway \
--customer-gateway-id $CUSTOMER_GW_ID

#delete subnets
echo "delete subnets"
for subnet in $(aws ec2 describe-subnets --filters Name=vpc-id,Values=$VPC_ID --output text | awk '{print $13}');
    do
        aws ec2 delete-subnet --subnet-id $subnet;
    done

#Delete vpc
echo "Delete vpc"
aws ec2 delete-vpc \
--vpc-id $VPC_ID
