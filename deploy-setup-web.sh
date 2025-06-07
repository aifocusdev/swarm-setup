#!/bin/bash

# ============================================================================
# AIFOCUS SWARM - DEPLOY SETUP WEB
# Script para fazer deploy da interface web do setup
# ============================================================================

# Cores para output
verde="\033[32m"
amarelo="\033[33m"
vermelho="\033[31m"
azul="\033[34m"
magenta="\033[35m"
ciano="\033[36m"
branco="\033[37m"
reset="\033[0m"

clear
echo -e "$ciano===================================================================================================$reset"
echo -e "$verde 🌐 DEPLOY DO SETUP WEB - setup.aifocus.dev $reset"
echo -e "$ciano===================================================================================================$reset"
echo ""

instalar_setup_web(){
    echo -e "$amarelo 🚀 Fazendo deploy da interface web do setup... $reset"
    echo ""
    
    # Verificar se estamos em um Docker Swarm
    if ! docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null | grep -q "active"; then
        echo -e "$vermelho ❌ Este servidor não faz parte de um Docker Swarm! $reset"
        echo -e "$amarelo Execute primeiro: 'Gerenciar Swarm' → 'Inicializar Swarm' $reset"
        echo ""
        read -p "Pressione ENTER para continuar..."
        return 1
    fi
    
    # Verificar se o Traefik está rodando
    if ! docker service ls | grep -q "traefik"; then
        echo -e "$vermelho ❌ Traefik não está rodando! $reset"
        echo -e "$amarelo Execute primeiro: 'Instalar Stacks' → 'Traefik' $reset"
        echo ""
        read -p "Pressione ENTER para continuar..."
        return 1
    fi
    
    echo -e "$amarelo 📋 Configurando setup web para: setup.aifocus.dev $reset"
    echo ""
    
    # Criar diretórios necessários
    echo -e "$amarelo 📁 Criando diretórios... $reset"
    mkdir -p /opt/aifocus/setup-web
    mkdir -p /opt/aifocus/setup-api
    
    # Copiar arquivos da interface web
    echo -e "$amarelo 📄 Copiando arquivos da interface... $reset"
    if [ -f "setup-web/index.html" ]; then
        cp -r setup-web/* /opt/aifocus/setup-web/
        echo -e "$verde ✅ Interface web copiada! $reset"
    else
        echo -e "$vermelho ❌ Arquivos da interface não encontrados! $reset"
        return 1
    fi
    
    # Copiar arquivos da API
    echo -e "$amarelo 🔧 Copiando arquivos da API... $reset"
    if [ -f "setup-api/server.js" ]; then
        cp -r setup-api/* /opt/aifocus/setup-api/
        echo -e "$verde ✅ API copiada! $reset"
    else
        echo -e "$vermelho ❌ Arquivos da API não encontrados! $reset"
        return 1
    fi
    
    # Fazer deploy do stack
    echo -e "$amarelo 🚀 Fazendo deploy do stack... $reset"
    cd /opt/aifocus
    
    if docker stack deploy -c /opt/aifocus/setup-web.yml setup-web; then
        echo -e "$verde ✅ Setup web deployado com sucesso! $reset"
        echo ""
        echo -e "$ciano ================================================ $reset"
        echo -e "$verde 🎉 SETUP WEB ATIVO! $reset"
        echo -e "$ciano ================================================ $reset"
        echo ""
        echo -e "$amarelo 🌐 Interface disponível em: $reset"
        echo -e "$branco   https://setup.aifocus.dev $reset"
        echo ""
        echo -e "$amarelo 📋 Próximos passos: $reset"
        echo -e "$branco   1. Configure o DNS setup.aifocus.dev → seu_load_balancer_ip $reset"
        echo -e "$branco   2. Aguarde 1-2 minutos para SSL automático $reset"
        echo -e "$branco   3. Acesse a interface web para setup $reset"
        echo ""
        echo -e "$amarelo 🔧 Para verificar status: $reset"
        echo -e "$branco   docker service ls | grep setup $reset"
        echo ""
        echo -e "$amarelo 📊 Para ver logs: $reset"
        echo -e "$branco   docker service logs setup-web_setup-web --follow $reset"
        echo -e "$branco   docker service logs setup-web_setup-api --follow $reset"
        
    else
        echo -e "$vermelho ❌ Erro ao fazer deploy do setup web! $reset"
        return 1
    fi
    
    echo ""
    read -p "Pressione ENTER para continuar..."
}

verificar_dns_setup(){
    echo -e "$amarelo 🔍 Verificando configuração DNS... $reset"
    echo ""
    
    # Verificar se conseguimos resolver o DNS
    if nslookup setup.aifocus.dev > /dev/null 2>&1; then
        echo -e "$verde ✅ DNS setup.aifocus.dev está configurado! $reset"
        
        # Verificar se aponta para nosso IP
        SETUP_IP=$(nslookup setup.aifocus.dev | grep "Address:" | tail -1 | cut -d' ' -f2)
        SERVER_IP=$(curl -s ifconfig.me)
        
        echo -e "$amarelo DNS aponta para: $SETUP_IP $reset"
        echo -e "$amarelo Nosso IP público: $SERVER_IP $reset"
        
        if [ "$SETUP_IP" = "$SERVER_IP" ]; then
            echo -e "$verde ✅ DNS configurado corretamente! $reset"
        else
            echo -e "$amarelo ⚠️  DNS não aponta para este servidor $reset"
            echo -e "$amarelo Configure: setup.aifocus.dev → $SERVER_IP $reset"
        fi
    else
        echo -e "$vermelho ❌ DNS setup.aifocus.dev não configurado! $reset"
        echo -e "$amarelo Configure no seu provedor DNS: $reset"
        echo -e "$branco   Tipo: A $reset"
        echo -e "$branco   Nome: setup $reset"
        echo -e "$branco   Valor: $(curl -s ifconfig.me) $reset"
    fi
    
    echo ""
    read -p "Pressione ENTER para continuar..."
}

remover_setup_web(){
    echo -e "$amarelo 🗑️  Removendo setup web... $reset"
    echo ""
    
    read -p "Tem certeza que deseja remover o setup web? (y/n): " confirma
    
    if [ "$confirma" = "y" ] || [ "$confirma" = "Y" ]; then
        docker stack rm setup-web
        echo -e "$verde ✅ Setup web removido! $reset"
    else
        echo -e "$amarelo Operação cancelada. $reset"
    fi
    
    echo ""
    read -p "Pressione ENTER para continuar..."
}

mostrar_info_setup(){
    echo -e "$ciano===================================================================================================$reset"
    echo -e "$verde 📋 INFORMAÇÕES DO SETUP WEB $reset"
    echo -e "$ciano===================================================================================================$reset"
    echo ""
    
    # Verificar se está rodando
    if docker service ls | grep -q "setup-web"; then
        echo -e "$verde ✅ Setup Web está ATIVO $reset"
        echo ""
        echo -e "$amarelo 🌐 URLs disponíveis: $reset"
        echo -e "$branco   Interface: https://setup.aifocus.dev $reset"
        echo -e "$branco   API: https://setup.aifocus.dev/api $reset"
        echo -e "$branco   Health: https://setup.aifocus.dev/health $reset"
        echo ""
        
        echo -e "$amarelo 📊 Status dos serviços: $reset"
        docker service ls | grep setup
        echo ""
        
        echo -e "$amarelo 🔧 Comandos úteis: $reset"
        echo -e "$branco   Logs interface: docker service logs setup-web_setup-web --follow $reset"
        echo -e "$branco   Logs API: docker service logs setup-web_setup-api --follow $reset"
        echo -e "$branco   Restart: docker service update --force setup-web_setup-web $reset"
        
    else
        echo -e "$vermelho ❌ Setup Web NÃO está rodando $reset"
        echo ""
        echo -e "$amarelo Para instalar: $reset"
        echo -e "$branco   ./deploy-setup-web.sh $reset"
    fi
    
    echo ""
    read -p "Pressione ENTER para continuar..."
}

# Menu principal
menu_setup_web(){
    while true; do
        clear
        echo -e "$ciano===================================================================================================$reset"
        echo -e "$verde 🌐 GERENCIAR SETUP WEB - setup.aifocus.dev $reset"
        echo -e "$ciano===================================================================================================$reset"
        echo ""
        echo -e "$amarelo Escolha uma opção: $reset"
        echo ""
        echo -e "$branco 1) Instalar Setup Web $reset"
        echo -e "$branco 2) Verificar DNS $reset"
        echo -e "$branco 3) Mostrar Informações $reset"
        echo -e "$branco 4) Remover Setup Web $reset"
        echo ""
        echo -e "$branco 0) Voltar $reset"
        echo ""
        echo -n -e "$amarelo Digite sua opção: $reset"
        read opcao
        
        case $opcao in
            1) instalar_setup_web ;;
            2) verificar_dns_setup ;;
            3) mostrar_info_setup ;;
            4) remover_setup_web ;;
            0) break ;;
            *) echo -e "$vermelho Opção inválida! $reset" && sleep 2 ;;
        esac
    done
}

# Se executado diretamente
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    # Verificar se estamos no diretório correto
    if [ ! -f "setup-web.yml" ]; then
        echo -e "$vermelho ❌ Arquivo setup-web.yml não encontrado! $reset"
        echo -e "$amarelo Execute este script do diretório que contém os arquivos do projeto. $reset"
        exit 1
    fi
    
    menu_setup_web
fi 