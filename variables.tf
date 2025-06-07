# ============================================================================
# AIFOCUS COMPANY - TERRAFORM VARIABLES
# Docker Swarm Infrastructure Variables
# ============================================================================

# ============================================================================
# PROVIDER CREDENTIALS
# ============================================================================

variable "hetzner_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "cloudflare_token" {
  description = "Cloudflare API Token"
  type        = string
  sensitive   = true
  default     = ""
}

# ============================================================================
# INFRASTRUCTURE SETTINGS
# ============================================================================

variable "environment" {
  description = "Environment name (production, staging, development)"
  type        = string
  default     = "production"
  
  validation {
    condition     = contains(["production", "staging", "development"], var.environment)
    error_message = "Environment must be one of: production, staging, development."
  }
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "aifocus-swarm"
}

# ============================================================================
# DOMAIN & SSL CONFIGURATION
# ============================================================================

variable "domain" {
  description = "Main domain name (e.g., example.com)"
  type        = string
}

variable "email" {
  description = "Email for Let's Encrypt SSL certificates"
  type        = string
}

variable "cloudflare_proxied" {
  description = "Whether to proxy DNS records through Cloudflare"
  type        = bool
  default     = false
}

# ============================================================================
# SERVER CONFIGURATION
# ============================================================================

variable "server_image" {
  description = "Server image to use"
  type        = string
  default     = "ubuntu-22.04"
}

variable "locations" {
  description = "List of Hetzner locations for high availability"
  type        = list(string)
  default     = ["nbg1", "fsn1", "hel1"]
}

# ============================================================================
# MANAGER NODES CONFIGURATION
# ============================================================================

variable "manager_count" {
  description = "Number of Swarm manager nodes"
  type        = number
  default     = 3
  
  validation {
    condition     = var.manager_count >= 1 && var.manager_count <= 7 && var.manager_count % 2 == 1
    error_message = "Manager count must be an odd number between 1 and 7."
  }
}

variable "manager_server_type" {
  description = "Server type for manager nodes"
  type        = string
  default     = "cx31"
}

# ============================================================================
# WORKER NODES CONFIGURATION
# ============================================================================

variable "worker_count" {
  description = "Number of Swarm worker nodes"
  type        = number
  default     = 2
  
  validation {
    condition     = var.worker_count >= 0 && var.worker_count <= 20
    error_message = "Worker count must be between 0 and 20."
  }
}

variable "worker_server_type" {
  description = "Server type for worker nodes"
  type        = string
  default     = "cx21"
}

# ============================================================================
# LOAD BALANCER CONFIGURATION
# ============================================================================

variable "load_balancer_type" {
  description = "Load balancer type"
  type        = string
  default     = "lb11"
}

variable "enable_load_balancer" {
  description = "Whether to create a load balancer"
  type        = bool
  default     = true
}

# ============================================================================
# STORAGE CONFIGURATION
# ============================================================================

variable "volume_size" {
  description = "Size of volumes in GB"
  type        = number
  default     = 50
  
  validation {
    condition     = var.volume_size >= 10 && var.volume_size <= 10000
    error_message = "Volume size must be between 10 and 10000 GB."
  }
}

variable "enable_volumes" {
  description = "Whether to create additional volumes"
  type        = bool
  default     = true
}

# ============================================================================
# SSH CONFIGURATION
# ============================================================================

variable "ssh_key_name" {
  description = "Name of the SSH key in Hetzner Cloud"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key file"
  type        = string
  default     = "~/.ssh/id_rsa"
}

# ============================================================================
# NETWORK CONFIGURATION
# ============================================================================

variable "network_zone" {
  description = "Network zone for the private network"
  type        = string
  default     = "eu-central"
}

variable "network_ip_range" {
  description = "IP range for the private network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_ip_range" {
  description = "IP range for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

# ============================================================================
# SECURITY CONFIGURATION
# ============================================================================

variable "allowed_ips" {
  description = "List of allowed IP addresses for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_firewall" {
  description = "Whether to enable firewall"
  type        = bool
  default     = true
}

# ============================================================================
# MONITORING CONFIGURATION
# ============================================================================

variable "enable_monitoring" {
  description = "Whether to enable monitoring stack"
  type        = bool
  default     = true
}

variable "monitoring_retention_days" {
  description = "Number of days to retain monitoring data"
  type        = number
  default     = 30
}

# ============================================================================
# BACKUP CONFIGURATION
# ============================================================================

variable "enable_backups" {
  description = "Whether to enable automatic backups"
  type        = bool
  default     = true
}

variable "backup_schedule" {
  description = "Cron schedule for backups"
  type        = string
  default     = "0 2 * * *"  # Daily at 2 AM
}

# ============================================================================
# ADVANCED CONFIGURATION
# ============================================================================

variable "docker_version" {
  description = "Docker version to install"
  type        = string
  default     = "24.0"
}

variable "enable_log_rotation" {
  description = "Whether to enable log rotation"
  type        = bool
  default     = true
}

variable "max_log_size" {
  description = "Maximum log size before rotation"
  type        = string
  default     = "100m"
}

variable "timezone" {
  description = "Timezone for all servers"
  type        = string
  default     = "UTC"
}

# ============================================================================
# RESOURCE TAGS
# ============================================================================

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default = {
    "ManagedBy"   = "Terraform"
    "Project"     = "AiFocus-Swarm"
    "Environment" = "Production"
  }
} 