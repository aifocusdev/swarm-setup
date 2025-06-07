# 🚀 **GUIA COMPLETO DE INSTALAÇÃO - AIFOCUS SWARM**

## 📋 **PRÉ-REQUISITOS**

### **1. Conta Hetzner Cloud**
- Crie uma conta em: https://console.hetzner.cloud/
- Gere um API Token em: Project > Security > API Tokens
- (Opcional) Crie uma chave SSH e faça upload

### **2. Domínio e DNS**
- Tenha um domínio próprio (ex: minhaempresa.com)
- (Opcional) Conta Cloudflare para DNS automático

### **3. Máquina Local**
- Linux ou WSL2 no Windows
- Git instalado
- Acesso à internet

---

## 🏗️ **INSTALAÇÃO RÁPIDA (5 MINUTOS)**

### **Passo 1: Clone e Execute**
```bash
# Clone o repositório
git clone https://github.com/aifocus/swarm-setup.git
cd swarm-setup/estrutura

# Torne executável
chmod +x AiFocusSwarm.sh SETUP-AIFOCUS-SWARM.sh

# Execute o setup inicial
./SETUP-AIFOCUS-SWARM.sh
```

### **Passo 2: Configure a Infraestrutura**
```bash
# Execute o menu principal
./AiFocusSwarm.sh

# Escolha: 1 - Gerenciar Infraestrutura
# Depois: 1 - Configurar Terraform
```

**Informações necessárias:**
- ✅ Token da API Hetzner Cloud
- ✅ Seu domínio (ex: empresa.com)
- ✅ Email para certificados SSL
- ✅ Nome da chave SSH no Hetzner
- 💰 Configuração de custos (opcional)

### **Passo 3: Deploy da Infraestrutura**
- O sistema criará automaticamente:
  - ⚡ 3 Managers + 2 Workers (configurável)
  - 🌐 Load Balancer com SSL
  - 🔒 Firewall e redes privadas
  - 💾 Volumes para dados
  - 📊 Monitoramento completo

**⏱️ Tempo estimado: 8-12 minutos**

---

## 📊 **CUSTOS ESTIMADOS**

### **💰 Setup Básico (Teste)**
- **2x cx21**: ~€20/mês
- **1x Load Balancer**: ~€6/mês
- **1x Volume 20GB**: ~€2/mês
- **TOTAL**: ~€28/mês

### **🏢 Setup Produção**
- **3x cx31 + 2x cx21**: ~€65/mês
- **1x Load Balancer**: ~€12/mês
- **2x Volume 50GB**: ~€10/mês
- **TOTAL**: ~€87/mês

### **🚀 Setup Enterprise**
- **3x cx41 + 5x cx41**: ~€240/mês
- **1x Load Balancer Pro**: ~€24/mês
- **5x Volume 100GB**: ~€50/mês
- **TOTAL**: ~€314/mês

---

## 🎯 **O QUE SERÁ CRIADO**

### **🏗️ Infraestrutura Base**
```
┌─────────────────────────────────────────┐
│              LOAD BALANCER              │
│            (SSL Termination)            │
└─────────────────┬───────────────────────┘
                  │
    ┌─────────────┼─────────────┐
    │             │             │
┌───▼───┐     ┌───▼───┐     ┌───▼───┐
│Manager│     │Manager│     │Manager│
│   1   │     │   2   │     │   3   │
└───────┘     └───────┘     └───────┘
                  │
              ┌───▼───┐     ┌───────┐
              │Worker │     │Worker │
              │   1   │     │   2   │
              └───────┘     └───────┘
```

### **🌐 Redes e Conectividade**
- **Rede Pública**: Para acesso externo
- **Rede Privada**: Comunicação interna segura
- **SSL Automático**: Let's Encrypt para todos os serviços
- **DNS Automático**: Subdomínios configurados automaticamente

### **📦 Stacks Incluídos**
- ✅ **Traefik**: Proxy reverso e SSL
- ✅ **Portainer**: Interface de gerenciamento
- ✅ **Monitoring**: Prometheus + Grafana
- ✅ **Chatwoot**: Sistema de chat
- ✅ **Evolution API**: WhatsApp Business
- ✅ **N8N**: Automação de workflows
- ✅ **Typebot**: Chatbots inteligentes

---

## 🚀 **APÓS A INSTALAÇÃO**

### **1. Acessos Principais**
```bash
# URLs que estarão disponíveis:
https://portainer.seudominio.com    # Gerenciamento Docker
https://traefik.seudominio.com      # Proxy/Load Balancer
https://grafana.seudominio.com      # Monitoramento
https://chat.seudominio.com         # Chatwoot
https://evolution.seudominio.com    # WhatsApp API
```

### **2. Credenciais Padrão**
- **Portainer**: Configure na primeira vez
- **Grafana**: admin / [senha gerada automaticamente]
- **Traefik**: admin / admin (MUDE IMEDIATAMENTE!)

### **3. Primeiros Passos**
```bash
# 1. Acesse o Portainer
https://portainer.seudominio.com

# 2. Configure senha de admin

# 3. Verifique se todos os serviços estão rodando:
docker service ls

# 4. Acesse o Grafana para ver métricas:
https://grafana.seudominio.com
```

---

## 🔧 **CONFIGURAÇÃO AVANÇADA**

### **1. Adicionar Mais Workers**
```bash
# No manager principal, obtenha o token:
docker swarm join-token worker

# No novo servidor worker:
docker swarm join --token SWMTKN-1-... manager-ip:2377
```

### **2. Configurar Monitoramento**
```bash
# Deploy do stack de monitoramento:
./AiFocusSwarm.sh
# Escolha: 2 - Monitoramento e Logs
# Depois: 1 - Instalar Stack de Monitoramento
```

### **3. Configurar Chat e Automação**
```bash
# Deploy do Chatwoot + Evolution:
./AiFocusSwarm.sh
# Escolha: 3 - Chat e Automação
# Depois: Escolha os serviços desejados
```

---

## 🛠️ **MANUTENÇÃO E OPERAÇÃO**

### **📊 Monitoramento**
```bash
# Verificar status do cluster:
./AiFocusSwarm.sh → 2 - Gerenciar Swarm → 3 - Status do Cluster

# Métricas em tempo real:
docker stats

# Logs dos serviços:
docker service logs [nome-do-serviço]
```

### **🔄 Backups Automáticos**
- ✅ Configurados automaticamente
- ✅ Executam diariamente às 2h
- ✅ Retêm 7 dias de backups
- ✅ Localizados em: `/opt/aifocus/backups/`

### **🔒 Segurança**
- ✅ Firewall configurado automaticamente
- ✅ SSL/TLS em todos os serviços
- ✅ Rede privada isolada
- ✅ Fail2ban ativo
- ✅ Logs centralizados

### **📈 Escalabilidade**
```bash
# Escalar um serviço:
docker service scale [serviço]=[replicas]

# Exemplo:
docker service scale chatwoot_app=3
```

---

## 🚨 **SOLUÇÃO DE PROBLEMAS**

### **❌ Problema: Terraform falha**
```bash
# Verifique o token da API:
terraform plan

# Reinicie se necessário:
terraform destroy
terraform apply
```

### **❌ Problema: Serviço não inicia**
```bash
# Verifique os logs:
docker service logs [nome-do-serviço] --follow

# Verifique recursos:
docker node ls
docker system df
```

### **❌ Problema: SSL não funciona**
```bash
# Verifique o DNS:
nslookup seudominio.com

# Verifique o Traefik:
docker service logs traefik_traefik --follow
```

### **❌ Problema: Alto uso de recursos**
```bash
# Monitore em tempo real:
docker stats

# Otimize recursos:
docker system prune -a
docker volume prune
```

---

## 📞 **SUPORTE E COMUNIDADE**

### **📚 Documentação**
- 📖 Wiki completo: [Em construção]
- 🎥 Videos tutoriais: [Em construção]
- 💡 Exemplos práticos: `./exemplos/`

### **🤝 Comunidade**
- 💬 Discord: [Link em breve]
- 📧 Email: suporte@aifocus.com.br
- 🐛 Issues: GitHub Issues

### **📋 Roadmap**
- ✅ ~~Infraestrutura base~~ (Concluído)
- ✅ ~~Monitoramento~~ (Concluído)
- ✅ ~~Chat automation~~ (Concluído)
- 🔄 Auto-scaling (Em desenvolvimento)
- 🔄 Multi-cloud (Próximo)
- 🔄 Kubernetes migration (Futuro)

---

## 🎉 **PRÓXIMOS PASSOS**

1. **📊 Configure o monitoramento** para acompanhar a performance
2. **💬 Implemente o Chatwoot** para atendimento
3. **🤖 Configure automações** com N8N e Typebot
4. **🔍 Monitore logs** através do Grafana
5. **⚡ Otimize performance** baseado nas métricas

---

**✨ Parabéns! Você agora tem uma infraestrutura enterprise completa rodando na nuvem! ✨**

*Made with ❤️ by AiFocus Company* 