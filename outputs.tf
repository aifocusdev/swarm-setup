# ============================================================================
# AIFOCUS COMPANY - TERRAFORM OUTPUTS
# Docker Swarm Infrastructure Outputs
# ============================================================================

# ============================================================================
# NETWORK INFORMATION
# ============================================================================

output "network_id" {
  description = "ID of the private network"
  value       = hcloud_network.aifocus_network.id
}

output "network_ip_range" {
  description = "IP range of the private network"
  value       = hcloud_network.aifocus_network.ip_range
}

output "subnet_ip_range" {
  description = "IP range of the subnet"
  value       = hcloud_network_subnet.aifocus_subnet.ip_range
}

# ============================================================================
# MANAGER NODES INFORMATION
# ============================================================================

output "manager_nodes" {
  description = "Manager nodes information"
  value = {
    for i, server in hcloud_server.swarm_manager : 
    "manager-${i + 1}" => {
      id         = server.id
      name       = server.name
      public_ip  = server.ipv4_address
      private_ip = [for network in server.network : network.ip if network.ip != null][0]
      location   = server.location
      server_type = server.server_type
      status     = server.status
    }
  }
}

output "manager_public_ips" {
  description = "Public IP addresses of manager nodes"
  value       = hcloud_server.swarm_manager[*].ipv4_address
}

output "manager_private_ips" {
  description = "Private IP addresses of manager nodes"  
  value       = [for server in hcloud_server.swarm_manager : [for network in server.network : network.ip if network.ip != null][0]]
}

output "primary_manager_ip" {
  description = "Public IP of the primary manager node"
  value       = hcloud_server.swarm_manager[0].ipv4_address
}

output "primary_manager_private_ip" {
  description = "Private IP of the primary manager node"
  value       = [for network in hcloud_server.swarm_manager[0].network : network.ip if network.ip != null][0]
}

# ============================================================================
# WORKER NODES INFORMATION
# ============================================================================

output "worker_nodes" {
  description = "Worker nodes information"
  value = var.worker_count > 0 ? {
    for i, server in hcloud_server.swarm_worker : 
    "worker-${i + 1}" => {
      id         = server.id
      name       = server.name
      public_ip  = server.ipv4_address
      private_ip = [for network in server.network : network.ip if network.ip != null][0]
      location   = server.location
      server_type = server.server_type
      status     = server.status
    }
  } : {}
}

output "worker_public_ips" {
  description = "Public IP addresses of worker nodes"
  value       = var.worker_count > 0 ? hcloud_server.swarm_worker[*].ipv4_address : []
}

output "worker_private_ips" {
  description = "Private IP addresses of worker nodes"
  value       = var.worker_count > 0 ? [for server in hcloud_server.swarm_worker : [for network in server.network : network.ip if network.ip != null][0]] : []
}

# ============================================================================
# LOAD BALANCER INFORMATION
# ============================================================================

output "load_balancer_info" {
  description = "Load balancer information"
  value = var.enable_load_balancer ? {
    id         = hcloud_load_balancer.aifocus_lb[0].id
    name       = hcloud_load_balancer.aifocus_lb[0].name
    public_ip  = hcloud_load_balancer.aifocus_lb[0].ipv4
    private_ip = hcloud_load_balancer_network.aifocus_lb_network[0].ip
    type       = hcloud_load_balancer.aifocus_lb[0].load_balancer_type
    location   = hcloud_load_balancer.aifocus_lb[0].location
  } : null
}

output "load_balancer_public_ip" {
  description = "Public IP address of the load balancer"
  value       = var.enable_load_balancer ? hcloud_load_balancer.aifocus_lb[0].ipv4 : null
}

# ============================================================================ 
# FLOATING IP INFORMATION
# ============================================================================

output "floating_ip" {
  description = "Floating IP address"
  value       = hcloud_floating_ip.aifocus_floating_ip.ip_address
}

output "floating_ip_info" {
  description = "Floating IP information"
  value = {
    ip       = hcloud_floating_ip.aifocus_floating_ip.ip_address
    type     = hcloud_floating_ip.aifocus_floating_ip.type
    location = hcloud_floating_ip.aifocus_floating_ip.home_location
    assigned_to = hcloud_floating_ip_assignment.aifocus_floating_assignment.server_id
  }
}

# ============================================================================
# STORAGE INFORMATION
# ============================================================================

output "volumes_info" {
  description = "Volumes information"
  value = var.enable_volumes && var.worker_count > 0 ? {
    for i, volume in hcloud_volume.aifocus_data : 
    "volume-${i + 1}" => {
      id       = volume.id
      name     = volume.name
      size     = volume.size
      location = volume.location
      attached_to = hcloud_volume_attachment.aifocus_data_attachment[i].server_id
    }
  } : {}
}

# ============================================================================
# DNS INFORMATION
# ============================================================================

# output "dns_records" {
#   description = "DNS records created"
#   sensitive   = true
#   value = var.cloudflare_token != "" ? {
#     main_domain = {
#       name    = cloudflare_record.aifocus_main[0].name
#       type    = cloudflare_record.aifocus_main[0].type
#       content = cloudflare_record.aifocus_main[0].content
#       proxied = cloudflare_record.aifocus_main[0].proxied
#     }
#     wildcard = {
#       name    = cloudflare_record.aifocus_wildcard[0].name
#       type    = cloudflare_record.aifocus_wildcard[0].type
#       content = cloudflare_record.aifocus_wildcard[0].content
#       proxied = cloudflare_record.aifocus_wildcard[0].proxied
#     }
#     services = {
#       for record in cloudflare_record.aifocus_services :
#       record.name => {
#         name    = record.name
#         type    = record.type
#         content = record.content
#         proxied = record.proxied
#       }
#     }
#   } : null
# }

# ============================================================================
# CONNECTION INFORMATION
# ============================================================================

output "ssh_connection_commands" {
  description = "SSH connection commands for all nodes"
  value = {
    managers = [
      for i, server in hcloud_server.swarm_manager :
      "ssh -i ${var.ssh_private_key_path} root@${server.ipv4_address}  # manager-${i + 1}"
    ]
    workers = var.worker_count > 0 ? [
      for i, server in hcloud_server.swarm_worker :
      "ssh -i ${var.ssh_private_key_path} root@${server.ipv4_address}  # worker-${i + 1}"
    ] : []
  }
}

output "docker_swarm_init_command" {
  description = "Command to initialize Docker Swarm (run on primary manager)"
  value       = "docker swarm init --advertise-addr ${[for network in hcloud_server.swarm_manager[0].network : network.ip if network.ip != null][0]}"
}

output "docker_swarm_join_token_command" {
  description = "Command to get worker join token (run on primary manager)"
  value       = "docker swarm join-token worker"
}

# ============================================================================
# ACCESS URLS
# ============================================================================

output "access_urls" {
  description = "Access URLs for services"
  value = {
    portainer      = "https://portainer.${var.domain}"
    traefik        = "https://traefik.${var.domain}"
    grafana        = "https://grafana.${var.domain}"
    prometheus     = "https://prometheus.${var.domain}"
    chatwoot       = "https://chat.${var.domain}"
    evolution      = "https://evolution.${var.domain}"
    n8n           = "https://n8n.${var.domain}"
    typebot       = "https://typebot.${var.domain}"
    uptime_kuma   = "https://uptime.${var.domain}"
    pgadmin       = "https://pgadmin.${var.domain}"
    main_site     = "https://${var.domain}"
  }
}

# ============================================================================
# DEPLOYMENT SUMMARY
# ============================================================================

output "deployment_summary" {
  description = "Summary of the deployment"
  sensitive   = true
  value = {
    environment          = var.environment
    domain              = var.domain
    total_nodes         = var.manager_count + var.worker_count
    manager_nodes       = var.manager_count
    worker_nodes        = var.worker_count
    load_balancer       = var.enable_load_balancer
    volumes_enabled     = var.enable_volumes
    monitoring_enabled  = var.enable_monitoring
    backups_enabled     = var.enable_backups
    firewall_enabled    = var.enable_firewall
    cloudflare_enabled  = var.cloudflare_token != ""
  }
}

# ============================================================================
# COST INFORMATION
# ============================================================================

output "estimated_monthly_cost" {
  description = "Custo mensal estimado em EUR"
  value = {
    managers      = var.manager_count * 15.11  # cx31 cost
    workers       = var.worker_count * 7.00    # cx21 cost
    load_balancer = var.enable_load_balancer ? 5.83 : 0.00
    network       = 0.00
    firewall      = 0.00
    total         = (var.manager_count * 15.11) + (var.worker_count * 7.00) + (var.enable_load_balancer ? 5.83 : 0.00)
  }
}

# ============================================================================
# NEXT STEPS & INSTRUCTIONS
# ============================================================================

output "next_steps" {
  description = "Important next steps after deployment"
  value = [
    "🎉 DEPLOY CONCLUÍDO COM SUCESSO!",
    "⏱️  Aguarde 5-10 minutos para configuração completa dos servidores",
    "🌐 Acesse Portainer: https://portainer.${var.domain}",
    "🌐 Acesse Traefik: https://traefik.${var.domain}",
    "🌐 Acesse Grafana: https://grafana.${var.domain}",
    "🔐 Configure senhas nos primeiros acessos",
    "📊 Custo mensal estimado: €${(var.manager_count * 15.11) + (var.worker_count * 7.00) + (var.enable_load_balancer ? 5.83 : 0.00)}"
  ]
}

output "important_notes" {
  description = "Important security and operational notes"
  value = [
    "🔒 Change default passwords immediately after first login",
    "🔐 Regenerate API tokens after initial setup for security", 
    "📱 Configure monitoring alerts for production use",
    "💾 Set up automated backups for critical data",
    "🛡️  Firewall is ${var.enable_firewall ? "enabled" : "disabled"} - review security settings"
  ]
} 