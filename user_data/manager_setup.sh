#!/bin/bash

# ============================================================================
# AIFOCUS COMPANY - DOCKER SWARM MANAGER SETUP
# Automatic configuration script for Docker Swarm manager nodes
# ============================================================================

set -e  # Exit on any error

# ============================================================================
# VARIABLES FROM TERRAFORM
# ============================================================================

NODE_ROLE="${node_role}"
NODE_INDEX="${node_index}"
MANAGER_IPS=(${join(" ", manager_ips)})
IS_PRIMARY="${is_primary}"
DOMAIN="${domain}"
EMAIL="${email}"
ENVIRONMENT="${environment}"

# ============================================================================
# LOGGING SETUP
# ============================================================================

exec > >(tee -a /var/log/manager-setup.log)
exec 2>&1

echo "============================================================================"
echo "AIFOCUS SWARM MANAGER SETUP - NODE $NODE_INDEX"
echo "============================================================================"
echo "Starting setup at: $(date)"
echo "Node Role: $NODE_ROLE"
echo "Node Index: $NODE_INDEX"
echo "Is Primary: $IS_PRIMARY"
echo "Domain: $DOMAIN"
echo "Environment: $ENVIRONMENT"
echo "============================================================================"

# ============================================================================
# SYSTEM UPDATES AND BASIC PACKAGES
# ============================================================================

echo "📦 Updating system packages..."
apt-get update -y
apt-get upgrade -y

echo "📦 Installing essential packages..."
apt-get install -y \
    curl \
    wget \
    git \
    vim \
    htop \
    unzip \
    software-properties-common \
    ca-certificates \
    gnupg \
    lsb-release \
    jq \
    ncdu \
    tree \
    fail2ban \
    ufw \
    ntp \
    logrotate

# ============================================================================
# TIMEZONE CONFIGURATION
# ============================================================================

echo "🕒 Setting timezone to UTC..."
timedatectl set-timezone UTC

# ============================================================================
# SECURITY HARDENING
# ============================================================================

echo "🛡️ Configuring basic security..."

# Configure UFW firewall
ufw --force reset
ufw default deny incoming
ufw default allow outgoing

# Allow SSH
ufw allow 22/tcp

# Allow Docker Swarm ports
ufw allow 2376/tcp   # Docker daemon API
ufw allow 2377/tcp   # Cluster management
ufw allow 7946/tcp   # Node communication
ufw allow 7946/udp   # Node communication
ufw allow 4789/udp   # Overlay network

# Allow HTTP/HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# Allow internal network
ufw allow from 10.0.0.0/16

# Enable firewall
ufw --force enable

# Configure fail2ban
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 1h
findtime = 10m
maxretry = 5

[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log
maxretry = 3
EOF

systemctl enable fail2ban
systemctl start fail2ban

# ============================================================================
# DOCKER INSTALLATION
# ============================================================================

echo "🐳 Installing Docker..."

# Add Docker's official GPG key
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Configure Docker daemon
mkdir -p /etc/docker
cat > /etc/docker/daemon.json << 'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "features": {
    "buildkit": true
  },
  "experimental": false,
  "metrics-addr": "0.0.0.0:9323",
  "default-address-pools": [
    {
      "base": "172.30.0.0/16",
      "size": 24
    }
  ]
}
EOF

# Start and enable Docker
systemctl enable docker
systemctl start docker

# Add root to docker group (if needed)
usermod -aG docker root

echo "✅ Docker installed successfully!"

# ============================================================================
# DOCKER SWARM INITIALIZATION (PRIMARY MANAGER ONLY)
# ============================================================================

if [ "$IS_PRIMARY" = "true" ]; then
    echo "🚀 Initializing Docker Swarm (Primary Manager)..."
    
    # Get private IP
    PRIVATE_IP=$(hostname -I | awk '{print $2}')
    
    # Initialize swarm
    docker swarm init --advertise-addr $PRIVATE_IP
    
    # Save join tokens
    mkdir -p /opt/aifocus/swarm
    docker swarm join-token manager | grep "docker swarm join" > /opt/aifocus/swarm/manager-token
    docker swarm join-token worker | grep "docker swarm join" > /opt/aifocus/swarm/worker-token
    
    # Create overlay networks
    docker network create --driver overlay --attachable traefik-public
    docker network create --driver overlay --attachable aifocus-internal
    docker network create --driver overlay --attachable database-internal
    docker network create --driver overlay --attachable monitoring-internal
    
    echo "✅ Docker Swarm initialized successfully!"
    
    # ============================================================================
    # DEPLOY CORE INFRASTRUCTURE
    # ============================================================================
    
    echo "🏗️ Preparing core infrastructure..."
    
    # Create directories
    mkdir -p /opt/aifocus/{stacks,configs,secrets,data}
    mkdir -p /opt/aifocus/data/{traefik,portainer,grafana,prometheus,postgres,redis}
    
    # Generate secrets
    echo "🔐 Generating secrets..."
    
    # Portainer admin password
    openssl rand -base64 32 | tr -d "=" | head -c 24 > /opt/aifocus/secrets/portainer_admin_password
    
    # Database passwords
    openssl rand -base64 32 | tr -d "=" | head -c 24 > /opt/aifocus/secrets/postgres_password
    openssl rand -base64 32 | tr -d "=" | head -c 24 > /opt/aifocus/secrets/postgres_replication_password
    openssl rand -base64 32 | tr -d "=" | head -c 24 > /opt/aifocus/secrets/redis_password
    
    # Application passwords
    openssl rand -base64 32 | tr -d "=" | head -c 24 > /opt/aifocus/secrets/grafana_admin_password
    openssl rand -base64 32 | tr -d "=" | head -c 24 > /opt/aifocus/secrets/chatwoot_secret_key
    
    # Create Docker secrets
    docker secret create portainer_admin_password /opt/aifocus/secrets/portainer_admin_password
    docker secret create postgres_password /opt/aifocus/secrets/postgres_password
    docker secret create postgres_replication_password /opt/aifocus/secrets/postgres_replication_password
    docker secret create redis_password /opt/aifocus/secrets/redis_password
    docker secret create grafana_admin_password /opt/aifocus/secrets/grafana_admin_password
    docker secret create chatwoot_secret_key /opt/aifocus/secrets/chatwoot_secret_key
    
    echo "✅ Secrets created successfully!"
    
else
    echo "⏳ Waiting for primary manager to initialize swarm..."
    
    # Wait for primary manager and join swarm
    sleep 60
    
    # This will be handled by a separate script or manual intervention
    # The join command will be provided by the primary manager
fi

# ============================================================================
# NODE LABELS
# ============================================================================

echo "🏷️ Setting node labels..."

# Wait for swarm to be ready
sleep 10

if [ "$IS_PRIMARY" = "true" ]; then
    # Label this node
    docker node update --label-add manager.primary=true $(docker node ls --filter role=manager --format "{{.Hostname}}" | head -1)
    docker node update --label-add database.postgres.primary=true $(docker node ls --filter role=manager --format "{{.Hostname}}" | head -1)
    
    # Wait for other managers to join and label them
    # This is a simplified approach - in production you might want more sophisticated labeling
fi

# ============================================================================
# MONITORING AGENT
# ============================================================================

echo "📊 Installing monitoring agents..."

# Install Node Exporter
useradd --no-create-home --shell /bin/false node_exporter

cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
tar xzf node_exporter-1.7.0.linux-amd64.tar.gz
cp node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/
chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Create systemd service
cat > /etc/systemd/system/node_exporter.service << 'EOF'
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

# ============================================================================
# LOG ROTATION
# ============================================================================

echo "📝 Configuring log rotation..."

cat > /etc/logrotate.d/aifocus << 'EOF'
/var/log/aifocus/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 644 root root
}

/opt/aifocus/data/*/logs/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 644 root root
    sharedscripts
    postrotate
        docker kill -s USR1 $(docker ps -q --filter label=com.docker.swarm.service.name) 2>/dev/null || true
    endscript
}
EOF

# ============================================================================
# CLEANUP AND OPTIMIZATION
# ============================================================================

echo "🧹 Cleaning up and optimizing..."

# Clean up
apt-get autoremove -y
apt-get autoclean

# Optimize system
echo 'vm.swappiness=10' >> /etc/sysctl.conf
echo 'net.core.rmem_max=16777216' >> /etc/sysctl.conf
echo 'net.core.wmem_max=16777216' >> /etc/sysctl.conf

# Docker optimization
echo 'fs.inotify.max_user_watches=1048576' >> /etc/sysctl.conf

sysctl -p

# ============================================================================
# FINAL SETUP
# ============================================================================

echo "🎯 Final setup tasks..."

# Create maintenance scripts directory
mkdir -p /opt/aifocus/scripts

# Create a simple health check script
cat > /opt/aifocus/scripts/health-check.sh << 'EOF'
#!/bin/bash
echo "=== Docker Swarm Health Check ==="
echo "Node Status:"
docker node ls
echo ""
echo "Service Status:"
docker service ls
echo ""
echo "Stack Status:"
docker stack ls
echo ""
echo "System Resources:"
free -h
df -h
echo ""
echo "Last 10 Docker events:"
docker events --since="1h" --until="now" | tail -10
EOF

chmod +x /opt/aifocus/scripts/health-check.sh

# Create update script
cat > /opt/aifocus/scripts/update-system.sh << 'EOF'
#!/bin/bash
echo "=== System Update Script ==="
apt-get update -y
apt-get upgrade -y
docker system prune -f
echo "System updated successfully!"
EOF

chmod +x /opt/aifocus/scripts/update-system.sh

# Create backup information file
cat > /opt/aifocus/node-info.txt << EOF
Node Type: Manager
Node Index: $NODE_INDEX
Is Primary: $IS_PRIMARY
Setup Date: $(date)
Domain: $DOMAIN
Environment: $ENVIRONMENT
EOF

# ============================================================================
# COMPLETION
# ============================================================================

echo "============================================================================"
echo "✅ AIFOCUS SWARM MANAGER SETUP COMPLETED SUCCESSFULLY!"
echo "============================================================================"
echo "Node: Manager $NODE_INDEX"
echo "Primary: $IS_PRIMARY"
echo "Setup completed at: $(date)"
echo ""
echo "Next steps:"
if [ "$IS_PRIMARY" = "true" ]; then
    echo "1. This is the primary manager - Swarm has been initialized"
    echo "2. Deploy Traefik: docker stack deploy -c traefik.yml traefik"
    echo "3. Deploy Portainer: docker stack deploy -c portainer.yml portainer"
    echo "4. Join worker tokens are available in /opt/aifocus/swarm/"
else
    echo "1. Join this manager to the swarm using the token from primary manager"
    echo "2. Wait for stack deployments from primary manager"
fi
echo ""
echo "Health check: /opt/aifocus/scripts/health-check.sh"
echo "System update: /opt/aifocus/scripts/update-system.sh"
echo "============================================================================"

# Signal completion
touch /opt/aifocus/.setup-completed 