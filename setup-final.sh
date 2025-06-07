#!/bin/bash

# ============================================================================
# AIFOCUS SWARM - CONFIGURAÇÃO FINAL AUTOMÁTICA
# Script para configurar Docker Swarm e todos os serviços
# ============================================================================

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configurações
DOMAIN="aifocus.dev"
MANAGER_IP="167.235.75.251"
MANAGER_PRIVATE_IP="10.0.1.10"
WORKER1_IP="91.99.56.40"
WORKER2_IP="91.99.95.193"

echo -e "${CYAN}======================================================================================================${NC}"
echo -e "${CYAN}  🚀 AIFOCUS SWARM - CONFIGURAÇÃO FINAL AUTOMÁTICA${NC}"
echo -e "${CYAN}  Configurando Docker Swarm e todos os serviços${NC}"
echo -e "${CYAN}======================================================================================================${NC}"
echo ""

# Função para executar comandos SSH
ssh_exec() {
    local host=$1
    local cmd=$2
    echo -e "${BLUE}📡 Executando em $host: $cmd${NC}"
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$host "$cmd"
}

# PASSO 1: Configurar Docker Swarm
echo -e "${YELLOW}🐳 [1/6] Configurando Docker Swarm...${NC}"

# Inicializar Swarm no manager principal
echo -e "${GREEN}✅ Inicializando Docker Swarm no manager principal...${NC}"
SWARM_OUTPUT=$(ssh_exec $MANAGER_IP "docker swarm init --advertise-addr $MANAGER_PRIVATE_IP 2>/dev/null || echo 'already_init'")

if [[ "$SWARM_OUTPUT" != "already_init" ]]; then
    # Obter tokens
    MANAGER_TOKEN=$(ssh_exec $MANAGER_IP "docker swarm join-token manager -q")
    WORKER_TOKEN=$(ssh_exec $MANAGER_IP "docker swarm join-token worker -q")

    # Adicionar outros managers
    echo -e "${GREEN}✅ Adicionando managers ao cluster...${NC}"
    ssh_exec "49.13.7.48" "docker swarm join --token $MANAGER_TOKEN $MANAGER_PRIVATE_IP:2377 2>/dev/null || true"
    ssh_exec "135.181.92.169" "docker swarm join --token $MANAGER_TOKEN $MANAGER_PRIVATE_IP:2377 2>/dev/null || true"

    # Adicionar workers
    echo -e "${GREEN}✅ Adicionando workers ao cluster...${NC}"
    ssh_exec $WORKER1_IP "docker swarm join --token $WORKER_TOKEN $MANAGER_PRIVATE_IP:2377 2>/dev/null || true"
    ssh_exec $WORKER2_IP "docker swarm join --token $WORKER_TOKEN $MANAGER_PRIVATE_IP:2377 2>/dev/null || true"
else
    echo -e "${YELLOW}⚠️  Docker Swarm já inicializado${NC}"
fi

# Verificar cluster
echo -e "${GREEN}✅ Verificando cluster Docker Swarm...${NC}"
ssh_exec $MANAGER_IP "docker node ls"
echo ""

# PASSO 2: Criar redes
echo -e "${YELLOW}🌐 [2/6] Criando redes Docker...${NC}"
ssh_exec $MANAGER_IP "docker network create --driver overlay --attachable traefik-public 2>/dev/null || echo 'Network already exists'"
ssh_exec $MANAGER_IP "docker network create --driver overlay --attachable monitoring 2>/dev/null || echo 'Network already exists'"
ssh_exec $MANAGER_IP "docker network create --driver overlay --attachable apps 2>/dev/null || echo 'Network already exists'"
echo ""

# PASSO 3: Deploy Traefik
echo -e "${YELLOW}🔀 [3/6] Deployando Traefik (Load Balancer)...${NC}"
ssh_exec $MANAGER_IP "cat > traefik.yml << 'EOF'
version: '3.8'

services:
  traefik:
    image: traefik:v3.0
    command:
      - --api.dashboard=true
      - --api.insecure=false
      - --providers.docker=true
      - --providers.docker.swarmMode=true
      - --providers.docker.exposedbydefault=false
      - --providers.docker.network=traefik-public
      - --entrypoints.web.address=:80
      - --entrypoints.websecure.address=:443
      - --certificatesresolvers.letsencrypt.acme.tlschallenge=true
      - --certificatesresolvers.letsencrypt.acme.email=aifocusdev@gmail.com
      - --certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json
      - --certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web
      - --global.checknewversion=false
      - --global.sendanonymoususage=false
    ports:
      - \"80:80\"
      - \"443:443\"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - traefik-letsencrypt:/letsencrypt
    networks:
      - traefik-public
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      labels:
        - traefik.enable=true
        - traefik.http.routers.traefik.rule=Host(\`traefik.$DOMAIN\`)
        - traefik.http.routers.traefik.entrypoints=websecure
        - traefik.http.routers.traefik.tls.certresolver=letsencrypt
        - traefik.http.routers.traefik.service=api@internal
        - traefik.http.services.traefik.loadbalancer.server.port=8080

volumes:
  traefik-letsencrypt:

networks:
  traefik-public:
    external: true
EOF"

ssh_exec $MANAGER_IP "docker stack deploy -c traefik.yml traefik"
echo ""

# PASSO 4: Deploy Portainer
echo -e "${YELLOW}🐳 [4/6] Deployando Portainer (Gerenciamento Docker)...${NC}"
ssh_exec $MANAGER_IP "cat > portainer.yml << 'EOF'
version: '3.8'

services:
  agent:
    image: portainer/agent:2.19.4
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /var/lib/docker/volumes:/var/lib/docker/volumes
    networks:
      - agent_network
    deploy:
      mode: global
      placement:
        constraints: [node.platform.os == linux]

  portainer:
    image: portainer/portainer-ee:2.19.4
    command: -H tcp://tasks.agent:9001 --tlsskipverify
    volumes:
      - portainer_data:/data
    networks:
      - agent_network
      - traefik-public
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.role == manager]
      labels:
        - traefik.enable=true
        - traefik.http.routers.portainer.rule=Host(\`portainer.$DOMAIN\`)
        - traefik.http.routers.portainer.entrypoints=websecure
        - traefik.http.routers.portainer.tls.certresolver=letsencrypt
        - traefik.http.services.portainer.loadbalancer.server.port=9000

volumes:
  portainer_data:

networks:
  agent_network:
    driver: overlay
    attachable: true
  traefik-public:
    external: true
EOF"

ssh_exec $MANAGER_IP "docker stack deploy -c portainer.yml portainer"
echo ""

# PASSO 5: Deploy Monitoring Stack (Grafana + Prometheus)
echo -e "${YELLOW}📊 [5/6] Deployando Stack de Monitoramento...${NC}"
ssh_exec $MANAGER_IP "cat > monitoring.yml << 'EOF'
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:v2.48.1
    command:
      - --config.file=/etc/prometheus/prometheus.yml
      - --storage.tsdb.path=/prometheus
      - --web.console.libraries=/etc/prometheus/console_libraries
      - --web.console.templates=/etc/prometheus/consoles
      - --storage.tsdb.retention.time=200h
      - --web.enable-lifecycle
    configs:
      - source: prometheus_config
        target: /etc/prometheus/prometheus.yml
    volumes:
      - prometheus_data:/prometheus
    networks:
      - monitoring
      - traefik-public
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      labels:
        - traefik.enable=true
        - traefik.http.routers.prometheus.rule=Host(\`prometheus.$DOMAIN\`)
        - traefik.http.routers.prometheus.entrypoints=websecure
        - traefik.http.routers.prometheus.tls.certresolver=letsencrypt
        - traefik.http.services.prometheus.loadbalancer.server.port=9090

  grafana:
    image: grafana/grafana:10.2.3
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=aifocus2024!
      - GF_USERS_ALLOW_SIGN_UP=false
    volumes:
      - grafana_data:/var/lib/grafana
    networks:
      - monitoring
      - traefik-public
    deploy:
      mode: replicated
      replicas: 1
      labels:
        - traefik.enable=true
        - traefik.http.routers.grafana.rule=Host(\`grafana.$DOMAIN\`)
        - traefik.http.routers.grafana.entrypoints=websecure
        - traefik.http.routers.grafana.tls.certresolver=letsencrypt
        - traefik.http.services.grafana.loadbalancer.server.port=3000

  node-exporter:
    image: prom/node-exporter:v1.7.0
    command:
      - --path.sysfs=/host/sys
      - --path.procfs=/host/proc
      - --collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    networks:
      - monitoring
    deploy:
      mode: global

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:v0.47.2
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:rw
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    networks:
      - monitoring
    deploy:
      mode: global

volumes:
  prometheus_data:
  grafana_data:

networks:
  monitoring:
    external: true
  traefik-public:
    external: true

configs:
  prometheus_config:
    file: ./prometheus.yml
EOF"

# Criar configuração do Prometheus
ssh_exec $MANAGER_IP "cat > prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    dns_sd_configs:
      - names:
          - 'tasks.node-exporter'
        type: 'A'
        port: 9100

  - job_name: 'cadvisor'
    dns_sd_configs:
      - names:
          - 'tasks.cadvisor'
        type: 'A'
        port: 8080
EOF"

ssh_exec $MANAGER_IP "docker stack deploy -c monitoring.yml monitoring"
echo ""

# PASSO 6: Deploy Uptime Kuma
echo -e "${YELLOW}📡 [6/6] Deployando Uptime Kuma (Monitoramento)...${NC}"
ssh_exec $MANAGER_IP "cat > uptime.yml << 'EOF'
version: '3.8'

services:
  uptime-kuma:
    image: louislam/uptime-kuma:1.23.11
    volumes:
      - uptime_data:/app/data
    networks:
      - traefik-public
    deploy:
      mode: replicated
      replicas: 1
      labels:
        - traefik.enable=true
        - traefik.http.routers.uptime.rule=Host(\`uptime.$DOMAIN\`)
        - traefik.http.routers.uptime.entrypoints=websecure
        - traefik.http.routers.uptime.tls.certresolver=letsencrypt
        - traefik.http.services.uptime.loadbalancer.server.port=3001

volumes:
  uptime_data:

networks:
  traefik-public:
    external: true
EOF"

ssh_exec $MANAGER_IP "docker stack deploy -c uptime.yml uptime"
echo ""

# Aguardar serviços
echo -e "${YELLOW}⏱️  Aguardando serviços iniciarem...${NC}"
sleep 30

# Verificar status
echo -e "${GREEN}✅ Verificando status dos serviços...${NC}"
ssh_exec $MANAGER_IP "docker stack ls"
echo ""
ssh_exec $MANAGER_IP "docker service ls"
echo ""

echo -e "${CYAN}======================================================================================================${NC}"
echo -e "${GREEN}🎉 CONFIGURAÇÃO COMPLETA! TODOS OS SERVIÇOS ESTÃO DEPLOYADOS!${NC}"
echo -e "${CYAN}======================================================================================================${NC}"
echo ""

echo -e "${YELLOW}🌐 SERVIÇOS DISPONÍVEIS:${NC}"
echo -e "${GREEN}✅ Traefik Dashboard: https://traefik.$DOMAIN${NC}"
echo -e "${GREEN}✅ Portainer: https://portainer.$DOMAIN${NC}"
echo -e "${GREEN}✅ Grafana: https://grafana.$DOMAIN (admin/aifocus2024!)${NC}"
echo -e "${GREEN}✅ Prometheus: https://prometheus.$DOMAIN${NC}"
echo -e "${GREEN}✅ Uptime Kuma: https://uptime.$DOMAIN${NC}"
echo ""

echo -e "${YELLOW}📋 INFORMAÇÕES IMPORTANTES:${NC}"
echo -e "${BLUE}🔐 Grafana Login: admin / aifocus2024!${NC}"
echo -e "${BLUE}🔗 Load Balancer IP: 167.235.110.156${NC}"
echo -e "${BLUE}💰 Custo Mensal: €65.16${NC}"
echo ""

echo -e "${GREEN}🚀 SUA INFRAESTRUTURA AIFOCUS SWARM ESTÁ PRONTA!${NC}" 