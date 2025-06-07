#!/bin/bash

## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                    AIFOCUS COMPANY SWARM                                    ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

## Cores
amarelo="\e[33m"
verde="\e[32m"
branco="\e[97m"
bege="\e[93m"
vermelho="\e[91m"
azul="\e[34m"
ciano="\e[36m"
reset="\e[0m"

## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                    AIFOCUS COMPANY SWARM                                    ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

sudo apt update > /dev/null 2>&1
sudo apt upgrade -y > /dev/null 2>&1

## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                    AIFOCUS COMPANY SWARM                                    ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

nome_aifocus(){
clear
echo ""
echo -e "$ciano===================================================================================================$reset"
echo -e "$ciano=                                                                                                 $ciano=$reset"
echo -e "$ciano=           $branco █████╗ ██╗    ███████╗ ██████╗  ██████╗██╗   ██╗███████╗                        $ciano=$reset"
echo -e "$ciano=           $branco██╔══██╗██║    ██╔════╝██╔═══██╗██╔════╝██║   ██║██╔════╝                        $ciano=$reset"
echo -e "$ciano=           $branco███████║██║    █████╗  ██║   ██║██║     ██║   ██║███████╗                        $ciano=$reset"
echo -e "$ciano=           $branco██╔══██║██║    ██╔══╝  ██║   ██║██║     ██║   ██║╚════██║                        $ciano=$reset"
echo -e "$ciano=           $branco██║  ██║██║    ██║     ╚██████╔╝╚██████╗╚██████╔╝███████║                        $ciano=$reset"
echo -e "$ciano=           $branco╚═╝  ╚═╝╚═╝    ╚═╝      ╚═════╝  ╚═════╝ ╚═════╝ ╚══════╝                        $ciano=$reset"
echo -e "$ciano=                                                                                                 $ciano=$reset"
echo -e "$ciano=                    $amarelo ██████╗ ██████╗ ███╗   ███╗██████╗  █████╗ ███╗   ██╗██╗   ██╗             $ciano=$reset"
echo -e "$ciano=                    $amarelo██╔════╝██╔═══██╗████╗ ████║██╔══██╗██╔══██╗████╗  ██║╚██╗ ██╔╝             $ciano=$reset"
echo -e "$ciano=                    $amarelo██║     ██║   ██║██╔████╔██║██████╔╝███████║██╔██╗ ██║ ╚████╔╝              $ciano=$reset"
echo -e "$ciano=                    $amarelo██║     ██║   ██║██║╚██╔╝██║██╔═══╝ ██╔══██║██║╚██╗██║  ╚██╔╝               $ciano=$reset"
echo -e "$ciano=                    $amarelo╚██████╗╚██████╔╝██║ ╚═╝ ██║██║     ██║  ██║██║ ╚████║   ██║                $ciano=$reset"
echo -e "$ciano=                    $amarelo ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝                $ciano=$reset"
echo -e "$ciano=                                                                                                 $ciano=$reset"
echo -e "$ciano=                                  $verde DOCKER SWARM EDITION                                       $ciano=$reset"
echo -e "$ciano===================================================================================================$reset"
echo ""
echo ""
}

nome_atualizando(){
    clear
    echo ""
    echo -e "$ciano===================================================================================================$reset"
    echo -e "$ciano=                                                                                                 $ciano=$reset"
    echo -e "$ciano=    $branco  █████╗ ████████╗██╗   ██╗ █████╗ ██╗     ██╗███████╗ █████╗ ███╗   ██╗██████╗  ██████╗     $ciano=$reset"
    echo -e "$ciano=    $branco ██╔══██╗╚══██╔══╝██║   ██║██╔══██╗██║     ██║╚══███╔╝██╔══██╗████╗  ██║██╔══██╗██╔═══██╗    $ciano=$reset"
    echo -e "$ciano=    $branco ███████║   ██║   ██║   ██║███████║██║     ██║  ███╔╝ ███████║██╔██╗ ██║██║  ██║██║   ██║    $ciano=$reset"
    echo -e "$ciano=    $branco ██╔══██║   ██║   ██║   ██║██╔══██║██║     ██║ ███╔╝  ██╔══██║██║╚██╗██║██║  ██║██║   ██║    $ciano=$reset"
    echo -e "$ciano=    $branco ██║  ██║   ██║   ╚██████╔╝██║  ██║███████╗██║███████╗██║  ██║██║ ╚████║██████╔╝╚██████╔╝    $ciano=$reset"
    echo -e "$ciano=    $branco ╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝  ╚═════╝     $ciano=$reset"
    echo -e "$ciano=                                                                                                 $ciano=$reset"
    echo -e "$ciano=                                      $amarelo AIFOCUS COMPANY                                        $ciano=$reset"
    echo -e "$ciano===================================================================================================$reset"
    echo ""
    echo ""
}

nome_iniciando(){
    clear
    echo ""
    echo -e "$ciano===================================================================================================$reset"
    echo -e "$ciano=                                                                                                 $ciano=$reset"
    echo -e "$ciano=                  $branco ██╗███╗   ██╗██╗ ██████╗██╗ █████╗ ███╗   ██╗██████╗  ██████╗                 $ciano=$reset"
    echo -e "$ciano=                  $branco ██║████╗  ██║██║██╔════╝██║██╔══██╗████╗  ██║██╔══██╗██╔═══██╗                $ciano=$reset"
    echo -e "$ciano=                  $branco ██║██╔██╗ ██║██║██║     ██║███████║██╔██╗ ██║██║  ██║██║   ██║                $ciano=$reset"
    echo -e "$ciano=                  $branco ██║██║╚██╗██║██║██║     ██║██╔══██║██║╚██╗██║██║  ██║██║   ██║                $ciano=$reset"
    echo -e "$ciano=                  $branco ██║██║ ╚████║██║╚██████╗██║██║  ██║██║ ╚████║██████╔╝╚██████╔╝                $ciano=$reset"
    echo -e "$ciano=                  $branco ╚═╝╚═╝  ╚═══╝╚═╝ ╚═════╝╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝  ╚═════╝                 $ciano=$reset"
    echo -e "$ciano=                                          $verde SWARM v. 3.0.0                                        $ciano=$reset"
    echo -e "$ciano=                                      $amarelo AIFOCUS COMPANY                                        $ciano=$reset"
    echo -e "$ciano===================================================================================================$reset"
    echo ""
    echo ""
}

nome_verificando(){
    clear
    echo ""
    echo -e "$ciano===================================================================================================$reset"
    echo -e "$ciano=                                                                                                 $ciano=$reset"
    echo -e "$ciano=       $branco ██╗   ██╗███████╗██████╗ ██╗███████╗██╗ ██████╗ █████╗ ███╗   ██╗██████╗  ██████╗       $ciano=$reset"
    echo -e "$ciano=       $branco ██║   ██║██╔════╝██╔══██╗██║██╔════╝██║██╔════╝██╔══██╗████╗  ██║██╔══██╗██╔═══██╗      $ciano=$reset"
    echo -e "$ciano=       $branco ██║   ██║█████╗  ██████╔╝██║█████╗  ██║██║     ███████║██╔██╗ ██║██║  ██║██║   ██║      $ciano=$reset"
    echo -e "$ciano=       $branco ╚██╗ ██╔╝██╔══╝  ██╔══██╗██║██╔══╝  ██║██║     ██╔══██║██║╚██╗██║██║  ██║██║   ██║      $ciano=$reset"
    echo -e "$ciano=       $branco  ╚████╔╝ ███████╗██║  ██║██║██║     ██║╚██████╗██║  ██║██║ ╚████║██████╔╝╚██████╔╝      $ciano=$reset"
    echo -e "$ciano=       $branco   ╚═══╝  ╚══════╝╚═╝  ╚═╝╚═╝╚═╝     ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝  ╚═════╝       $ciano=$reset"
    echo -e "$ciano=                                                                                                 $ciano=$reset"
    echo -e "$ciano=                                      $amarelo AIFOCUS COMPANY                                        $ciano=$reset"
    echo -e "$ciano===================================================================================================$reset"
    echo ""
    echo ""
}

nome_infrastructure(){
    clear
    echo ""
    echo -e "$ciano===================================================================================================$reset"
    echo -e "$ciano=                                                                                                 $ciano=$reset"
    echo -e "$ciano=     $branco ██╗███╗   ██╗███████╗██████╗  █████╗ ███████╗████████╗██████╗ ██╗   ██╗ ██████╗████████╗   $ciano=$reset"
    echo -e "$ciano=     $branco ██║████╗  ██║██╔════╝██╔══██╗██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██║   ██║██╔════╝╚══██╔══╝   $ciano=$reset"
    echo -e "$ciano=     $branco ██║██╔██╗ ██║█████╗  ██████╔╝███████║███████╗   ██║   ██████╔╝██║   ██║██║        ██║      $ciano=$reset"
    echo -e "$ciano=     $branco ██║██║╚██╗██║██╔══╝  ██╔══██╗██╔══██║╚════██║   ██║   ██╔══██╗██║   ██║██║        ██║      $ciano=$reset"
    echo -e "$ciano=     $branco ██║██║ ╚████║██║     ██║  ██║██║  ██║███████║   ██║   ██║  ██║╚██████╔╝╚██████╗   ██║      $ciano=$reset"
    echo -e "$ciano=     $branco ╚═╝╚═╝  ╚═══╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝  ╚═════╝   ╚═╝      $ciano=$reset"
    echo -e "$ciano=                                                                                                 $ciano=$reset"
    echo -e "$ciano=                                      $amarelo AIFOCUS COMPANY                                        $ciano=$reset"
    echo -e "$ciano===================================================================================================$reset"
    echo ""
    echo ""
}

nome_swarm(){
    clear
    echo ""
    echo -e "$ciano===================================================================================================$reset"
    echo -e "$ciano=                                                                                                 $ciano=$reset"
    echo -e "$ciano=                      $branco ███████╗██╗    ██╗ █████╗ ██████╗ ███╗   ███╗                           $ciano=$reset"
    echo -e "$ciano=                      $branco ██╔════╝██║    ██║██╔══██╗██╔══██╗████╗ ████║                           $ciano=$reset"
    echo -e "$ciano=                      $branco ███████╗██║ █╗ ██║███████║██████╔╝██╔████╔██║                           $ciano=$reset"
    echo -e "$ciano=                      $branco ╚════██║██║███╗██║██╔══██║██╔══██╗██║╚██╔╝██║                           $ciano=$reset"
    echo -e "$ciano=                      $branco ███████║╚███╔███╔╝██║  ██║██║  ██║██║ ╚═╝ ██║                           $ciano=$reset"
    echo -e "$ciano=                      $branco ╚══════╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝                           $ciano=$reset"
    echo -e "$ciano=                                                                                                 $ciano=$reset"
    echo -e "$ciano=                                      $amarelo AIFOCUS COMPANY                                        $ciano=$reset"
    echo -e "$ciano===================================================================================================$reset"
    echo ""
    echo ""
}

## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                    AIFOCUS COMPANY SWARM                                    ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

desc_ver(){
echo -e "                        Este script recomenda o uso do Ubuntu$amarelo 20.04$branco para infraestrutura Swarm.$reset"
echo ""
echo -e "                        $verde✅ Infraestrutura automatizada com Terraform$reset"
echo -e "                        $verde✅ Docker Swarm com 3 servidores + Load Balancer$reset"
echo -e "                        $verde✅ Alta disponibilidade e escalabilidade$reset"
echo -e "                        $verde✅ Rede interna segura entre servidores$reset"
echo ""
} 

## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                    AIFOCUS COMPANY SWARM                                    ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

clear
nome_verificando
echo "Aguarde enquanto verificamos as informações do sistema e preparamos o ambiente Swarm."
sleep 2

# Verifica se está usando Ubuntu 20.04
if ! grep -q 'Ubuntu 20.04' /etc/os-release; then
    nome_aifocus
    desc_ver
    sleep 5
    clear
    nome_verificando
fi

# Verifica se o usuário é root
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script precisa ser executado como root. Executando sudo su..."
    sudo su
fi

# Verifica se o usuário está no diretório /root/
if [ "$PWD" != "/root" ]; then
    echo "Mudando para o diretório /root/"
    cd /root || exit
fi

## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                    AIFOCUS COMPANY SWARM                                    ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

nome_iniciando 

## Fazendo upgrade
sudo apt upgrade -y > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "1/18 - [ OK ] - Fazendo Upgrade do Sistema"
else
    echo "1/18 - [ OFF ] - Fazendo Upgrade do Sistema"
fi

echo ""

## Instalando Sudo
apt install sudo -y > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "2/18 - [ OK ] - Verificando/Instalando sudo"
else
    echo "2/18 - [ OFF ] - Verificando/Instalando sudo"
fi

echo ""

## Instalando apt-utils
sudo apt-get install -y apt-utils > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "3/18 - [ OK ] - Verificando/Instalando apt-utils"
else
    echo "3/18 - [ OFF ] - Verificando/Instalando apt-utils"
fi

echo ""

## Instalando dialog
sudo apt-get install -y dialog > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "4/18 - [ OK ] - Verificando/Instalando dialog"
else
    echo "4/18 - [ OFF ] - Verificando/Instalando dialog"
fi

echo ""

## Instalando jq
sudo apt-get install -y jq > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "5/18 - [ OK ] - Verificando/Instalando jq 1/2"
else
    echo "5/18 - [ OFF ] - Verificando/Instalando jq 1/2"
fi

echo ""

## Instalando jq
sudo apt install jq -y > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "6/18 - [ OK ] - Verificando/Instalando jq 2/2"
else
    echo "6/18 - [ OFF ] - Verificando/Instalando jq 2/2"
fi

echo ""

## Instalando apache2-utils
sudo apt install apache2-utils -y > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "7/18 - [ OK ] - Verificando/Instalando apache2-utils 1/2"
else
    echo "7/18 - [ OFF ] - Verificando/Instalando apache2-utils 1/2"
fi

echo ""

## Instalando apache2-utils
apt install apache2-utils -y > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "8/18 - [ OK ] - Verificando/Instalando apache2-utils 2/2"
else
    echo "8/18 - [ OFF ] - Verificando/Instalando apache2-utils 2/2"
fi

echo ""

## Instalando git
apt install git -y > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "9/18 - [ OK ] - Verificando/Instalando Git"
else
    echo "9/18 - [ OFF ] - Verificando/Instalando Git"
fi

echo ""

## Instalando python3
apt install python3 -y > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "10/18 - [ OK ] - Verificando/Instalando python3"
else
    echo "10/18 - [ OFF ] - Verificando/Instalando python3"
fi

echo ""

## Instalando curl
apt install curl -y > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "11/18 - [ OK ] - Verificando/Instalando curl"
else
    echo "11/18 - [ OFF ] - Verificando/Instalando curl"
fi

echo ""

## Instalando unzip
apt install unzip -y > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "12/18 - [ OK ] - Verificando/Instalando unzip"
else
    echo "12/18 - [ OFF ] - Verificando/Instalando unzip"
fi

echo ""

## Instalando Docker
curl -fsSL https://get.docker.com | bash > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "13/18 - [ OK ] - Instalando Docker Engine"
else
    echo "13/18 - [ OFF ] - Instalando Docker Engine"
fi

echo ""

## Instalando Terraform
wget -q https://releases.hashicorp.com/terraform/1.8.0/terraform_1.8.0_linux_amd64.zip > /dev/null 2>&1
unzip -q terraform_1.8.0_linux_amd64.zip > /dev/null 2>&1
sudo mv terraform /usr/local/bin/ > /dev/null 2>&1
rm terraform_1.8.0_linux_amd64.zip > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "14/18 - [ OK ] - Instalando Terraform"
else
    echo "14/18 - [ OFF ] - Instalando Terraform"
fi

echo ""

## Fazendo update
sudo apt update > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "15/18 - [ OK ] - Fazendo Update"
else
    echo "15/18 - [ OFF ] - Fazendo Update"
fi

echo ""

## Fazendo upgrade
sudo apt upgrade -y > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "16/18 - [ OK ] - Fazendo Upgrade Final"
else
    echo "16/18 - [ OFF ] - Fazendo Upgrade Final"
fi

echo ""

## Instalando neofetch
apt install neofetch -y > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "17/18 - [ OK ] - Verificando/Instalando neofetch"
else
    echo "17/18 - [ OFF ] - Verificando/Instalando neofetch"
fi

echo ""

# Verifica se o arquivo AiFocusSwarm já existe
if [ -e "AiFocusSwarm" ]; then
    echo ""
    rm AiFocusSwarm
fi

# Baixa o script principal do AiFocus Swarm
curl -sSL https://raw.githubusercontent.com/aifocusdev/AiFocusSwarm/main/AiFocusSwarm -o AiFocusSwarm
if [ $? -eq 0 ]; then
    echo "18/18 - [ OK ] - Baixando AiFocus Swarm Script"
    # Executa o script baixado
    chmod +x AiFocusSwarm
    ./AiFocusSwarm
else
    echo "18/18 - [ OFF ] - Baixando AiFocus Swarm Script"
    echo "Encerrando o setup. Verifique sua conexão com a internet."
    sleep 5
fi

## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                    AIFOCUS COMPANY SWARM                                    ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

echo ""
echo -e "$verde========================================$reset"
echo -e "$verde  AIFOCUS COMPANY SWARM PREPARADO!    $reset"
echo -e "$verde========================================$reset"
echo ""

sudo apt update > /dev/null 2>&1
sudo apt upgrade -y > /dev/null 2>&1

clear
rm AiFocusSwarm > /dev/null 2>&1