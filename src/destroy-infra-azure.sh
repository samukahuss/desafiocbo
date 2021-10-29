#!/bin/bash

#Restaurando tabela de hosts
sudo cp -p /etc/hosts.bak /etc/hosts

./destroy-infra-aws.sh &

#Destruindo o resource group
echo "Destruindo o resource group"
az group delete -g rg-desafiocbo --yes -o table --verbose
