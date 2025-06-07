# ============================================================================
# AIFOCUS SWARM - DEPLOY AUTOMÁTICO (PowerShell)
# Script de deploy para Windows PowerShell
# ============================================================================

# Configurar cores
$Host.UI.RawUI.WindowTitle = "AiFocus Swarm Deploy"

# Função para escrever com cores
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    } else {
        $input | Write-Output
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

Clear-Host
Write-ColorOutput Cyan @"
======================================================================================================
  🚀 AIFOCUS SWARM - DEPLOY AUTOMÁTICO
  Infraestrutura Enterprise para aifocus.dev
======================================================================================================
"@
Write-Host ""

# Verificar se arquivo terraform.tfvars existe
if (-Not (Test-Path "terraform.tfvars")) {
    Write-ColorOutput Red "❌ Arquivo terraform.tfvars não encontrado!"
    Write-ColorOutput Yellow "Execute este script do diretório correto."
    exit 1
}

Write-ColorOutput Green "✅ Arquivo de configuração encontrado!"
Write-Host ""

# Mostrar configuração
Write-ColorOutput Yellow "📋 CONFIGURAÇÃO DO DEPLOY:"
Write-Host "   Domínio: aifocus.dev"
Write-Host "   Managers: 3x cx31"
Write-Host "   Workers: 2x cx21"
Write-Host "   Load Balancer: Sim"
Write-Host "   DNS Automático: Cloudflare"
Write-Host "   Custo Estimado: €71/mês"
Write-Host ""

Write-ColorOutput Yellow "🌐 SUBDOMÍNIOS QUE SERÃO CRIADOS:"
Write-Host "   ✅ portainer.aifocus.dev    # Gerenciamento Docker"
Write-Host "   ✅ traefik.aifocus.dev      # Load Balancer"
Write-Host "   ✅ grafana.aifocus.dev      # Dashboards"
Write-Host "   ✅ prometheus.aifocus.dev   # Métricas"
Write-Host "   ✅ chat.aifocus.dev         # Chatwoot"
Write-Host "   ✅ evolution.aifocus.dev    # WhatsApp API"
Write-Host "   ✅ uptime.aifocus.dev       # Monitoramento"
Write-Host ""

$confirma = Read-Host "Deseja continuar com o deploy? (y/n)"

if ($confirma -ne "y" -and $confirma -ne "Y") {
    Write-ColorOutput Yellow "Deploy cancelado."
    exit 0
}

Write-Host ""
Write-ColorOutput Green "🚀 INICIANDO DEPLOY DA INFRAESTRUTURA..."
Write-Host ""

# Verificar se Terraform está instalado
$terraformInstalled = $false
try {
    $terraformVersion = terraform --version
    $terraformInstalled = $true
    Write-ColorOutput Blue "ℹ️  Terraform já instalado: $($terraformVersion.Split("`n")[0])"
} catch {
    Write-ColorOutput Yellow "📥 Terraform não encontrado. Instalando..."
    
    # Instalar Terraform via Chocolatey se disponível
    try {
        choco install terraform -y
        $terraformInstalled = $true
        Write-ColorOutput Green "✅ Terraform instalado via Chocolatey!"
    } catch {
        Write-ColorOutput Red "❌ Erro ao instalar Terraform."
        Write-ColorOutput Yellow "Por favor, instale manualmente:"
        Write-Host "1. Vá para: https://developer.hashicorp.com/terraform/downloads"
        Write-Host "2. Baixe a versão para Windows"
        Write-Host "3. Extraia e adicione ao PATH"
        exit 1
    }
}

if (-not $terraformInstalled) {
    Write-ColorOutput Red "❌ Terraform não pôde ser instalado automaticamente."
    exit 1
}

Write-Host ""

# Passo 1: Terraform Init
Write-ColorOutput Yellow "🔄 [1/4] Inicializando Terraform..."
try {
    $initOutput = terraform init 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput Green "✅ Terraform inicializado!"
    } else {
        throw "Terraform init falhou"
    }
} catch {
    Write-ColorOutput Red "❌ Erro ao inicializar Terraform!"
    Write-Host $initOutput
    exit 1
}
Write-Host ""

# Passo 2: Terraform Plan
Write-ColorOutput Yellow "📋 [2/4] Criando plano de execução..."
try {
    $planOutput = terraform plan -out=tfplan 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput Green "✅ Plano criado com sucesso!"
    } else {
        throw "Terraform plan falhou"
    }
} catch {
    Write-ColorOutput Red "❌ Erro ao criar plano!"
    Write-Host $planOutput
    exit 1
}
Write-Host ""

# Passo 3: Terraform Apply
Write-ColorOutput Yellow "🏗️  [3/4] Aplicando infraestrutura..."
Write-ColorOutput Blue "⏱️  Isso pode levar 8-12 minutos..."
Write-Host ""

try {
    $applyOutput = terraform apply tfplan 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput Green "✅ Infraestrutura criada com sucesso!"
    } else {
        throw "Terraform apply falhou"
    }
} catch {
    Write-ColorOutput Red "❌ Erro ao aplicar infraestrutura!"
    Write-Host $applyOutput
    exit 1
}
Write-Host ""

# Passo 4: Coletar Outputs
Write-ColorOutput Yellow "📄 [4/4] Coletando informações..."
terraform output > terraform-outputs.txt

Write-Host ""
Write-ColorOutput Cyan @"
======================================================================================================
🎉 DEPLOY CONCLUÍDO COM SUCESSO!
======================================================================================================
"@
Write-Host ""

Write-ColorOutput Yellow "📋 PRÓXIMOS PASSOS:"
Write-Host "   1. ⏱️  Aguarde 5-10 minutos para configuração completa dos servidores"
Write-Host "   2. 🌐 Teste os acessos abaixo"
Write-Host "   3. 🔐 Configure senhas nos primeiros acessos"
Write-Host ""

Write-ColorOutput Yellow "🌐 ACESSOS DISPONÍVEIS:"
Write-Host "   Portainer:   https://portainer.aifocus.dev"
Write-Host "   Traefik:     https://traefik.aifocus.dev"
Write-Host "   Grafana:     https://grafana.aifocus.dev"
Write-Host "   Prometheus:  https://prometheus.aifocus.dev"
Write-Host ""

Write-ColorOutput Yellow "📊 INFORMAÇÕES TÉCNICAS:"
Write-Host "   Outputs salvos em: terraform-outputs.txt"
Write-Host "   Estado Terraform: terraform.tfstate"
Write-Host ""

Write-ColorOutput Yellow "🔧 COMANDOS ÚTEIS:"
Write-Host "   Ver servidores: terraform output"
Write-Host "   Destruir tudo: terraform destroy"
Write-Host ""

Write-ColorOutput Yellow "⚠️  LEMBRETE DE SEGURANÇA:"
Write-Host "   Regenere as credenciais da API após o setup por segurança!"
Write-Host ""

Write-ColorOutput Green "🚀 SUA INFRAESTRUTURA ENTERPRISE ESTÁ PRONTA!"
Write-Host ""

# Mostrar outputs se disponível
if (Test-Path "terraform-outputs.txt") {
    Write-ColorOutput Yellow "📋 OUTPUTS DO TERRAFORM:"
    Get-Content "terraform-outputs.txt"
    Write-Host ""
}

Write-ColorOutput Blue "Pressione ENTER para finalizar..."
Read-Host 