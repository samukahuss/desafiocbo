#!/bin/bash

#Destruindo o resource group
echo "Destruindo o resource group"
az group delete -g rg-desafio --yes -o table --verbose
