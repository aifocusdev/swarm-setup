# ============================================================================
# AIFOCUS SWARM - CONFIGURAÇÃO FINAL AUTOMÁTICA (PowerShell)
# Script para configurar Docker Swarm e todos os serviços
# ============================================================================

# Configurações
$DOMAIN = "aifocus.dev"
$MANAGER_IP = "167.235.75.251"
$MANAGER_PRIVATE_IP = "10.0.1.10"

Write-Host "======================================================================================================" -ForegroundColor Cyan
Write-Host "  🚀 AIFOCUS SWARM - CONFIGURAÇÃO FINAL AUTOMÁTICA" -ForegroundColor Cyan
Write-Host "  Configurando Docker Swarm e todos os serviços" -ForegroundColor Cyan
Write-Host "======================================================================================================" -ForegroundColor Cyan
Write-Host ""

# Como não temos acesso SSH funcionando, vou criar um script que pode ser executado manualmente
# Primeiro, vou criar todos os arquivos de configuração

Write-Host "📋 Criando arquivos de configuração dos serviços..." -ForegroundColor Yellow

# 1. Traefik Configuration
@"
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
      - "80:80"
      - "443:443"
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
        - traefik.http.routers.traefik.rule=Host(`traefik.$DOMAIN`)
        - traefik.http.routers.traefik.entrypoints=websecure
        - traefik.http.routers.traefik.tls.certresolver=letsencrypt
        - traefik.http.routers.traefik.service=api@internal
        - traefik.http.services.traefik.loadbalancer.server.port=8080

volumes:
  traefik-letsencrypt:

networks:
  traefik-public:
    external: true
"@ | Out-File -FilePath "traefik.yml" -Encoding UTF8

Write-Host "✅ traefik.yml criado" -ForegroundColor Green

# 2. Portainer Configuration
@"
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
        - traefik.http.routers.portainer.rule=Host(`portainer.$DOMAIN`)
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
"@ | Out-File -FilePath "portainer.yml" -Encoding UTF8

Write-Host "✅ portainer.yml criado" -ForegroundColor Green

# 3. Monitoring Stack
@"
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
        - traefik.http.routers.prometheus.rule=Host(`prometheus.$DOMAIN`)
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
        - traefik.http.routers.grafana.rule=Host(`grafana.$DOMAIN`)
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
"@ | Out-File -FilePath "monitoring.yml" -Encoding UTF8

Write-Host "✅ monitoring.yml criado" -ForegroundColor Green

# 4. Prometheus Configuration
@"
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
"@ | Out-File -FilePath "prometheus.yml" -Encoding UTF8

Write-Host "✅ prometheus.yml criado" -ForegroundColor Green

# 5. Uptime Kuma
@"
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
        - traefik.http.routers.uptime.rule=Host(`uptime.$DOMAIN`)
        - traefik.http.routers.uptime.entrypoints=websecure
        - traefik.http.routers.uptime.tls.certresolver=letsencrypt
        - traefik.http.services.uptime.loadbalancer.server.port=3001

volumes:
  uptime_data:

networks:
  traefik-public:
    external: true
"@ | Out-File -FilePath "uptime.yml" -Encoding UTF8

Write-Host "✅ uptime.yml criado" -ForegroundColor Green

# 6. Script de Deploy
@"
#!/bin/bash

# Configurar Docker Swarm
echo "🐳 Configurando Docker Swarm..."
docker swarm init --advertise-addr $MANAGER_PRIVATE_IP 2>/dev/null || echo "Swarm já inicializado"

# Criar redes
echo "🌐 Criando redes..."
docker network create --driver overlay --attachable traefik-public 2>/dev/null || echo "Rede traefik-public já existe"
docker network create --driver overlay --attachable monitoring 2>/dev/null || echo "Rede monitoring já existe"
docker network create --driver overlay --attachable apps 2>/dev/null || echo "Rede apps já existe"

# Deploy dos serviços
echo "🚀 Deployando Traefik..."
docker stack deploy -c traefik.yml traefik

echo "⏱️ Aguardando Traefik inicializar..."
sleep 30

echo "🐳 Deployando Portainer..."
docker stack deploy -c portainer.yml portainer

echo "📊 Deployando Monitoring..."
docker stack deploy -c monitoring.yml monitoring

echo "📡 Deployando Uptime Kuma..."
docker stack deploy -c uptime.yml uptime

echo "⏱️ Aguardando todos os serviços..."
sleep 60

echo "✅ Verificando status..."
docker stack ls
docker service ls

echo ""
echo "🎉 TODOS OS SERVIÇOS DEPLOYADOS!"
echo ""
echo "🌐 ACESSOS:"
echo "✅ Traefik: https://traefik.$DOMAIN"
echo "✅ Portainer: https://portainer.$DOMAIN"
echo "✅ Grafana: https://grafana.$DOMAIN (admin/aifocus2024!)"
echo "✅ Prometheus: https://prometheus.$DOMAIN"
echo "✅ Uptime: https://uptime.$DOMAIN"
echo ""
"@ | Out-File -FilePath "deploy-all.sh" -Encoding UTF8

Write-Host "✅ deploy-all.sh criado" -ForegroundColor Green

Write-Host ""
Write-Host "======================================================================================================" -ForegroundColor Cyan
Write-Host "📋 ARQUIVOS CRIADOS COM SUCESSO!" -ForegroundColor Green
Write-Host "======================================================================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "🔗 Para finalizar a configuração, siga estes passos:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. 📂 Todos os arquivos YAML foram criados neste diretório" -ForegroundColor Blue
Write-Host "2. 🔑 Configure acesso SSH ao servidor manager principal:" -ForegroundColor Blue
Write-Host "   IP: $MANAGER_IP" -ForegroundColor White
Write-Host ""
Write-Host "3. 📋 Copie os arquivos para o servidor e execute:" -ForegroundColor Blue
Write-Host "   scp *.yml *.sh root@${MANAGER_IP}:~/" -ForegroundColor White
Write-Host "   ssh root@$MANAGER_IP" -ForegroundColor White
Write-Host "   chmod +x deploy-all.sh" -ForegroundColor White
Write-Host "   ./deploy-all.sh" -ForegroundColor White
Write-Host ""

Write-Host "🌐 SERVIÇOS QUE SERÃO DISPONIBILIZADOS:" -ForegroundColor Yellow
Write-Host "✅ Traefik Dashboard: https://traefik.$DOMAIN" -ForegroundColor Green
Write-Host "✅ Portainer: https://portainer.$DOMAIN" -ForegroundColor Green
Write-Host "✅ Grafana: https://grafana.$DOMAIN (admin/aifocus2024!)" -ForegroundColor Green
Write-Host "✅ Prometheus: https://prometheus.$DOMAIN" -ForegroundColor Green
Write-Host "✅ Uptime Kuma: https://uptime.$DOMAIN" -ForegroundColor Green
Write-Host ""

Write-Host "💰 CUSTO MENSAL: €65.16" -ForegroundColor Blue
Write-Host "🔗 LOAD BALANCER: 167.235.110.156" -ForegroundColor Blue
Write-Host ""

Write-Host "🎉 INFRAESTRUTURA AIFOCUS SWARM PRONTA PARA CONFIGURAÇÃO FINAL!" -ForegroundColor Green

Write-Host ""
Write-Host "ALTERNATIVAMENTE, você pode acessar o Hetzner Cloud Console e configurar via interface web." -ForegroundColor Yellow 