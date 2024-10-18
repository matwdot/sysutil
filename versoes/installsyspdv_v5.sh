#!/bin/bash
# ****************************************************************
# Script de Instalação/Atualização do SysPDV PDV para Linux
# Versão: 4.0
# Desenvolvido por: Matheus Wesley
# Contatos: https://matheuswesley.github.io/devlinks
# ****************************************************************

# ---------------------
# Variáveis de cores
# ---------------------
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
BG_PURPLE='\033[45;1;37m'
NC='\033[0m' # Sem cor

# ---------------------
# Funções principais
# ---------------------

# Verifica e instala dependências
requisitos(){
  echo "Verificando dependências..."
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

# Baixa a build do SysPDV
baixar_build() {
  read -p "Informe a BUILD para download: " build
  URL="https://objectstorage.us-ashburn-1.oraclecloud.com/n/casamagalhaes/b/syspdv/o/b$build/InstaladorSysPDV19_0_0_$build.exe"

  if ! [[ $URL =~ ^https://.* ]]; then
    echo -e "${RED}URL inválida.${NC}"
    return 1
  fi

  read -p "Informe o diretório (padrão: /home/pdv/Downloads): " DESTINO
  DESTINO=${DESTINO:-/home/pdv/Downloads}
  ARQUIVO="$DESTINO/InstaladorSysPDV19_0_0_$build.exe"

  echo -e "${YELLOW}Baixando a BUILD${NC} ${RED}$build${NC}${YELLOW} para ${NC}${GREEN}$DESTINO${NC}${YELLOW}. Aguarde!!${NC}"

  curl --progress-bar --location --fail --output "$ARQUIVO" "$URL"
  if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}A BUILD $build foi baixada com sucesso.${NC}"
    echo -e "${YELLOW}Iniciando instalação...${NC}"
    chmod +x "$ARQUIVO"
    wine "$ARQUIVO"
  else
    echo -e "${RED}Falha no download: ${NC}"
  fi
}

# Baixa e instala o Driver MFe
baixar_drive_mfe() {
  read -p "Informe a versão do driver (padrão: 02.05.18): " VERSAO
  VERSAO=${VERSAO:-02.05.18}
  URL="http://servicos.sefaz.ce.gov.br/internet/download/projetomfe/instalador-ce-sefaz-driver-linux-x86-$VERSAO.tar.gz"
  read -p "Informe o diretório (padrão: /home/pdv/Downloads): " DESTINO
  DESTINO=${DESTINO:-/home/pdv/Downloads}
  ARQUIVO="$DESTINO/instalador-ce-sefaz-driver-linux-x86-$VERSAO.tar.gz"
  DIR_EXTRACAO="$DESTINO"

  echo -e "${YELLOW}Baixando o Driver MFe${NC} ${RED}v$VERSAO${NC}${YELLOW} para ${NC}${GREEN}$DESTINO${NC}${YELLOW}. Aguarde!${NC}"

  curl --progress-bar --location --fail --output "$ARQUIVO" "$URL"
  if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}O Driver MFe foi baixado com sucesso.${NC}"
    echo -e "${YELLOW}Descompactando...${NC}"
    tar -xf "$ARQUIVO" -C "$DIR_EXTRACAO"
    echo -e "${YELLOW}Iniciando instalação...${NC}"
    if [ $? -eq 0 ]; then
      if cd "$DIR_EXTRACAO/instalador-ce-sefaz-driver-linux-x86-$VERSAO"; then
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

    rm "$ARQUIVO"  # Remover arquivo baixado
  else
    echo -e "${RED}Falha no download.${NC}"
  fi
}

# Configura periféricos
configurar_perifericos() {
  echo -n -e "${YELLOW}Deseja configurar os periféricos? (S/n): ${NC}"
  read confirm
  while [[ "$confirm" != "S" && "$confirm" != "N" && "$confirm" != "s" && "$confirm" != "n" ]]; do
    echo -n -e "${RED}Opção inválida. (S = Sim | N = Não): ${NC}"
    read confirm
  done

  if [[ "$confirm" =~ [sS] ]]; then
    if command -v subl &> /dev/null; then
      editor="subl"
    else
      echo -e "${YELLOW}Sublime Text não encontrado. Utilizando o editor padrão (nano).${NC}"
      editor="nano"
    fi

    if $editor /usr/local/bin/setty && $editor /etc/udev/rules.d/90-dispositivos-usb.rules; then
      echo -e "${GREEN}Arquivos abertos para configuração.${NC}"
      echo "Arquivo setty configura a porta serial. 90-dispositivos-usb.rules configura USB."
    else
      echo -e "${RED}Erro ao abrir os arquivos de configuração.${NC}"
    fi
  else
    echo -e "${RED}Configuração de periféricos cancelada.${NC}"
  fi
}

# Instala VPN
instalar_vpn() {
  echo -n -e "${YELLOW}Deseja instalar a VPN? (S/n): ${NC}"
  read confirm
  while [[ "$confirm" != "S" && "$confirm" != "N" && "$confirm" != "s" && "$confirm" != "n" ]]; do
    read -p "${RED}Opção inválida. (S = Sim | N = Não): ${NC}" confirm
  done

  if [[ "$confirm" =~ [sS] ]]; then
    echo "Iniciando a instalação da VPN..."
    if ! sudo ./dep/wnbinstall.sh -i; then
      echo -e "${RED}Erro ao instalar a VPN. Verifique permissões e tente novamente.${NC}"
    else
      echo -n -e "${GREEN}Informe a chave da VPN: ${NC}"
      read key
      sudo wnbmonitor -k "$key" && sudo wnbmonitor -r
      echo -e "${GREEN}VPN instalada com sucesso!${NC}"
    fi
  else
    echo -e "${RED}Configuração da VPN cancelada.${NC}"
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
  read -p "Deseja atualizar o SysPDV? (S/n): " confirm

  if [[ "$confirm" == "" || "$confirm" == "S" || "$confirm" == "s" ]]; then
    baixar_build
  else
    echo "Atualização cancelada!"
  fi
}

# ---------------------
# Menu principal
# ---------------------
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
  read -p "Escolha uma opção: " opc

  case $opc in
    1) clear; instalar_syspdv; echo -e "${GREEN}Instalação concluída!${NC}" ;;
    2) clear; atualizar_syspdv; echo -e "${GREEN}Atualização concluída!${NC}" ;;
    3) clear; instalar_vpn ;;
    4) clear; baixar_drive_mfe ;;
    5) clear; configurar_perifericos ;;
    0 | q) clear; exit ;;
    *) echo -e "${RED}Opção inválida!${NC}"; sleep 1; clear ;;
  esac
done
