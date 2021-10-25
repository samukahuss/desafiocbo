# Desafio CBO

## Tasks
1) Cloud Provider 1
  * Aplicacao 1 : backend rest hipotético, em qualquer linguagem, com scalling automático em caso de aumento de requisições no mesmo. Poderá ser utilizado instância de máquina virtual, container ou outra solução de escolha do candidato.
  * Aplicacao 2 : Frontend em qualquer linguagem hospedado em duas instâncias de máquinas virtuais, e acessado(pela internet) através de um balanceador de carga, que deverá ter redundância de rede por zona de disponibilidade.
  * Ambas as aplicações(Backend e Frotend) devem responder pelo mesmo DNS, porém com contextos (paths) distintos.
  * Banco de dados: Criar um banco de dados qualquer ao qual o acesso deverá ser feito através de outro nome de DNS, porém do mesmo domínio das aplicações. O acesso ao banco de dados deverá ser restrito somente as duas aplicações acima. Poderá ser utilizado qualquer serviço de banco de dados na nuvem (instância de máquina, RDS e etc).

2) Cloud Provider 2
  * Configurar comunicação privada(exemplo: VPN) entre o cloud provider 1 e o 2.
  * Subir um servidor que responda no mesmo domínio das aplicações do outro cloud provider. Esse servidor terá por finalidade execução de testes.

Observação: Caso o participante opte, encorajamos subir as aplicações em um cloud provider e o banco no outro cloud provider. Reforçamos que isso não é um requisito.

## Requisitos:
- Ambiente Cloud: AWS, Azure ou GCP
- Load Balancer
- Documentação detalhada, contendo no mínimo:
  - Diagrama com a arquitetura da solução
  - Código utilizado para criação do projeto (ex.: Terraform, python e etc)
  - Custo estimado da solução entregue
  - Outras documentações que o participante julgar importante
  - Disponibilizar em um repositório público (ex.: GitHub)

## Tecnologias sugeridas:
Pode-se fazer uso das seguintes tecnologias:
* Docker
* Terraform
* Ansible
* Kubernetes (Gerenciado ou nao)
* Instancias de máquinas virtuais
* Servicos gerenciados de hospedagem de aplicações (Azure App Service , AWS Beanstalk)
* Banco de dados Gerenciado ou não
OBS: outras ferramentas/soluções também são bem-vindas, desde que funcione de forma simples e eficiente.

## Será avaliado:
- Percentual de entrega
- Uso de ferramentas de automatização
- Técnicas e boas práticas de segurança
- Organização
- Gestão de custos da infraestrutura/projeto
- Qualidade da documentação
- Criatividade
- Roadmap de futuras melhorias

# Descrição do projeto
Este projeto foi criado com intuito de apresentar uma solução possível para o desafio proposto pelo CBO. Está não é a única solução e não tem como objetivo ser parametro para correção de outras soluções.

A criação dos recursos na azure foi feita através do [az cli](https://docs.microsoft.com/pt-br/cli/azure/install-azure-cli). A criação dos recursos na aws foi feita através do [aws cli](https://aws.amazon.com/pt/cli/). Todos os recursos são criados pelo script shell [deploy-infra-azure.sh](/repos/github/desafiocbo/src/deploy-infra-azure.sh)

Foi criada uma aplicação simples de backend e dispobinilizada no repositório [desafiocbo-app](https://github.com/samukahuss/desafiocbo-app)

# Diagrama da solução
![alt text](https://github.com/samukahuss/desafiocbo/blob/main/img/desafiocbo_diagrama.png)

# Pré-requisitos
- [Uma conta válida na Azure](https://azure.microsoft.com/en-us/free/search/?&ef_id=Cj0KCQjwiNSLBhCPARIsAKNS4_dbPmDMDyKEeDlQ-C6DP_VcH8s3pds5Xl8VM2pol9QK3V3I_x4ZWBQaArgNEALw_wcB:G:s&OCID=AID2200154_SEM_Cj0KCQjwiNSLBhCPARIsAKNS4_dbPmDMDyKEeDlQ-C6DP_VcH8s3pds5Xl8VM2pol9QK3V3I_x4ZWBQaArgNEALw_wcB:G:s&gclid=Cj0KCQjwiNSLBhCPARIsAKNS4_dbPmDMDyKEeDlQ-C6DP_VcH8s3pds5Xl8VM2pol9QK3V3I_x4ZWBQaArgNEALw_wcB)
- [Uma conta válida na AWS](https://aws.amazon.com/free/?trk=ps_a134p0000078Pq7AAE&trkCampaign=acq_paid_search_brand&sc_channel=ps&sc_campaign=acquisition_BR&sc_publisher=google&sc_category=core-main&sc_country=BR&sc_geo=LATAM&sc_outcome=acq&sc_detail=aws&sc_content=Brand%20Core%20AWS_p&sc_matchtype=p&sc_segment=507891927296&sc_medium=ACQ-P|PS-GO|Brand|Desktop|SU|Core-Main|Core|BR|EN|Text|xx|PH&s_kwcid=AL!4422!3!507891927296!p!!g!!aws&ef_id=Cj0KCQjwiNSLBhCPARIsAKNS4_dE7lWRS7j7iQL2OrqiakDzahLQma4SDysPMQKeZmIIP0gHs6YNCpEaArXbEALw_wcB:G:s&s_kwcid=AL!4422!3!507891927296!p!!g!!aws&all-free-tier.sort-by=item.additionalFields.SortRank&all-free-tier.sort-order=asc&awsf.Free%20Tier%20Types=*all&awsf.Free%20Tier%20Categories=*all)
- [bash](https://pt.wikipedia.org/wiki/Bash)
- [az cli](https://docs.microsoft.com/pt-br/cli/azure/install-azure-cli)
- [aws cli](https://aws.amazon.com/pt/cli/)
- [desafiocbo-app](https://github.com/samukahuss/desafiocbo-app)
- Estação de trabalho deve ser linux.

# Instruções de execução

1) Faça o clone dos repositórios para sua estação de trabalho:
    * [desafiocbo](https://github.com/samukahuss/desafiocbo)
    * [desafiocbo-app](https://github.com/samukahuss/desafiocbo-app)

2) Abra o script [deploy-infra-azure.sh](/repos/github/desafiocbo/src/deploy-infra-azure.sh) e na linha 85 e atualize o valor da variável BACK_APP_PATH com o path onde o repositório [desafiocbo-app](https://github.com/samukahuss/desafiocbo-app) foi clonado.
```
#App service 
BACK_APP_PATH='/repos/github/desafiocbo-app'

```
3) Abra o terminal e faça o login em sua conta azure com o [az login](https://docs.microsoft.com/pt-br/cli/azure/authenticate-azure-cli).
4) [Configure](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) o [aws cli](https://aws.amazon.com/pt/cli/) de acordo com suas credenciais.
5) Vá no path onde o [desafiocbo](https://github.com/samukahuss/desafiocbo) foi clonado em [src](/repos/github/desafiocbo/src) e execute o script [deploy-infra-azure.sh](/repos/github/desafiocbo/src/deploy-infra-azure.sh). 
```
samuel@NOT-01486:/repos/github/desafiocbo/src$ ./deploy-infra-azure.sh

```
Todo o processo de deploy pode demorar mais de 70 minutos.

# Deleção do ambiente

1) Vá no path onde o [desafiocbo](https://github.com/samukahuss/desafiocbo) foi clonado em [src](/repos/github/desafiocbo/src) e execute o script [destroy-infra-azure.sh](/repos/github/desafiocbo/src/destroy-infra-azure.sh)
```
samuel@NOT-01486:/repos/github/desafiocbo/src$ ./destroy-infra-azure.sh

```