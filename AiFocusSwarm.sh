#!/bin/bash

## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                    AIFOCUS COMPANY SWARM                                    ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

## Cores
amarelo="\e[33m"
verde="\e[32m"
branco="\e[97m"
bege="\e[93m"
vermelho="\e[91m"
azul="\e[34m"
ciano="\e[36m"
magenta="\e[35m"
reset="\e[0m"

## Versão
versao="3.0.0"

## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                    AIFOCUS COMPANY SWARM                                    ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

nome_aifocus(){
clear
echo ""
echo -e "$ciano===================================================================================================$reset"
echo -e "$ciano=                                                                                                 $ciano=$reset"
echo -e "$ciano=           $branco █████╗ ██╗    ███████╗ ██████╗  ██████╗██╗   ██╗███████╗                        $ciano=$reset"
echo -e "$ciano=           $branco██╔══██╗██║    ██╔════╝██╔═══██╗██╔════╝██║   ██║██╔════╝                        $ciano=$reset"
echo -e "$ciano=           $branco███████║██║    █████╗  ██║   ██║██║     ██║   ██║███████╗                        $ciano=$reset"
echo -e "$ciano=           $branco██╔══██║██║    ██╔══╝  ██║   ██║██║     ██║   ██║╚════██║                        $ciano=$reset"
echo -e "$ciano=           $branco██║  ██║██║    ██║     ╚██████╔╝╚██████╗╚██████╔╝███████║                        $ciano=$reset"
echo -e "$ciano=           $branco╚═╝  ╚═╝╚═╝    ╚═╝      ╚═════╝  ╚═════╝ ╚═════╝ ╚══════╝                        $ciano=$reset"
echo -e "$ciano=                                                                                                 $ciano=$reset"
echo -e "$ciano=                    $amarelo ██████╗ ██████╗ ███╗   ███╗██████╗  █████╗ ███╗   ██╗██╗   ██╗             $ciano=$reset"
echo -e "$ciano=                    $amarelo██╔════╝██╔═══██╗████╗ ████║██╔══██╗██╔══██╗████╗  ██║╚██╗ ██╔╝             $ciano=$reset"
echo -e "$ciano=                    $amarelo██║     ██║   ██║██╔████╔██║██████╔╝███████║██╔██╗ ██║ ╚████╔╝              $ciano=$reset"
echo -e "$ciano=                    $amarelo██║     ██║   ██║██║╚██╔╝██║██╔═══╝ ██╔══██║██║╚██╗██║  ╚██╔╝               $ciano=$reset"
echo -e "$ciano=                    $amarelo╚██████╗╚██████╔╝██║ ╚═╝ ██║██║     ██║  ██║██║ ╚████║   ██║                $ciano=$reset"
echo -e "$ciano=                    $amarelo ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝                $ciano=$reset"
echo -e "$ciano=                                                                                                 $ciano=$reset"
echo -e "$ciano=                                  $verde DOCKER SWARM EDITION                                       $ciano=$reset"
echo -e "$ciano=                                         v. $versao                                               $ciano=$reset"
echo -e "$ciano===================================================================================================$reset"
echo ""
echo ""
}

menu_principal(){
    nome_aifocus
    echo -e "$branco Selecione a opção desejada:$reset"
    echo ""
    echo -e "$amarelo [1]$reset - 🏗️  Configurar Infraestrutura Swarm (Terraform + Hetzner)"
    echo -e "$amarelo [2]$reset - 🐳  Gerenciar Docker Swarm"
    echo -e "$amarelo [3]$reset - 📊  Instalar Stacks de Monitoramento"
    echo -e "$amarelo [4]$reset - 💬  Instalar Chatwoot + Evolution API"
    echo -e "$amarelo [5]$reset - 🤖  Instalar N8N + Typebot"
    echo -e "$amarelo [6]$reset - 🔗  Instalar Traefik + Portainer"
    echo -e "$amarelo [7]$reset - 💾  Instalar Bancos de Dados"
    echo -e "$amarelo [8]$reset - 🛠️  Ferramentas de Desenvolvimento"
    echo -e "$amarelo [9]$reset - 🔧  Utilitários e Serviços"
    echo -e "$amarelo [10]$reset - 📈 Dashboard Completo (Todas as Stacks)"
    echo -e "$amarelo [11]$reset - 🔄 Backup e Restore"
    echo -e "$amarelo [12]$reset - ⚙️  Configurações Avançadas"
    echo -e "$amarelo [0]$reset - ❌ Sair"
    echo ""
    echo -e "$ciano==================================================================================================$reset"
    echo ""
    read -p "Digite sua opção [0-12]: " opcao
    case $opcao in
        1) menu_infraestrutura ;;
        2) menu_swarm ;;
        3) menu_monitoramento ;;
        4) menu_chat_automation ;;
        5) menu_automation_tools ;;
        6) menu_proxy_management ;;
        7) menu_databases ;;
        8) menu_development ;;
        9) menu_utilities ;;
        10) instalar_dashboard_completo ;;
        11) menu_backup ;;
        12) menu_configuracoes ;;
        0) echo "Saindo..."; exit 0 ;;
        *) echo "Opção inválida!"; sleep 2; menu_principal ;;
    esac
}

menu_infraestrutura(){
    clear
    echo ""
    echo -e "$ciano===================================================================================================$reset"
    echo -e "$ciano=                                                                                                 $ciano=$reset"
    echo -e "$ciano=     $branco ██╗███╗   ██╗███████╗██████╗  █████╗ ███████╗████████╗██████╗ ██╗   ██╗ ██████╗████████╗   $ciano=$reset"
    echo -e "$ciano=     $branco ██║████╗  ██║██╔════╝██╔══██╗██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██║   ██║██╔════╝╚══██╔══╝   $ciano=$reset"
    echo -e "$ciano=     $branco ██║██╔██╗ ██║█████╗  ██████╔╝███████║███████╗   ██║   ██████╔╝██║   ██║██║        ██║      $ciano=$reset"
    echo -e "$ciano=     $branco ██║██║╚██╗██║██╔══╝  ██╔══██╗██╔══██║╚════██║   ██║   ██╔══██╗██║   ██║██║        ██║      $ciano=$reset"
    echo -e "$ciano=     $branco ██║██║ ╚████║██║     ██║  ██║██║  ██║███████║   ██║   ██║  ██║╚██████╔╝╚██████╗   ██║      $ciano=$reset"
    echo -e "$ciano=     $branco ╚═╝╚═╝  ╚═══╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝  ╚═════╝   ╚═╝      $ciano=$reset"
    echo -e "$ciano=                                                                                                 $ciano=$reset"
    echo -e "$ciano===================================================================================================$reset"
    echo ""
    echo -e "$branco Configuração de Infraestrutura:$reset"
    echo ""
    echo -e "$amarelo [1]$reset - 🏗️  Configurar Terraform + Hetzner Cloud"
    echo -e "$amarelo [2]$reset - 🌐  Configurar DNS e Domínios"
    echo -e "$amarelo [3]$reset - 🔒  Configurar SSL/TLS Automático"
    echo -e "$amarelo [4]$reset - 🖥️  Verificar Status dos Servidores"
    echo -e "$amarelo [5]$reset - 🔄  Expandir Cluster (Adicionar Nós)"
    echo -e "$amarelo [6]$reset - 📊  Monitorar Recursos da Infraestrutura"
    echo -e "$amarelo [0]$reset - ⬅️  Voltar ao Menu Principal"
    echo ""
    read -p "Digite sua opção [0-6]: " opcao
    case $opcao in
        1) configurar_terraform ;;
        2) configurar_dns ;;
        3) configurar_ssl ;;
        4) status_servidores ;;
        5) expandir_cluster ;;
        6) monitorar_recursos ;;
        0) menu_principal ;;
        *) echo "Opção inválida!"; sleep 2; menu_infraestrutura ;;
    esac
}

menu_swarm(){
    clear
    echo ""
    echo -e "$ciano===================================================================================================$reset"
    echo -e "$ciano=                                                                                                 $ciano=$reset"
    echo -e "$ciano=                      $branco ███████╗██╗    ██╗ █████╗ ██████╗ ███╗   ███╗                           $ciano=$reset"
    echo -e "$ciano=                      $branco ██╔════╝██║    ██║██╔══██╗██╔══██╗████╗ ████║                           $ciano=$reset"
    echo -e "$ciano=                      $branco ███████╗██║ █╗ ██║███████║██████╔╝██╔████╔██║                           $ciano=$reset"
    echo -e "$ciano=                      $branco ╚════██║██║███╗██║██╔══██║██╔══██╗██║╚██╔╝██║                           $ciano=$reset"
    echo -e "$ciano=                      $branco ███████║╚███╔███╔╝██║  ██║██║  ██║██║ ╚═╝ ██║                           $ciano=$reset"
    echo -e "$ciano=                      $branco ╚══════╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝                           $ciano=$reset"
    echo -e "$ciano=                                                                                                 $ciano=$reset"
    echo -e "$ciano===================================================================================================$reset"
    echo ""
    echo -e "$branco Gerenciamento Docker Swarm:$reset"
    echo ""
    echo -e "$amarelo [1]$reset - 🚀  Inicializar Docker Swarm"
    echo -e "$amarelo [2]$reset - 👥  Adicionar Worker Nodes"
    echo -e "$amarelo [3]$reset - 📊  Status do Cluster"
    echo -e "$amarelo [4]$reset - 🔄  Reiniciar Serviços"
    echo -e "$amarelo [5]$reset - 📋  Listar Stacks Ativas"
    echo -e "$amarelo [6]$reset - 🔧  Remover Stack"
    echo -e "$amarelo [7]$reset - 📈  Escalar Serviços"
    echo -e "$amarelo [8]$reset - 🛠️  Maintenance Mode"
    echo -e "$amarelo [0]$reset - ⬅️  Voltar ao Menu Principal"
    echo ""
    read -p "Digite sua opção [0-8]: " opcao
    case $opcao in
        1) inicializar_swarm ;;
        2) adicionar_workers ;;
        3) status_cluster ;;
        4) reiniciar_servicos ;;
        5) listar_stacks ;;
        6) remover_stack ;;
        7) escalar_servicos ;;
        8) maintenance_mode ;;
        0) menu_principal ;;
        *) echo "Opção inválida!"; sleep 2; menu_swarm ;;
    esac
}

menu_monitoramento(){
    clear
    echo ""
    echo -e "$verde===================================================================================================$reset"
    echo -e "$verde=                                    📊 MONITORAMENTO                                           =$reset"
    echo -e "$verde===================================================================================================$reset"
    echo ""
    echo -e "$branco Stacks de Monitoramento:$reset"
    echo ""
    echo -e "$amarelo [1]$reset - 📊  Instalar Grafana + Prometheus"
    echo -e "$amarelo [2]$reset - 📈  Instalar Uptimekuma"
    echo -e "$amarelo [3]$reset - 🔍  Instalar Elasticsearch + Kibana"
    echo -e "$amarelo [4]$reset - 📱  Instalar Ntfy (Notificações)"
    echo -e "$amarelo [5]$reset - 🚨  Configurar Alertas"
    echo -e "$amarelo [6]$reset - 📊  Dashboard Completo de Monitoramento"
    echo -e "$amarelo [0]$reset - ⬅️  Voltar ao Menu Principal"
    echo ""
    read -p "Digite sua opção [0-6]: " opcao
    case $opcao in
        1) instalar_grafana_prometheus ;;
        2) instalar_uptime_kuma ;;
        3) instalar_elastic_kibana ;;
        4) instalar_ntfy ;;
        5) configurar_alertas ;;
        6) dashboard_monitoramento ;;
        0) menu_principal ;;
        *) echo "Opção inválida!"; sleep 2; menu_monitoramento ;;
    esac
}

menu_chat_automation(){
    clear
    echo ""
    echo -e "$magenta===================================================================================================$reset"
    echo -e "$magenta=                               💬 CHAT & AUTOMAÇÃO                                            =$reset"
    echo -e "$magenta===================================================================================================$reset"
    echo ""
    echo -e "$branco Ferramentas de Chat e Automação:$reset"
    echo ""
    echo -e "$amarelo [1]$reset - 💬  Instalar Chatwoot"
    echo -e "$amarelo [2]$reset - 📱  Instalar Evolution API"
    echo -e "$amarelo [3]$reset - 🔗  Conectar Chatwoot + Evolution"
    echo -e "$amarelo [4]$reset - 🤖  Instalar Typebot"
    echo -e "$amarelo [5]$reset - 📞  Instalar Quepasa API"
    echo -e "$amarelo [6]$reset - 🎯  Instalar Wuzapi"
    echo -e "$amarelo [7]$reset - 📦  Stack Completa (Chatwoot + Evolution + Typebot)"
    echo -e "$amarelo [0]$reset - ⬅️  Voltar ao Menu Principal"
    echo ""
    read -p "Digite sua opção [0-7]: " opcao
    case $opcao in
        1) instalar_chatwoot ;;
        2) instalar_evolution_api ;;
        3) conectar_chatwoot_evolution ;;
        4) instalar_typebot ;;
        5) instalar_quepasa ;;
        6) instalar_wuzapi ;;
        7) stack_chat_completa ;;
        0) menu_principal ;;
        *) echo "Opção inválida!"; sleep 2; menu_chat_automation ;;
    esac
}

## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                    FUNÇÕES PRINCIPAIS                                       ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

configurar_terraform(){
    clear
    echo -e "$ciano===================================================================================================$reset"
    echo -e "$verde 🏗️ CONFIGURANDO TERRAFORM PARA INFRAESTRUTURA $reset"
    echo -e "$ciano===================================================================================================$reset"
    echo ""
    
    # Verificar se Terraform está instalado
    if ! command -v terraform &> /dev/null; then
        echo -e "$amarelo 📥 Instalando Terraform... $reset"
        
        # Instalar Terraform
        wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt update && sudo apt install terraform -y
        
        echo -e "$verde ✅ Terraform instalado! $reset"
        echo ""
    fi
    
    # Verificar se há configuração existente
    if [ -f "terraform.tfvars" ]; then
        echo -e "$amarelo ⚠️  Configuração existente encontrada! $reset"
        echo ""
        cat terraform.tfvars
        echo ""
        read -p "Deseja reconfigurar? (y/n): " reconfig
        
        if [ "$reconfig" != "y" ] && [ "$reconfig" != "Y" ]; then
            menu_infraestrutura
            return
        fi
    fi
    
    echo -e "$amarelo 🔧 Vamos configurar sua infraestrutura: $reset"
    echo ""
    
    # Coletar informações
    read -p "Hetzner Cloud API Token: " hetzner_token
    read -p "Seu domínio (ex: empresa.com): " dominio
    read -p "Seu email para SSL: " email_ssl
    read -p "Nome da chave SSH no Hetzner: " ssh_key_name
    
    echo ""
    echo -e "$amarelo Configuração de nós: $reset"
    read -p "Quantos managers? (1, 3, 5 ou 7) [3]: " manager_count
    manager_count=${manager_count:-3}
    
    read -p "Quantos workers? [2]: " worker_count
    worker_count=${worker_count:-2}
    
    read -p "Tipo de servidor para managers (cx21, cx31, cx41) [cx31]: " manager_type
    manager_type=${manager_type:-cx31}
    
    read -p "Tipo de servidor para workers (cx11, cx21, cx31) [cx21]: " worker_type
    worker_type=${worker_type:-cx21}
    
    echo ""
    read -p "Habilitar Load Balancer? (y/n) [y]: " enable_lb
    enable_lb=${enable_lb:-y}
    
    read -p "Habilitar volumes extras? (y/n) [y]: " enable_volumes
    enable_volumes=${enable_volumes:-y}
    
    read -p "Token do Cloudflare (opcional para DNS automático): " cloudflare_token
    
    # Criar arquivo terraform.tfvars
    cat > terraform.tfvars << EOF
# ============================================================================
# CONFIGURAÇÃO DA INFRAESTRUTURA AIFOCUS SWARM
# Gerado automaticamente em $(date)
# ============================================================================

# Credenciais obrigatórias
hetzner_token = "$hetzner_token"
domain = "$dominio"
email = "$email_ssl"
ssh_key_name = "$ssh_key_name"

# Configuração dos servidores
manager_count = $manager_count
worker_count = $worker_count
manager_server_type = "$manager_type"
worker_server_type = "$worker_type"

# Features
enable_load_balancer = $([ "$enable_lb" = "y" ] && echo "true" || echo "false")
enable_volumes = $([ "$enable_volumes" = "y" ] && echo "true" || echo "false")

# Cloudflare (opcional)
$([ ! -z "$cloudflare_token" ] && echo "cloudflare_token = \"$cloudflare_token\"" || echo "# cloudflare_token = \"\"")

# Configurações de rede
network_ip_range = "10.0.0.0/16"
subnet_ip_range = "10.0.1.0/24"

# Configurações de segurança
allowed_ips = ["0.0.0.0/0"]
enable_firewall = true

# Features avançadas
enable_monitoring = true
enable_backups = true
volume_size = 50

# Tags
tags = {
  "Environment" = "Production"
  "Project"     = "AiFocus-Swarm"
  "ManagedBy"   = "Terraform"
  "Owner"       = "$(whoami)"
}
EOF
    
    echo -e "$verde ✅ Configuração salva em terraform.tfvars! $reset"
    echo ""
    
    # Mostrar custos estimados
    echo -e "$amarelo 💰 CUSTO ESTIMADO MENSAL (EUR): $reset"
    
    # Calcular custos básicos
    case $manager_type in
        "cx11") manager_cost=3 ;;
        "cx21") manager_cost=6 ;;
        "cx31") manager_cost=15 ;;
        "cx41") manager_cost=30 ;;
        *) manager_cost=15 ;;
    esac
    
    case $worker_type in
        "cx11") worker_cost=3 ;;
        "cx21") worker_cost=6 ;;
        "cx31") worker_cost=15 ;;
        "cx41") worker_cost=30 ;;
        *) worker_cost=6 ;;
    esac
    
    total_servers=$((manager_cost * manager_count + worker_cost * worker_count))
    lb_cost=$([ "$enable_lb" = "y" ] && echo "6" || echo "0")
    volumes_cost=$([ "$enable_volumes" = "y" ] && echo $((worker_count * 2)) || echo "0")
    
    total_cost=$((total_servers + lb_cost + volumes_cost))
    
    echo "  - $manager_count Managers ($manager_type): €$((manager_cost * manager_count))"
    echo "  - $worker_count Workers ($worker_type): €$((worker_cost * worker_count))"
    [ "$enable_lb" = "y" ] && echo "  - Load Balancer: €$lb_cost"
    [ "$enable_volumes" = "y" ] && echo "  - Volumes: €$volumes_cost"
    echo "  ---------------------------------"
    echo "  TOTAL ESTIMADO: €$total_cost/mês"
    echo ""
    
    read -p "Deseja aplicar a infraestrutura agora? (y/n): " aplicar
    
    if [ "$aplicar" = "y" ] || [ "$aplicar" = "Y" ]; then
        echo -e "$amarelo 🚀 Inicializando Terraform... $reset"
        terraform init
        
        echo -e "$amarelo 📋 Mostrando plano de execução... $reset"
        terraform plan
        
        echo ""
        read -p "Confirma a criação da infraestrutura? (y/n): " confirma
        
        if [ "$confirma" = "y" ] || [ "$confirma" = "Y" ]; then
            echo -e "$amarelo 🏗️ Criando infraestrutura... $reset"
            terraform apply -auto-approve
            
            if [ $? -eq 0 ]; then
                echo -e "$verde ✅ Infraestrutura criada com sucesso! $reset"
                echo ""
                echo -e "$amarelo 📋 PRÓXIMOS PASSOS: $reset"
                echo "1. Aguarde a configuração automática dos servidores (5-10 min)"
                echo "2. Use 'Gerenciar Swarm' para verificar status"
                echo "3. Deploy dos stacks de aplicação"
                
                # Salvar outputs importantes
                terraform output > /opt/aifocus/terraform-outputs.txt
                
                echo ""
                echo -e "$verde 📄 Outputs salvos em: /opt/aifocus/terraform-outputs.txt $reset"
            else
                echo -e "$vermelho ❌ Erro ao criar infraestrutura! $reset"
            fi
        fi
    fi
    
    echo ""
    read -p "Pressione ENTER para continuar..."
    menu_infraestrutura
}

inicializar_swarm(){
    clear
    echo -e "$ciano===================================================================================================$reset"
    echo -e "$verde 🚀 INICIALIZANDO DOCKER SWARM $reset"
    echo -e "$ciano===================================================================================================$reset"
    echo ""
    
    # Verificar se já é um swarm
    if docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null | grep -q "active"; then
        echo -e "$amarelo ⚠️  Este nó já faz parte de um Docker Swarm $reset"
        echo ""
        docker node ls
    else
        echo -e "$amarelo 🔄 Inicializando Docker Swarm... $reset"
        
        # Obter IP do servidor
        SERVER_IP=$(curl -s ifconfig.me)
        
        # Inicializar swarm
        docker swarm init --advertise-addr $SERVER_IP
        
        if [ $? -eq 0 ]; then
            echo -e "$verde ✅ Docker Swarm inicializado com sucesso! $reset"
            echo ""
            echo -e "$amarelo 📋 Token para adicionar workers: $reset"
            docker swarm join-token worker
        else
            echo -e "$vermelho ❌ Erro ao inicializar Docker Swarm $reset"
        fi
    fi
    
    # Criar redes overlay
    echo ""
    echo -e "$amarelo 🌐 Criando redes overlay... $reset"
    
    docker network create --driver overlay --attachable traefik-public 2>/dev/null || echo "Rede traefik-public já existe"
    docker network create --driver overlay --attachable aifocus-internal 2>/dev/null || echo "Rede aifocus-internal já existe"
    
    echo -e "$verde ✅ Redes criadas! $reset"
    echo ""
    read -p "Pressione ENTER para continuar..."
    menu_swarm
}

instalar_chatwoot(){
    clear
    echo -e "$magenta===================================================================================================$reset"
    echo -e "$verde 💬 INSTALANDO CHATWOOT EM DOCKER SWARM $reset"
    echo -e "$magenta===================================================================================================$reset"
    echo ""
    
    # Criar diretório para stacks
    mkdir -p /opt/aifocus/stacks
    cd /opt/aifocus/stacks
    
    # Solicitar informações
    read -p "Subdomínio para Chatwoot (ex: chat): " subdomain
    read -p "Seu domínio principal: " domain
    
    # Criar stack do Chatwoot para Swarm
    cat > chatwoot-stack.yml << EOF
version: '3.8'

services:
  postgres:
    image: postgres:13
    environment:
      POSTGRES_USER: chatwoot
      POSTGRES_PASSWORD: chatwoot_password
      POSTGRES_DB: chatwoot
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - aifocus-internal
    deploy:
      placement:
        constraints:
          - node.role == worker
      replicas: 1

  redis:
    image: redis:6-alpine
    volumes:
      - redis_data:/data
    networks:
      - aifocus-internal
    deploy:
      placement:
        constraints:
          - node.role == worker
      replicas: 1

  chatwoot:
    image: chatwoot/chatwoot:latest
    environment:
      RAILS_ENV: production
      DATABASE_URL: postgresql://chatwoot:chatwoot_password@postgres:5432/chatwoot
      REDIS_URL: redis://redis:6379
      SECRET_KEY_BASE: \$(openssl rand -hex 64)
      FRONTEND_URL: https://${subdomain}.${domain}
    networks:
      - traefik-public
      - aifocus-internal
    deploy:
      labels:
        - traefik.enable=true
        - traefik.http.routers.chatwoot.rule=Host(\`${subdomain}.${domain}\`)
        - traefik.http.routers.chatwoot.tls=true
        - traefik.http.routers.chatwoot.tls.certresolver=letsencrypt
        - traefik.http.services.chatwoot.loadbalancer.server.port=3000
        - traefik.docker.network=traefik-public
      replicas: 2
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure

volumes:
  postgres_data:
  redis_data:

networks:
  traefik-public:
    external: true
  aifocus-internal:
    external: true
EOF
    
    echo -e "$amarelo 🚀 Deployando Chatwoot no Swarm... $reset"
    docker stack deploy -c chatwoot-stack.yml chatwoot
    
    if [ $? -eq 0 ]; then
        echo -e "$verde ✅ Chatwoot instalado com sucesso! $reset"
        echo ""
        echo -e "$amarelo 📱 Acesse em: https://${subdomain}.${domain} $reset"
        echo -e "$amarelo 🔧 Execute as migrações em alguns minutos: $reset"
        echo -e "$branco docker exec -it \$(docker ps -q -f name=chatwoot_chatwoot) bundle exec rails db:migrate $reset"
    else
        echo -e "$vermelho ❌ Erro ao instalar Chatwoot $reset"
    fi
    
    echo ""
    read -p "Pressione ENTER para continuar..."
    menu_chat_automation
}

status_cluster(){
    clear
    echo -e "$ciano===================================================================================================$reset"
    echo -e "$verde 📊 STATUS DO CLUSTER DOCKER SWARM $reset"
    echo -e "$ciano===================================================================================================$reset"
    echo ""
    
    echo -e "$amarelo 🖥️  NODES DO CLUSTER: $reset"
    docker node ls
    echo ""
    
    echo -e "$amarelo 📦 STACKS ATIVAS: $reset"
    docker stack ls
    echo ""
    
    echo -e "$amarelo 🔄 SERVIÇOS EM EXECUÇÃO: $reset"
    docker service ls
    echo ""
    
    echo -e "$amarelo 🌐 REDES OVERLAY: $reset"
    docker network ls --filter driver=overlay
    echo ""
    
    read -p "Pressione ENTER para continuar..."
    menu_swarm
}

## Inicializar o menu principal
menu_principal