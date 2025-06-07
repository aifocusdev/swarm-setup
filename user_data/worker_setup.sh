#!/bin/bash

# ============================================================================
# AIFOCUS COMPANY - DOCKER SWARM WORKER SETUP
# Automatic configuration script for Docker Swarm worker nodes
# ============================================================================

set -e  # Exit on any error

# ============================================================================
# VARIABLES FROM TERRAFORM
# ============================================================================

NODE_ROLE="${node_role}"
NODE_INDEX="${node_index}"
MANAGER_IP="${manager_ip}"
DOMAIN="${domain}"
ENVIRONMENT="${environment}"

# ============================================================================
# LOGGING SETUP
# ============================================================================

exec > >(tee -a /var/log/worker-setup.log)
exec 2>&1

echo "============================================================================"
echo "AIFOCUS SWARM WORKER SETUP - NODE $NODE_INDEX"
echo "============================================================================"
echo "Starting setup at: $(date)"
echo "Node Role: $NODE_ROLE"
echo "Node Index: $NODE_INDEX"
echo "Manager IP: $MANAGER_IP"
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
ufw allow 7946/tcp   # Node communication
ufw allow 7946/udp   # Node communication
ufw allow 4789/udp   # Overlay network

# Allow HTTP/HTTPS (for containers)
ufw allow 80/tcp
ufw allow 443/tcp

# Allow internal network
ufw allow from 10.0.0.0/16

# Allow monitoring ports
ufw allow 9100/tcp   # Node Exporter
ufw allow 8080/tcp   # cAdvisor

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

# Configure Docker daemon for workers (optimized for workloads)
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
  ],
  "max-concurrent-downloads": 10,
  "max-concurrent-uploads": 10
}
EOF

# Start and enable Docker
systemctl enable docker
systemctl start docker

# Add root to docker group
usermod -aG docker root

echo "✅ Docker installed successfully!"

# ============================================================================
# PREPARE FOR SWARM JOIN
# ============================================================================

echo "⏳ Preparing to join Docker Swarm..."

# Create directories for worker-specific data
mkdir -p /opt/aifocus/{data,logs}
mkdir -p /opt/aifocus/data/{volumes,apps,cache}

# Set up volume directories with proper permissions
mkdir -p /opt/aifocus/data/volumes/{postgres,redis,mongo,minio,uploads,backups}
chmod -R 755 /opt/aifocus/data/volumes

# This worker will join the swarm via the join token
# The actual join will happen after the manager provides the token
echo "Worker node is ready to join swarm. Waiting for join token from manager."

# ============================================================================
# MONITORING AGENTS
# ============================================================================

echo "📊 Installing monitoring agents..."

# Install Node Exporter
useradd --no-create-home --shell /bin/false node_exporter

cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
tar xzf node_exporter-1.7.0.linux-amd64.tar.gz
cp node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/
chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Create systemd service for Node Exporter
cat > /etc/systemd/system/node_exporter.service << 'EOF'
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --web.listen-address=:9100

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

# Install cAdvisor for container monitoring
docker run \
  --detach=true \
  --name=cadvisor \
  --restart=unless-stopped \
  --publish=8080:8080 \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:rw \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  --privileged \
  --device=/dev/kmsg \
  gcr.io/cadvisor/cadvisor:latest

echo "✅ Monitoring agents installed!"

# ============================================================================
# STORAGE OPTIMIZATION
# ============================================================================

echo "💾 Optimizing storage..."

# Configure Docker cleanup
cat > /etc/cron.daily/docker-cleanup << 'EOF'
#!/bin/bash
# Clean up Docker system
docker system prune -f --volumes
docker image prune -a -f --filter "until=168h"
EOF

chmod +x /etc/cron.daily/docker-cleanup

# Set up log rotation for containers
cat > /etc/logrotate.d/docker-containers << 'EOF'
/var/lib/docker/containers/*/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    sharedscripts
    postrotate
        /bin/kill -USR1 $(cat /var/run/docker.pid) 2>/dev/null || true
    endscript
}
EOF

# ============================================================================
# WORKER-SPECIFIC OPTIMIZATIONS
# ============================================================================

echo "⚡ Applying worker-specific optimizations..."

# Increase file limits for containers
cat >> /etc/security/limits.conf << 'EOF'
root soft nofile 65536
root hard nofile 65536
* soft nofile 65536
* hard nofile 65536
EOF

# Optimize kernel parameters for containerized workloads
cat >> /etc/sysctl.conf << 'EOF'
# Memory management
vm.swappiness=10
vm.dirty_ratio=40
vm.dirty_background_ratio=5

# Network optimization
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.core.netdev_max_backlog=5000
net.ipv4.tcp_rmem=4096 65536 16777216
net.ipv4.tcp_wmem=4096 65536 16777216

# File system optimization
fs.inotify.max_user_watches=1048576
fs.file-max=2097152

# Docker specific
kernel.pid_max=4194304
EOF

sysctl -p

# ============================================================================
# BACKUP PREPARATION
# ============================================================================

echo "🗄️ Setting up backup infrastructure..."

# Create backup directories
mkdir -p /opt/aifocus/backups/{daily,weekly,monthly}
mkdir -p /opt/aifocus/scripts

# Create worker backup script
cat > /opt/aifocus/scripts/backup-worker-data.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="/opt/aifocus/backups/daily"
DATE=$(date +%Y%m%d_%H%M%S)

echo "Starting worker backup at: $(date)"

# Backup container volumes
if [ -d "/opt/aifocus/data/volumes" ]; then
    tar czf "$BACKUP_DIR/volumes_$DATE.tar.gz" -C /opt/aifocus/data volumes/
    echo "Volumes backed up successfully"
fi

# Backup logs
if [ -d "/opt/aifocus/logs" ]; then
    tar czf "$BACKUP_DIR/logs_$DATE.tar.gz" -C /opt/aifocus logs/
    echo "Logs backed up successfully"
fi

# Clean old backups (keep only 7 days)
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +7 -delete

echo "Worker backup completed at: $(date)"
EOF

chmod +x /opt/aifocus/scripts/backup-worker-data.sh

# Add to crontab
echo "0 3 * * * /opt/aifocus/scripts/backup-worker-data.sh" | crontab -

# ============================================================================
# HEALTH MONITORING
# ============================================================================

echo "🔍 Setting up health monitoring..."

# Create worker health check script
cat > /opt/aifocus/scripts/health-check-worker.sh << 'EOF'
#!/bin/bash

echo "=== Worker Node Health Check ==="
echo "Date: $(date)"
echo ""

echo "=== System Resources ==="
free -h
echo ""
df -h
echo ""

echo "=== Docker Status ==="
systemctl status docker --no-pager -l
echo ""

echo "=== Running Containers ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo "=== Container Resource Usage ==="
docker stats --no-stream
echo ""

echo "=== Docker Swarm Status ==="
if docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null | grep -q "active"; then
    echo "Node is part of swarm"
    docker node ls 2>/dev/null || echo "Cannot list nodes (worker node)"
else
    echo "Node is NOT part of swarm"
fi
echo ""

echo "=== Disk Usage by Container ==="
docker system df
echo ""

echo "=== Recent Docker Events ==="
docker events --since="1h" --until="now" | tail -10
echo ""

echo "=== Load Average ==="
uptime
echo ""

echo "=== Network Connections ==="
netstat -tuln | grep -E ':80|:443|:2377|:7946|:4789'
echo ""

echo "Health check completed at: $(date)"
EOF

chmod +x /opt/aifocus/scripts/health-check-worker.sh

# ============================================================================
# MAINTENANCE SCRIPTS
# ============================================================================

echo "🔧 Creating maintenance scripts..."

# System update script
cat > /opt/aifocus/scripts/update-worker.sh << 'EOF'
#!/bin/bash

echo "=== Worker Node Update Script ==="
echo "Starting update at: $(date)"

# Update system packages
apt-get update -y
apt-get upgrade -y

# Update Docker images that are in use
docker images --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>" | xargs -r docker pull

# Clean up unused resources
docker system prune -f
docker volume prune -f

# Restart monitoring agents
systemctl restart node_exporter

echo "Worker update completed at: $(date)"
EOF

chmod +x /opt/aifocus/scripts/update-worker.sh

# Performance monitoring script
cat > /opt/aifocus/scripts/monitor-performance.sh << 'EOF'
#!/bin/bash

LOG_FILE="/opt/aifocus/logs/performance.log"
mkdir -p /opt/aifocus/logs

echo "$(date): Starting performance monitoring" >> $LOG_FILE

# Monitor CPU, Memory, Disk for 5 minutes
for i in {1..5}; do
    echo "=== $(date) ===" >> $LOG_FILE
    echo "CPU Usage:" >> $LOG_FILE
    top -bn1 | head -3 >> $LOG_FILE
    echo "Memory Usage:" >> $LOG_FILE
    free -h >> $LOG_FILE
    echo "Disk Usage:" >> $LOG_FILE
    df -h >> $LOG_FILE
    echo "Container Stats:" >> $LOG_FILE
    docker stats --no-stream >> $LOG_FILE
    echo "" >> $LOG_FILE
    sleep 60
done

echo "$(date): Performance monitoring completed" >> $LOG_FILE
EOF

chmod +x /opt/aifocus/scripts/monitor-performance.sh

# ============================================================================
# CONTAINER RUNTIME OPTIMIZATION
# ============================================================================

echo "🏃 Optimizing container runtime..."

# Create custom Docker daemon service override
mkdir -p /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/override.conf << 'EOF'
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --host=fd:// --containerd=/run/containerd/containerd.sock --storage-opt dm.loopdatasize=200G
EOF

systemctl daemon-reload

# ============================================================================
# CLEANUP AND FINAL SETUP
# ============================================================================

echo "🧹 Final cleanup and setup..."

# Clean up
apt-get autoremove -y
apt-get autoclean

# Create node information file
cat > /opt/aifocus/node-info.txt << EOF
Node Type: Worker
Node Index: $NODE_INDEX
Setup Date: $(date)
Manager IP: $MANAGER_IP
Domain: $DOMAIN
Environment: $ENVIRONMENT
EOF

# Create join swarm helper script
cat > /opt/aifocus/scripts/join-swarm.sh << 'EOF'
#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 '<docker swarm join command>'"
    echo "Example: $0 'docker swarm join --token SWMTKN-1-... 10.0.1.10:2377'"
    exit 1
fi

echo "Joining Docker Swarm with command: $1"
eval "$1"

if [ $? -eq 0 ]; then
    echo "Successfully joined Docker Swarm!"
    docker info | grep -A 10 Swarm
else
    echo "Failed to join Docker Swarm"
    exit 1
fi
EOF

chmod +x /opt/aifocus/scripts/join-swarm.sh

# ============================================================================
# POST-SETUP INSTRUCTIONS
# ============================================================================

echo "============================================================================"
echo "✅ AIFOCUS SWARM WORKER SETUP COMPLETED SUCCESSFULLY!"
echo "============================================================================"
echo "Node: Worker $NODE_INDEX"
echo "Setup completed at: $(date)"
echo ""
echo "Next steps:"
echo "1. Get worker join token from manager node:"
echo "   ssh root@$MANAGER_IP 'docker swarm join-token worker'"
echo ""
echo "2. Join this worker to the swarm:"
echo "   /opt/aifocus/scripts/join-swarm.sh 'docker swarm join --token TOKEN MANAGER_IP:2377'"
echo ""
echo "3. Verify swarm membership from manager:"
echo "   docker node ls"
echo ""
echo "Available scripts:"
echo "  - Health check: /opt/aifocus/scripts/health-check-worker.sh"
echo "  - System update: /opt/aifocus/scripts/update-worker.sh"
echo "  - Performance monitor: /opt/aifocus/scripts/monitor-performance.sh"
echo "  - Join swarm: /opt/aifocus/scripts/join-swarm.sh"
echo ""
echo "Monitoring endpoints:"
echo "  - Node Exporter: http://$(hostname -I | awk '{print $1}'):9100/metrics"
echo "  - cAdvisor: http://$(hostname -I | awk '{print $1}'):8080"
echo "============================================================================"

# Signal completion
touch /opt/aifocus/.setup-completed

echo "Worker setup completed successfully!" 