const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const bodyParser = require('body-parser');
const { execSync, exec } = require('child_process');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.API_PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Logging middleware
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
    next();
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ 
        status: 'healthy', 
        timestamp: new Date().toISOString(),
        service: 'aifocus-setup-api'
    });
});

// Get system status
app.get('/api/status', (req, res) => {
    try {
        const dockerInfo = execSync('docker info --format "{{json .}}"', { encoding: 'utf8' });
        const swarmInfo = JSON.parse(dockerInfo);
        
        res.json({
            docker: {
                running: true,
                swarm: swarmInfo.Swarm.LocalNodeState === 'active'
            },
            terraform: fs.existsSync('/workspace/terraform.tfstate'),
            timestamp: new Date().toISOString()
        });
    } catch (error) {
        res.status(500).json({
            error: 'Failed to get system status',
            message: error.message
        });
    }
});

// Generate terraform configuration
app.post('/api/config/terraform', (req, res) => {
    try {
        const config = req.body;
        
        // Validate required fields
        const required = ['hetzner_token', 'domain', 'email', 'ssh_key_name'];
        for (let field of required) {
            if (!config[field]) {
                return res.status(400).json({
                    error: `Campo obrigatório ausente: ${field}`
                });
            }
        }

        // Generate terraform.tfvars content
        const tfvarsContent = `# ============================================================================
# CONFIGURAÇÃO DA INFRAESTRUTURA AIFOCUS SWARM
# Gerado automaticamente via Web Setup em ${new Date().toISOString()}
# ============================================================================

# Credenciais obrigatórias
hetzner_token = "${config.hetzner_token}"
domain = "${config.domain}"
email = "${config.email}"
ssh_key_name = "${config.ssh_key_name}"

# Configuração dos servidores
manager_count = ${config.manager_count || 3}
worker_count = ${config.worker_count || 2}
manager_server_type = "${config.manager_server_type || 'cx31'}"
worker_server_type = "${config.worker_server_type || 'cx21'}"

# Features
enable_load_balancer = ${config.enable_load_balancer ? 'true' : 'false'}
enable_volumes = ${config.enable_volumes ? 'true' : 'false'}

# Cloudflare (opcional)
${config.cloudflare_token ? `cloudflare_token = "${config.cloudflare_token}"` : '# cloudflare_token = ""'}

# Configurações de rede
network_ip_range = "10.0.0.0/16"
subnet_ip_range = "10.0.1.0/24"

# Configurações de segurança
allowed_ips = ["0.0.0.0/0"]
enable_firewall = true

# Features avançadas
enable_monitoring = ${config.enable_monitoring ? 'true' : 'false'}
enable_backups = true
volume_size = 50

# Tags
tags = {
  "Environment" = "Production"
  "Project"     = "AiFocus-Swarm"
  "ManagedBy"   = "Terraform"
  "Owner"       = "WebSetup"
  "CreatedBy"   = "setup.aifocus.dev"
}
`;

        // Write terraform.tfvars file
        fs.writeFileSync('/workspace/terraform.tfvars', tfvarsContent);

        res.json({
            success: true,
            message: 'Configuração Terraform gerada com sucesso',
            config_path: '/workspace/terraform.tfvars'
        });

    } catch (error) {
        console.error('Error generating terraform config:', error);
        res.status(500).json({
            error: 'Erro ao gerar configuração Terraform',
            message: error.message
        });
    }
});

// Deploy infrastructure
app.post('/api/deploy', (req, res) => {
    try {
        const config = req.body;
        
        // First generate terraform config
        const configResponse = generateTerraformConfig(config);
        if (!configResponse.success) {
            return res.status(400).json(configResponse);
        }

        // Set working directory
        process.chdir('/workspace');

        // Initialize deployment process
        const deploymentId = Date.now().toString();
        
        // Start deployment in background
        deployInfrastructure(deploymentId, config, (progress) => {
            // In a real implementation, you'd use WebSocket or SSE for real-time updates
            console.log(`Deployment ${deploymentId}: ${progress}`);
        });

        res.json({
            success: true,
            deployment_id: deploymentId,
            message: 'Deploy iniciado com sucesso',
            estimated_time: '8-12 minutos'
        });

    } catch (error) {
        console.error('Error starting deployment:', error);
        res.status(500).json({
            error: 'Erro ao iniciar deploy',
            message: error.message
        });
    }
});

// Get deployment status
app.get('/api/deploy/:id/status', (req, res) => {
    const deploymentId = req.params.id;
    
    try {
        // Check if terraform state exists
        const stateExists = fs.existsSync('/workspace/terraform.tfstate');
        const outputsExist = fs.existsSync('/workspace/terraform-outputs.txt');
        
        if (outputsExist) {
            const outputs = fs.readFileSync('/workspace/terraform-outputs.txt', 'utf8');
            res.json({
                status: 'completed',
                deployment_id: deploymentId,
                outputs: outputs,
                message: 'Deploy concluído com sucesso!'
            });
        } else if (stateExists) {
            res.json({
                status: 'in_progress',
                deployment_id: deploymentId,
                message: 'Deploy em andamento...'
            });
        } else {
            res.json({
                status: 'not_found',
                deployment_id: deploymentId,
                message: 'Deploy não encontrado'
            });
        }
    } catch (error) {
        res.status(500).json({
            error: 'Erro ao verificar status do deploy',
            message: error.message
        });
    }
});

// Get deployment logs
app.get('/api/deploy/:id/logs', (req, res) => {
    const deploymentId = req.params.id;
    const logFile = `/tmp/deployment-${deploymentId}.log`;
    
    try {
        if (fs.existsSync(logFile)) {
            const logs = fs.readFileSync(logFile, 'utf8');
            res.json({
                logs: logs.split('\n').filter(line => line.trim()),
                timestamp: new Date().toISOString()
            });
        } else {
            res.json({
                logs: ['Log file not found'],
                timestamp: new Date().toISOString()
            });
        }
    } catch (error) {
        res.status(500).json({
            error: 'Erro ao ler logs',
            message: error.message
        });
    }
});

// Utility function to generate terraform config
function generateTerraformConfig(config) {
    try {
        const required = ['hetzner_token', 'domain', 'email', 'ssh_key_name'];
        for (let field of required) {
            if (!config[field]) {
                return {
                    success: false,
                    error: `Campo obrigatório ausente: ${field}`
                };
            }
        }

        const tfvarsContent = `# Auto-generated by AiFocus Setup API
hetzner_token = "${config.hetzner_token}"
domain = "${config.domain}"
email = "${config.email}"
ssh_key_name = "${config.ssh_key_name}"
manager_count = ${config.manager_count || 3}
worker_count = ${config.worker_count || 2}
manager_server_type = "${config.manager_server_type || 'cx31'}"
worker_server_type = "${config.worker_server_type || 'cx21'}"
enable_load_balancer = ${config.enable_load_balancer ? 'true' : 'false'}
enable_volumes = ${config.enable_volumes ? 'true' : 'false'}
enable_monitoring = ${config.enable_monitoring ? 'true' : 'false'}
${config.cloudflare_token ? `cloudflare_token = "${config.cloudflare_token}"` : ''}
`;

        fs.writeFileSync('/workspace/terraform.tfvars', tfvarsContent);
        
        return {
            success: true,
            message: 'Configuração gerada com sucesso'
        };
    } catch (error) {
        return {
            success: false,
            error: error.message
        };
    }
}

// Utility function to deploy infrastructure
async function deployInfrastructure(deploymentId, config, progressCallback) {
    const logFile = `/tmp/deployment-${deploymentId}.log`;
    
    try {
        // Log deployment start
        fs.writeFileSync(logFile, `[${new Date().toISOString()}] Iniciando deploy da infraestrutura...\n`);
        progressCallback('Iniciando deploy...');

        // Terraform init
        fs.appendFileSync(logFile, `[${new Date().toISOString()}] Executando terraform init...\n`);
        progressCallback('Inicializando Terraform...');
        execSync('terraform init', { 
            cwd: '/workspace',
            stdio: 'pipe' 
        });

        // Terraform plan
        fs.appendFileSync(logFile, `[${new Date().toISOString()}] Executando terraform plan...\n`);
        progressCallback('Criando plano de execução...');
        execSync('terraform plan', { 
            cwd: '/workspace',
            stdio: 'pipe' 
        });

        // Terraform apply
        fs.appendFileSync(logFile, `[${new Date().toISOString()}] Executando terraform apply...\n`);
        progressCallback('Aplicando infraestrutura...');
        execSync('terraform apply -auto-approve', { 
            cwd: '/workspace',
            stdio: 'pipe' 
        });

        // Save outputs
        fs.appendFileSync(logFile, `[${new Date().toISOString()}] Salvando outputs...\n`);
        progressCallback('Salvando configurações...');
        const outputs = execSync('terraform output', { 
            cwd: '/workspace',
            encoding: 'utf8' 
        });
        fs.writeFileSync('/workspace/terraform-outputs.txt', outputs);

        fs.appendFileSync(logFile, `[${new Date().toISOString()}] Deploy concluído com sucesso!\n`);
        progressCallback('Deploy concluído!');

    } catch (error) {
        fs.appendFileSync(logFile, `[${new Date().toISOString()}] ERRO: ${error.message}\n`);
        progressCallback(`Erro: ${error.message}`);
        throw error;
    }
}

// Error handler
app.use((err, req, res, next) => {
    console.error('API Error:', err);
    res.status(500).json({
        error: 'Internal server error',
        message: err.message
    });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
    console.log(`AiFocus Setup API running on port ${PORT}`);
    console.log(`Health check: http://localhost:${PORT}/health`);
});

module.exports = app; 