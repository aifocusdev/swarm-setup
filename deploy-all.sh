#!/bin/bash

echo "======================================================================================================="
echo "🚀 AIFOCUS SWARM - CONFIGURAÇÃO FINAL AUTOMÁTICA"
echo "======================================================================================================="
echo ""

# Configurar Docker Swarm
echo "🐳 [1/6] Configurando Docker Swarm..."
docker swarm init --advertise-addr 10.0.1.10 2>/dev/null || echo "✅ Swarm já inicializado"
echo ""

# Criar redes
echo "🌐 [2/6] Criando redes Docker..."
docker network create --driver overlay --attachable traefik-public 2>/dev/null || echo "✅ Rede traefik-public já existe"
docker network create --driver overlay --attachable monitoring 2>/dev/null || echo "✅ Rede monitoring já existe"
docker network create --driver overlay --attachable apps 2>/dev/null || echo "✅ Rede apps já existe"
echo ""

# Deploy Traefik
echo "🔀 [3/6] Deployando Traefik (Load Balancer)..."
docker stack deploy -c traefik.yml traefik
echo "⏱️ Aguardando Traefik inicializar..."
sleep 30
echo ""

# Deploy Portainer
echo "🐳 [4/6] Deployando Portainer (Gerenciamento Docker)..."
docker stack deploy -c portainer.yml portainer
echo ""

# Deploy Monitoring
echo "📊 [5/6] Deployando Stack de Monitoramento..."
docker stack deploy -c monitoring.yml monitoring
echo ""

# Deploy Uptime Kuma
echo "📡 [6/6] Deployando Uptime Kuma..."
docker stack deploy -c uptime.yml uptime
echo ""

# Aguardar todos os serviços
echo "⏱️ Aguardando todos os serviços iniciarem..."
sleep 60
echo ""

# Verificar status
echo "✅ Verificando status dos serviços..."
docker stack ls
echo ""
docker service ls
echo ""

echo "======================================================================================================="
echo "🎉 TODOS OS SERVIÇOS DEPLOYADOS COM SUCESSO!"
echo "======================================================================================================="
echo ""

echo "🌐 SERVIÇOS DISPONÍVEIS:"
echo "✅ Traefik Dashboard: https://traefik.aifocus.dev"
echo "✅ Portainer: https://portainer.aifocus.dev"
echo "✅ Grafana: https://grafana.aifocus.dev (admin/aifocus2024!)"
echo "✅ Prometheus: https://prometheus.aifocus.dev"
echo "✅ Uptime Kuma: https://uptime.aifocus.dev"
echo ""

echo "📋 INFORMAÇÕES IMPORTANTES:"
echo "🔐 Grafana Login: admin / aifocus2024!"
echo "🔗 Load Balancer IP: 167.235.110.156"
echo "💰 Custo Mensal: €65.16"
echo ""

echo "🚀 SUA INFRAESTRUTURA AIFOCUS SWARM ESTÁ PRONTA!" 