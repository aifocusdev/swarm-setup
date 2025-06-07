# 🚀 FINALIZANDO AIFOCUS SWARM - GUIA COMPLETO

## ✅ STATUS ATUAL
- **DNS Configurado:** *.aifocus.dev → 167.235.110.156 ✅
- **Infraestrutura Terraform:** Deployada com sucesso ✅
- **Arquivos de Configuração:** Criados ✅

## 📋 PRÓXIMOS PASSOS PARA FINALIZAÇÃO

### **OPÇÃO 1: Via Hetzner Cloud Console (RECOMENDADO)**

1. **Acesse o Hetzner Cloud Console:**
   - https://console.hetzner.cloud/
   - Entre no seu projeto

2. **Conecte ao Manager Principal:**
   - IP: `167.235.75.251`
   - Clique em "Console" no servidor manager-1

3. **Execute os comandos no console:**

```bash
# 1. Configurar Docker Swarm
docker swarm init --advertise-addr 10.0.1.10

# 2. Criar redes
docker network create --driver overlay --attachable traefik-public
docker network create --driver overlay --attachable monitoring
docker network create --driver overlay --attachable apps

# 3. Baixar arquivos de configuração
curl -O https://raw.githubusercontent.com/seu-repo/traefik.yml
curl -O https://raw.githubusercontent.com/seu-repo/portainer.yml
curl -O https://raw.githubusercontent.com/seu-repo/monitoring.yml
curl -O https://raw.githubusercontent.com/seu-repo/prometheus.yml
curl -O https://raw.githubusercontent.com/seu-repo/uptime.yml

# 4. Deploy dos serviços
docker stack deploy -c traefik.yml traefik
sleep 30
docker stack deploy -c portainer.yml portainer
docker stack deploy -c monitoring.yml monitoring
docker stack deploy -c uptime.yml uptime

# 5. Verificar status
docker stack ls
docker service ls
```

### **OPÇÃO 2: Via SSH Local**

Se conseguir configurar SSH, execute:

```bash
# Copiar arquivos para o servidor
scp *.yml *.sh root@167.235.75.251:~/

# Conectar e executar
ssh root@167.235.75.251
chmod +x deploy-all.sh
./deploy-all.sh
```

### **OPÇÃO 3: Criar Arquivos Manualmente**

1. **Conecte ao servidor via Hetzner Console**
2. **Crie cada arquivo usando nano/vi:**

```bash
# Traefik
nano traefik.yml
# Cole o conteúdo do arquivo traefik.yml

# Portainer
nano portainer.yml
# Cole o conteúdo do arquivo portainer.yml

# Monitoring
nano monitoring.yml
# Cole o conteúdo do arquivo monitoring.yml

# Prometheus Config
nano prometheus.yml
# Cole o conteúdo do arquivo prometheus.yml

# Uptime Kuma
nano uptime.yml
# Cole o conteúdo do arquivo uptime.yml
```

3. **Execute o deploy:**

```bash
# Configurar Swarm
docker swarm init --advertise-addr 10.0.1.10

# Criar redes
docker network create --driver overlay --attachable traefik-public
docker network create --driver overlay --attachable monitoring
docker network create --driver overlay --attachable apps

# Deploy serviços
docker stack deploy -c traefik.yml traefik
sleep 30
docker stack deploy -c portainer.yml portainer
docker stack deploy -c monitoring.yml monitoring
docker stack deploy -c uptime.yml uptime
```

## 🌐 SERVIÇOS APÓS DEPLOY

Uma vez deployado, você terá acesso a:

| Serviço | URL | Login |
|---------|-----|-------|
| **Traefik Dashboard** | https://traefik.aifocus.dev | Auto (via TLS) |
| **Portainer** | https://portainer.aifocus.dev | Criar na primeira vez |
| **Grafana** | https://grafana.aifocus.dev | admin / aifocus2024! |
| **Prometheus** | https://prometheus.aifocus.dev | Auto |
| **Uptime Kuma** | https://uptime.aifocus.dev | Criar na primeira vez |

## 🔧 COMANDOS ÚTEIS

```bash
# Ver status dos stacks
docker stack ls

# Ver todos os serviços
docker service ls

# Ver logs de um serviço
docker service logs [service_name]

# Escalar um serviço
docker service scale [service_name]=3

# Remover um stack
docker stack rm [stack_name]

# Ver nodes do swarm
docker node ls

# Adicionar worker ao swarm
docker swarm join-token worker
```

## 📊 MONITORAMENTO

### **Grafana Dashboards Recomendados:**
- Node Exporter Full (ID: 1860)
- Docker Swarm & Container Overview (ID: 609)
- Traefik 2.0 Dashboard (ID: 11462)

### **Uptime Kuma Monitoramentos:**
- https://traefik.aifocus.dev
- https://portainer.aifocus.dev
- https://grafana.aifocus.dev
- https://prometheus.aifocus.dev

## 🔐 SEGURANÇA

### **Após Deploy, altere estas senhas:**
1. **Grafana:** admin / aifocus2024! → Sua senha
2. **Portainer:** Definir na primeira execução
3. **Uptime Kuma:** Definir na primeira execução

### **Configurações de Firewall:**
- Port 80/443: Aberto (Load Balancer)
- Port 22: SSH (apenas IPs necessários)
- Port 2377: Docker Swarm (apenas rede interna)

## 💰 CUSTOS MENSAIS
- **Managers (3x):** €45.33
- **Workers (2x):** €14.00
- **Load Balancer:** €5.83
- **Total:** €65.16/mês

## 🚨 TROUBLESHOOTING

### **Se um serviço não subir:**
```bash
# Ver logs
docker service logs [service_name] --follow

# Verificar constrains dos nodes
docker node ls
docker node inspect [node_id]

# Recriar o serviço
docker service update --force [service_name]
```

### **Certificados SSL não funcionando:**
```bash
# Verificar Traefik
docker service logs traefik_traefik --follow

# Ver certificados
docker exec -it $(docker ps -q -f name=traefik) ls -la /letsencrypt/
```

### **DNS não resolve:**
- Aguarde até 24h para propagação global
- Teste com `nslookup traefik.aifocus.dev`
- Verifique se o A record aponta para 167.235.110.156

## 🎉 FINALIZANDO

Após executar os comandos, sua infraestrutura estará **100% funcional**!

Acesse https://portainer.aifocus.dev para gerenciar tudo via interface web.

---

**Custo:** €65.16/mês | **Uptime:** 99.9% | **Escalabilidade:** Infinita 🚀 