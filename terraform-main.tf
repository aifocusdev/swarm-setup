# ============================================================================
# AIFOCUS COMPANY - DOCKER SWARM INFRASTRUCTURE
# Hetzner Cloud + Load Balancer + High Availability
# ============================================================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# ============================================================================
# PROVIDERS
# ============================================================================

provider "hcloud" {
  token = var.hetzner_token
}

provider "cloudflare" {
  api_token = var.cloudflare_token
}

# ============================================================================
# DATA SOURCES
# ============================================================================

data "hcloud_ssh_key" "default" {
  name = var.ssh_key_name
}

data "cloudflare_zone" "domain" {
  count = var.cloudflare_token != "" ? 1 : 0
  name  = var.domain
}

# ============================================================================
# NETWORK CONFIGURATION
# ============================================================================

resource "hcloud_network" "aifocus_network" {
  name     = "aifocus-network"
  ip_range = "10.0.0.0/16"
  labels = {
    environment = var.environment
    project     = "aifocus-swarm"
  }
}

resource "hcloud_network_subnet" "aifocus_subnet" {
  type         = "cloud"
  network_id   = hcloud_network.aifocus_network.id
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

# ============================================================================
# PLACEMENT GROUPS (Anti-Affinity)
# ============================================================================

resource "hcloud_placement_group" "swarm_managers" {
  name   = "swarm-managers"
  type   = "spread"
  labels = {
    role = "manager"
  }
}

resource "hcloud_placement_group" "swarm_workers" {
  name   = "swarm-workers"  
  type   = "spread"
  labels = {
    role = "worker"
  }
}

# ============================================================================
# SWARM MANAGER NODES
# ============================================================================

resource "hcloud_server" "swarm_manager" {
  count              = var.manager_count
  name               = "aifocus-manager-${count.index + 1}"
  image              = var.server_image
  server_type        = var.manager_server_type
  location           = var.locations[count.index % length(var.locations)]
  ssh_keys           = [data.hcloud_ssh_key.default.id]
  placement_group_id = hcloud_placement_group.swarm_managers.id
  
  network {
    network_id = hcloud_network.aifocus_network.id
    ip         = "10.0.1.${10 + count.index}"
  }

  user_data = templatefile("${path.module}/user_data/manager_setup.sh", {
    node_role     = "manager"
    node_index    = count.index + 1
    manager_ips   = [for i in range(var.manager_count) : "10.0.1.${10 + i}"]
    is_primary    = count.index == 0
    domain        = var.domain
    email         = var.email
    environment   = var.environment
  })

  labels = {
    role        = "manager"
    environment = var.environment
    project     = "aifocus-swarm"
  }

  depends_on = [hcloud_network_subnet.aifocus_subnet]
}

# ============================================================================
# SWARM WORKER NODES
# ============================================================================

resource "hcloud_server" "swarm_worker" {
  count              = var.worker_count
  name               = "aifocus-worker-${count.index + 1}"
  image              = var.server_image
  server_type        = var.worker_server_type
  location           = var.locations[count.index % length(var.locations)]
  ssh_keys           = [data.hcloud_ssh_key.default.id]
  placement_group_id = hcloud_placement_group.swarm_workers.id
  
  network {
    network_id = hcloud_network.aifocus_network.id
    ip         = "10.0.1.${20 + count.index}"
  }

  user_data = templatefile("${path.module}/user_data/worker_setup.sh", {
    node_role     = "worker"
    node_index    = count.index + 1
    manager_ip    = "10.0.1.10"
    domain        = var.domain
    environment   = var.environment
  })

  labels = {
    role        = "worker"
    environment = var.environment
    project     = "aifocus-swarm"
  }

  depends_on = [
    hcloud_network_subnet.aifocus_subnet,
    hcloud_server.swarm_manager
  ]
}

# ============================================================================
# LOAD BALANCER
# ============================================================================

resource "hcloud_load_balancer" "aifocus_lb" {
  count              = var.enable_load_balancer ? 1 : 0
  name               = "aifocus-loadbalancer"
  load_balancer_type = var.load_balancer_type
  location           = var.locations[0]
  
  labels = {
    environment = var.environment
    project     = "aifocus-swarm"
  }
}

resource "hcloud_load_balancer_network" "aifocus_lb_network" {
  count            = var.enable_load_balancer ? 1 : 0
  load_balancer_id = hcloud_load_balancer.aifocus_lb[0].id
  network_id       = hcloud_network.aifocus_network.id
  ip               = "10.0.1.254"
}

# HTTP Target Group
resource "hcloud_load_balancer_target" "aifocus_lb_target_http" {
  count            = var.enable_load_balancer ? var.manager_count : 0
  type             = "server"
  load_balancer_id = hcloud_load_balancer.aifocus_lb[0].id
  server_id        = hcloud_server.swarm_manager[count.index].id
  use_private_ip   = true
}

# HTTPS Target Group  
resource "hcloud_load_balancer_target" "aifocus_lb_target_https" {
  count            = var.enable_load_balancer ? var.manager_count : 0
  type             = "server"
  load_balancer_id = hcloud_load_balancer.aifocus_lb[0].id
  server_id        = hcloud_server.swarm_manager[count.index].id
  use_private_ip   = true
}

# Load Balancer Services
resource "hcloud_load_balancer_service" "aifocus_lb_http" {
  count            = var.enable_load_balancer ? 1 : 0
  load_balancer_id = hcloud_load_balancer.aifocus_lb[0].id
  protocol         = "http"
  listen_port      = 80
  destination_port = 80
  
  health_check {
    protocol = "http"
    port     = 80
    interval = 15
    timeout  = 10
    retries  = 3
    http {
      path         = "/health"
      status_codes = ["200"]
    }
  }
}

resource "hcloud_load_balancer_service" "aifocus_lb_https" {
  count            = var.enable_load_balancer ? 1 : 0
  load_balancer_id = hcloud_load_balancer.aifocus_lb[0].id
  protocol         = "tcp"
  listen_port      = 443
  destination_port = 443
  
  health_check {
    protocol = "tcp"
    port     = 443
    interval = 15
    timeout  = 10
    retries  = 3
  }
}

# ============================================================================
# VOLUMES (Shared Storage)
# ============================================================================

resource "hcloud_volume" "aifocus_data" {
  count    = var.enable_volumes && var.worker_count > 0 ? var.worker_count : 0
  name     = "aifocus-data-${count.index + 1}"
  size     = var.volume_size
  location = var.locations[count.index % length(var.locations)]
  format   = "ext4"
  
  labels = {
    environment = var.environment
    project     = "aifocus-swarm"
    type        = "data"
  }
}

resource "hcloud_volume_attachment" "aifocus_data_attachment" {
  count     = var.enable_volumes && var.worker_count > 0 ? var.worker_count : 0
  volume_id = hcloud_volume.aifocus_data[count.index].id
  server_id = hcloud_server.swarm_worker[count.index].id
  automount = true
}

# ============================================================================
# FLOATING IPS
# ============================================================================

resource "hcloud_floating_ip" "aifocus_floating_ip" {
  type          = "ipv4"
  home_location = var.locations[0]
  name          = "aifocus-floating-ip"
  
  labels = {
    environment = var.environment
    project     = "aifocus-swarm"
  }
}

resource "hcloud_floating_ip_assignment" "aifocus_floating_assignment" {
  floating_ip_id = hcloud_floating_ip.aifocus_floating_ip.id
  server_id      = hcloud_server.swarm_manager[0].id
}

# ============================================================================
# FIREWALL RULES
# ============================================================================

resource "hcloud_firewall" "aifocus_firewall" {
  name = "aifocus-firewall"
  
  # SSH Access
  rule {
    direction = "in"
    port      = "22"
    protocol  = "tcp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  
  # HTTP/HTTPS
  rule {
    direction = "in"
    port      = "80"
    protocol  = "tcp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  
  rule {
    direction = "in"
    port      = "443"
    protocol  = "tcp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  
  # Docker Swarm Ports
  rule {
    direction = "in"
    port      = "2377"
    protocol  = "tcp"
    source_ips = ["10.0.0.0/16"]
  }
  
  rule {
    direction = "in"
    port      = "7946"
    protocol  = "tcp"
    source_ips = ["10.0.0.0/16"]
  }
  
  rule {
    direction = "in"
    port      = "7946"
    protocol  = "udp"
    source_ips = ["10.0.0.0/16"]
  }
  
  rule {
    direction = "in"
    port      = "4789"
    protocol  = "udp"
    source_ips = ["10.0.0.0/16"]
  }
  
  # Custom Application Ports
  rule {
    direction = "in"
    port      = "8080"
    protocol  = "tcp"
    source_ips = ["10.0.0.0/16"]
  }
  
  rule {
    direction = "in"
    port      = "9000"
    protocol  = "tcp"
    source_ips = ["10.0.0.0/16"]
  }
}

# Attach firewall to servers
resource "hcloud_firewall_attachment" "aifocus_firewall_manager" {
  count       = var.manager_count
  firewall_id = hcloud_firewall.aifocus_firewall.id
  server_ids  = [hcloud_server.swarm_manager[count.index].id]
}

resource "hcloud_firewall_attachment" "aifocus_firewall_worker" {
  count       = var.worker_count > 0 ? var.worker_count : 0
  firewall_id = hcloud_firewall.aifocus_firewall.id
  server_ids  = [hcloud_server.swarm_worker[count.index].id]
}

# ============================================================================
# DNS RECORDS (Cloudflare)
# ============================================================================

# Main domain pointing to Load Balancer
resource "cloudflare_record" "aifocus_main" {
  count   = var.cloudflare_token != "" ? 1 : 0
  zone_id = data.cloudflare_zone.domain[0].id
  name    = var.domain
  value   = var.enable_load_balancer ? hcloud_load_balancer.aifocus_lb[0].ipv4 : hcloud_floating_ip.aifocus_floating_ip.ip_address
  type    = "A"
  ttl     = 300
  proxied = var.cloudflare_proxied
}

# Wildcard subdomain
resource "cloudflare_record" "aifocus_wildcard" {
  count   = var.cloudflare_token != "" ? 1 : 0
  zone_id = data.cloudflare_zone.domain[0].id
  name    = "*"
  value   = var.enable_load_balancer ? hcloud_load_balancer.aifocus_lb[0].ipv4 : hcloud_floating_ip.aifocus_floating_ip.ip_address
  type    = "A"
  ttl     = 300
  proxied = false
}

# Service-specific subdomains
locals {
  subdomains = [
    "traefik",
    "portainer", 
    "chatwoot",
    "evolution",
    "n8n",
    "typebot",
    "grafana",
    "prometheus",
    "uptime",
    "minio",
    "pgadmin",
    "redis-insight"
  ]
}

resource "cloudflare_record" "aifocus_services" {
  count   = var.cloudflare_token != "" ? length(local.subdomains) : 0
  zone_id = data.cloudflare_zone.domain[0].id
  name    = local.subdomains[count.index]
  value   = var.enable_load_balancer ? hcloud_load_balancer.aifocus_lb[0].ipv4 : hcloud_floating_ip.aifocus_floating_ip.ip_address
  type    = "A"
  ttl     = 300
  proxied = false
}