#!/bin/bash
# ****************************************************************
#
# Script de Instalação/Atualização do SysPDV PDV nos Caixas Linux
# Versão: 4.0
# Desenvolvido por: Matheus Wesley
# Contatos: https://matheuswesley.github.io/devlinks
#
# ****************************************************************

# --------------------
# **** Variaveis *****
# --------------------

# Cores
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
BG_PURPLE='\033[45;1;37m'
NC='\033[0m' # Sem cor

# --------------------
# **** Funções *******
# --------------------

# Verifica se os programas estão instalados e instala caso não
requisitos(){

  echo "Verificando dependencias..."

  # curl
  if ! command -v curl &> /dev/null; then
    echo "Instalando curl"
    sudo apt update && sudo apt install -y curl
    if [ $? -eq 0 ]; then
      echo "O curl foi instalado com sucesso."
    else
      echo "Falha na instalação do curl."
      exit 1
    fi
  else
    echo -e "${GREEN}dep: curl -> OK${NC}"
  fi

}

# Função para baixar a BUILD
baixar_build() {
    # Solicitar a BUILD e validar a URL
    read -p "Informe a BUILD para download: " build
    URL="https://objectstorage.us-ashburn-1.oraclecloud.com/n/casamagalhaes/b/syspdv/o/b$build/InstaladorSysPDV19_0_0_$build.exe"

    # Verificar se a URL possui o formato esperado (exemplo básico)
    if ! [[ $URL =~ ^https://.* ]]; then
        echo -e "${RED}URL inválida.${NC}"
        return 1
    fi

    # Solicitar o diretório para salvar o arquivo
    read -p "Informe o diretório: (Pasta padrão é /pdv/Downloads): " DESTINO
    DESTINO=${DESTINO:-/home/pdv/Downloads}

    # Construir o nome do arquivo completo
    ARQUIVO="$DESTINO/InstaladorSysPDV19_0_0_$build.exe"

    echo -e "${YELLOW}Baixando a BUILD${NC} ${RED}$build${NC}${YELLOW} para ${NC}${GREEN}$DESTINO${NC}${YELLOW}. Aguarde!!${NC}"

    # Aqui está realizando o download do instalador
    curl --progress-bar --location --fail --output "$ARQUIVO" "$URL"

    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}A BUILD: $build foi baixada com sucesso.${NC}"
        echo -e "${YELLOW}Iniciando instalação...${NC}"
        chmod +x "$ARQUIVO"
        wine "$ARQUIVO"
    else
        echo -e "${RED}Falha no download: ${NC}"
    fi
}

# Função para baixar o drive MFe
baixar_drive_mfe() {
    # Solicitar a versão do driver
    read -p "Informe a versão do driver (padrão: 02.05.18): " VERSAO
    VERSAO=${VERSAO:-02.05.18}

    # URL de Download do Driver MFe
    URL="http://servicos.sefaz.ce.gov.br/internet/download/projetomfe/instalador-ce-sefaz-driver-linux-x86-$VERSAO.tar.gz"

    # Solicitar o diretório para salvar o arquivo
    read -p "Informe o diretório (padrão: /home/pdv/Downloads): " DESTINO
    DESTINO=${DESTINO:-/home/pdv/Downloads}

    # Construir o nome do arquivo completo
    ARQUIVO="$DESTINO/instalador-ce-sefaz-driver-linux-x86-$VERSAO.tar.gz"
    DIR_EXTRACAO="$DESTINO"

    echo -e "${YELLOW}Baixando o Driver MFe${NC} ${RED}v$VERSAO${NC}${YELLOW} para ${NC}${GREEN}$DESTINO${NC}${YELLOW}. Aguarde!${NC}"

    # Baixar o arquivo com barra de progresso detalhada
    curl --progress-bar --location --fail --output "$ARQUIVO" "$URL"

    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}O Driver MFe foi baixado com sucesso.${NC}"
        echo -e "${YELLOW}Iniciando instalação...${NC}"
        # mkdir -p "$DIR_EXTRACAO"
        
        # Extrair o arquivo
        tar -xvf "$ARQUIVO" -C "$DIR_EXTRACAO"
        if [ $? -eq 0 ]; then
            # Verificar se o diretório foi alterado com sucesso
            if cd "$DIR_EXTRACAO/instalador-ce-sefaz-driver-linux-x86-$VERSAO"; then
                # Verificar se o script de instalação existe e tem permissão de execução
                if [ -x "./instala-driver.sh" ]; then
                    sudo ./instala-driver.sh 
                    if [ $? -eq 0 ]; then
                        echo -e "${GREEN}Instalação concluída com sucesso.${NC}"
                        sleep 2
                    else
                        echo -e "${RED}Erro durante a instalação do driver.${NC}"
                        sleep 2
                    fi
                else
                    echo -e "${RED}Erro: o script de instalação não foi encontrado ou não é executável.${NC}"
                    sleep 2
                fi
            else
                echo -e "${RED}Erro: falha ao acessar o diretório de extração.${NC}"
                sleep 2
            fi
        else
            echo -e "${RED}Erro ao extrair o arquivo.${NC}"
            sleep 2
        fi

        # Agora pode remover o arquivo baixado
        rm "$ARQUIVO"
        # rm -rf "$DIR_EXTRACAO"  # Descomentar para remover o diretório após a instalação
    else
        echo -e "${RED}Falha no download.${NC}"
    fi
}


# Função que abre arquivos de configuração dos perifericos
configurar_perifericos() {
    echo -n -e "${YELLOW}Deseja configurar os periféricos? (S/n): ${NC}"
    read confirm

    # Validação da resposta
    while [[ "$confirm" != "S" && "$confirm" != "N" && "$confirm" != "s" && "$confirm" != "n" ]]; do
        echo -n -e "${RED}Opção inválida. (S = Sim | N = Não): ${NC}"
        read confirm
    done

    if [[ "$confirm" == "S" || "$confirm" == "s" ]]; then
        # Verificar se o Sublime Text está instalado
        if command -v subl &> /dev/null; then
            editor="subl"
        else
            echo -e "${YELLOW}Sublime Text não encontrado. Utilizando o editor padrão (nano).${NC}"
            editor="vi"
        fi

        # Abrir os arquivos e verificar se foram abertos com sucesso
        if $editor /usr/local/bin/setty && $editor /etc/udev/rules.d/90-dispositivos-usb.rules; then
            echo -e "${GREEN}Arquivos abertos para configuração. ${NC}"
            echo "O arquivo setty configura a porta serial. O arquivo 90-dispositivos-usb.rules configura dispositivos USB."
        else
            echo -e "${RED}Erro ao abrir os arquivos de configuração.${NC}"
        fi
    else
        echo -e "${RED}Configuração de periféricos cancelada.${NC}"
    fi
}


# Função para instalar a VPN
instalar_vpn() {
    echo -n -e "${YELLOW}Deseja instalar a VPN? (S/n): ${NC}"
    read confirm

    # Validação mais robusta da resposta
    while [[ "$confirm" != "S" && "$confirm" != "N" && "$confirm" != "s" && "$confirm" != "n" ]]; do
        echo -n -e "${RED}Opção inválida. (S = Sim | N = Não): ${NC}"
        read confirm
    done

    if [[ "$confirm" == "S" || "$confirm" == "s" ]]; then
        echo -e "Iniciando a instalação da VPN..."
        if ! sudo ./dep/wnbinstall.sh -i; then
            echo -e "${RED}Erro ao instalar a VPN. Verifique as permissões e tente novamente.${NC}"
        else
            echo -n -e "${GREEN}Informe a chave da VPN: ${NC}"
            read key
            sudo wnbmonitor -k  $key && sudo wnbmonitor -r
            echo -e "${GREEN}VPN instalada com sucesso!${NC}"
        fi
    else
        echo -e "${RED}Configuração da VPN cancelada.${NC}"
    fi
}

# Função para instalar a Drive MFe
instalar_drive_mfe() {
    echo -n -e "${YELLOW}Deseja instalar o Drive MFe? (S/n): ${NC}"
    read confirm

    # Validação mais robusta da resposta
    while [[ "$confirm" != "S" && "$confirm" != "N" && "$confirm" != "s" && "$confirm" != "n" ]]; do
        echo -n -e "${RED}Opção inválida. (S = Sim | N = Não): ${NC}"
        read confirm
    done

    if [[ "$confirm" == "S" || "$confirm" == "s" ]]; then
        baixar_drive_mfe
    else
        echo -e "${RED}Instalação Drive MFE cancelada.${NC}"
    fi
}

# Função para instalar o SysPDV
instalar_syspdv() {
  requisitos
  read -p "Deseja instalar o SysPDV? (S/n): " confirm

  if [[ "$confirm" == "" || "$confirm" == "S" || "$confirm" == "s" ]]; then
    baixar_build
    configurar_perifericos
    instalar_vpn
    instalar_drive_mfe  
  else
    echo "Instalação cancelada!"
  fi
}

# Função para atualizar o SysPDV
atualizar_syspdv() {
  read -p "Deseja atualizar o SysPDV? (S/n) " confirm

  if [[ "$confirm" == "" || "$confirm" == "S" || "$confirm" == "s" ]]; then
    baixar_build
  else
    echo "Atualização cancelada!"
  fi
}

# --------------------
# ****** MENU ********
# --------------------
while true; do
  clear
  echo "--------------------------------"
  echo -e "\033[1m            SysPDV\033[0m"
  echo "--------------------------------"
  echo "1. Instalar SysPDV PDV"
  echo "2. Atualizar SysPDV PDV"
  echo "--------------------------------"
  echo -e "\033[1m          Utilitários\033[0m"
  echo "--------------------------------"
  echo "3. Instalar VPN"
  echo "4. Instalar Driver MFe"
  echo "5. Configurar Periféricos"
  echo "6. Configurar DocGate (dev)"
  echo "7. Configurar Biométrico (dev)"
  echo "8. Transferência de Arquivos via SCP (dev)"
  echo "--------------------------------"
  echo -e "Use\033[1m 0 ou q\033[0m para sair."
  echo "--------------------------------"
  echo ""
  read -p "Escolha uma opção: " opc



  case $opc in
  1)
    # Instalação do SysPDV (PDV, VPN MFE, Perifericos)
    clear
    instalar_syspdv
    echo -e "${GREEN}Instalação concluída!${DONE_ICON}${NC}"
    ;;
  2)
    # Atualização de versão
    clear
    atualizar_syspdv
    echo -e "${GREEN}Atualização concluída!${DONE_ICON}${NC}"
    ;;
  3)
    # Instalação da VPN
    clear
    instalar_vpn
    ;;
  4)
    # Instalar Drive MFe
    clear
    instalar_drive_mfe    
    ;;
  5)
    # Configurar Perifericos
    clear
    configurar_perifericos
    ;;
  0 | q)
    # Fechar o script 0 ou q
    clear
    exit
    ;;
  *)
    echo -e "${RED}Opção inválida!! ${INVALID_ICON}${NC}"
    sleep 1
    clear
    ;;
  esac
done
