#!/bin/bash

# ============================================================================
# AIFOCUS SWARM - DEPLOY AUTOMÁTICO
# Script de deploy rápido para aifocus.dev
# ============================================================================

# Cores para output
verde="\033[32m"
amarelo="\033[33m"
vermelho="\033[31m"
azul="\033[34m"
magenta="\033[35m"
ciano="\033[36m"
branco="\033[37m"
reset="\033[0m"

clear
echo -e "$ciano======================================================================================================"
echo -e "  🚀 AIFOCUS SWARM - DEPLOY AUTOMÁTICO"
echo -e "  Infraestrutura Enterprise para aifocus.dev"
echo -e "======================================================================================================$reset"
echo ""

# Verificar se estamos no diretório correto
if [ ! -f "terraform.tfvars" ]; then
    echo -e "$vermelho ❌ Arquivo terraform.tfvars não encontrado! $reset"
    echo -e "$amarelo Execute este script do diretório correto. $reset"
    exit 1
fi

echo -e "$verde ✅ Arquivo de configuração encontrado! $reset"
echo ""

# Mostrar configuração
echo -e "$amarelo 📋 CONFIGURAÇÃO DO DEPLOY: $reset"
echo -e "$branco   Domínio: aifocus.dev $reset"
echo -e "$branco   Managers: 3x cx31 $reset"
echo -e "$branco   Workers: 2x cx21 $reset"
echo -e "$branco   Load Balancer: Sim $reset"
echo -e "$branco   DNS Automático: Cloudflare $reset"
echo -e "$branco   Custo Estimado: €71/mês $reset"
echo ""

echo -e "$amarelo 🌐 SUBDOMÍNIOS QUE SERÃO CRIADOS: $reset"
echo -e "$branco   ✅ portainer.aifocus.dev    # Gerenciamento Docker $reset"
echo -e "$branco   ✅ traefik.aifocus.dev      # Load Balancer $reset"
echo -e "$branco   ✅ grafana.aifocus.dev      # Dashboards $reset"
echo -e "$branco   ✅ prometheus.aifocus.dev   # Métricas $reset"
echo -e "$branco   ✅ chat.aifocus.dev         # Chatwoot $reset"
echo -e "$branco   ✅ evolution.aifocus.dev    # WhatsApp API $reset"
echo -e "$branco   ✅ uptime.aifocus.dev       # Monitoramento $reset"
echo ""

read -p "$(echo -e $amarelo"Deseja continuar com o deploy? (y/n): "$reset)" confirma

if [ "$confirma" != "y" ] && [ "$confirma" != "Y" ]; then
    echo -e "$amarelo Deploy cancelado. $reset"
    exit 0
fi

echo ""
echo -e "$verde 🚀 INICIANDO DEPLOY DA INFRAESTRUTURA... $reset"
echo ""

# Verificar/Instalar Terraform
if ! command -v terraform &> /dev/null; then
    echo -e "$amarelo 📥 Instalando Terraform... $reset"
    
    # Detectar sistema operacional
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)
    
    case $ARCH in
        x86_64) ARCH="amd64" ;;
        aarch64) ARCH="arm64" ;;
        arm64) ARCH="arm64" ;;
    esac
    
    # Download e instalação
    wget -q "https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_${OS}_${ARCH}.zip"
    unzip -q "terraform_1.6.6_${OS}_${ARCH}.zip"
    sudo mv terraform /usr/local/bin/
    rm "terraform_1.6.6_${OS}_${ARCH}.zip"
    
    echo -e "$verde ✅ Terraform instalado! $reset"
fi

# Verificar versão do Terraform
TERRAFORM_VERSION=$(terraform version -json | jq -r '.terraform_version' 2>/dev/null || terraform version | head -1 | cut -d' ' -f2 | cut -d'v' -f2)
echo -e "$azul ℹ️  Terraform versão: $TERRAFORM_VERSION $reset"
echo ""

# Passo 1: Terraform Init
echo -e "$amarelo 🔄 [1/4] Inicializando Terraform... $reset"
if terraform init; then
    echo -e "$verde ✅ Terraform inicializado! $reset"
else
    echo -e "$vermelho ❌ Erro ao inicializar Terraform! $reset"
    exit 1
fi
echo ""

# Passo 2: Terraform Plan
echo -e "$amarelo 📋 [2/4] Criando plano de execução... $reset"
if terraform plan -out=tfplan; then
    echo -e "$verde ✅ Plano criado com sucesso! $reset"
else
    echo -e "$vermelho ❌ Erro ao criar plano! $reset"
    exit 1
fi
echo ""

# Passo 3: Terraform Apply
echo -e "$amarelo 🏗️  [3/4] Aplicando infraestrutura... $reset"
echo -e "$azul ⏱️  Isso pode levar 8-12 minutos... $reset"
echo ""

if terraform apply tfplan; then
    echo -e "$verde ✅ Infraestrutura criada com sucesso! $reset"
else
    echo -e "$vermelho ❌ Erro ao aplicar infraestrutura! $reset"
    exit 1
fi
echo ""

# Passo 4: Coletar Outputs
echo -e "$amarelo 📄 [4/4] Coletando informações... $reset"
terraform output > terraform-outputs.txt

echo ""
echo -e "$ciano======================================================================================================$reset"
echo -e "$verde 🎉 DEPLOY CONCLUÍDO COM SUCESSO! $reset"
echo -e "$ciano======================================================================================================$reset"
echo ""

echo -e "$amarelo 📋 PRÓXIMOS PASSOS: $reset"
echo -e "$branco   1. ⏱️  Aguarde 5-10 minutos para configuração completa dos servidores $reset"
echo -e "$branco   2. 🌐 Teste os acessos abaixo $reset"
echo -e "$branco   3. 🔐 Configure senhas nos primeiros acessos $reset"
echo ""

echo -e "$amarelo 🌐 ACESSOS DISPONÍVEIS: $reset"
echo -e "$branco   Portainer:   https://portainer.aifocus.dev $reset"
echo -e "$branco   Traefik:     https://traefik.aifocus.dev $reset"  
echo -e "$branco   Grafana:     https://grafana.aifocus.dev $reset"
echo -e "$branco   Prometheus:  https://prometheus.aifocus.dev $reset"
echo ""

echo -e "$amarelo 📊 INFORMAÇÕES TÉCNICAS: $reset"
echo -e "$branco   Outputs salvos em: terraform-outputs.txt $reset"
echo -e "$branco   Estado Terraform: terraform.tfstate $reset"
echo ""

echo -e "$amarelo 🔧 COMANDOS ÚTEIS: $reset"
echo -e "$branco   Ver servidores: terraform output $reset"
echo -e "$branco   Destruir tudo: terraform destroy $reset"
echo -e "$branco   Logs:          tail -f /var/log/cloud-init-output.log $reset"
echo ""

echo -e "$amarelo ⚠️  LEMBRETE DE SEGURANÇA: $reset"
echo -e "$branco   Regenere as credenciais da API após o setup por segurança! $reset"
echo ""

echo -e "$verde 🚀 SUA INFRAESTRUTURA ENTERPRISE ESTÁ PRONTA! $reset"
echo ""

# Mostrar IPs dos servidores
if command -v jq &> /dev/null; then
    echo -e "$amarelo 🌐 IPs DOS SERVIDORES: $reset"
    terraform output -json | jq -r '
        if .manager_ips.value then
            (.manager_ips.value[] | "  Manager: \(.)"),
            (.worker_ips.value[]? | "  Worker:  \(.)")
        else
            "  Verifique: terraform output"
        end'
    echo ""
fi

echo -e "$azul Pressione ENTER para finalizar... $reset"
read -r 