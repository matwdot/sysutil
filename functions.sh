#!/bin/bash
# ****************************************************************
# Script de Instalação/Atualização do SysPDV PDV para Linux
# Versão: 5.2
# Desenvolvido por: Matheus Wesley
# Contatos: https://matheuswesley.github.io/devlinks
#
# ****************************************************************
# Arquivo de Funções
#
# ****************************************************************

# ---------------------
# Importações
# ---------------------

. func/instalar_vpn.sh
. func/baixar_drive_mfe.sh

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

# Configura periféricos
configurar_perifericos() {

  # Função para exibir mensagens de erro e abortar a execução
  error_exit() {
    echo -e "${RED}$1${NC}" >&2
    exit 1
  }

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
      error_exit "Sublime Text não encontrado. Utilizando o editor padrão (nano)."
      editor="nano"
    fi

    # Define variaveis para os arquivos setty e 90-dispositivos
    setty=/usr/local/bin/setty
    dispositivos-usb=/etc/udev/rules.d/90-dispositivos-usb.rules

    if $editor $setty && $editor $dispositivos-usb; then
      echo -e "${GREEN}Arquivos abertos para configuração.${NC}"
      echo "Arquivo setty configura a porta serial. 90-dispositivos-usb.rules configura USB."
      # Esperar que o usuário termine de configurar
  	  echo -e "${YELLOW}Pressione Enter quando concluir a configuração.${NC}"
  	  read -p ""

  	  # Aplica permissão na pasta 
	  if ! sudo chmod +x "$setty"; then
	    error_exit "Erro ao aplicar permissão no arquivo $setty"
	    sleep 3
	  else
	  	sudo setty
	  fi


    else
      echo -e "${RED}Erro ao abrir os arquivos de configuração.${NC}"
    fi
  else
    echo -e "${RED}Configuração de periféricos cancelada.${NC}"
  fi
}


# Configura DocGate
configurar_docgate() {

  # Função para exibir mensagens de erro e abortar a execução
  error_exit() {
    echo -e "${RED}$1${NC}" >&2
    exit 1
  }
  error_msg() {
    echo -e "${RED}$1${NC}" >&2
  }

  # Pedir confirmação
  while true; do
    read -p "Deseja configurar o DocGate 5.0? (S/n): " confirm
    case "${confirm,,}" in
      s) break ;;  # '' aceita o valor padrão como 'S'
      n) echo "Operação cancelada."; sleep 2; return 1 ;;
      *) error_msg "Opção inválida. Digite S ou N." ;;
    esac
  done

  # Verificar se o arquivo tar.gz existe
  if [[ ! -f "dep/docgateV5.tar.gz" ]]; then
    error_exit "Arquivo dep/docgateV5.tar.gz não encontrado. Verifique o caminho e tente novamente."
  fi

  # Fazer backup do diretório DocGate existente
  if [[ -d "/opt/docgate" ]]; then
    echo -e "${YELLOW}Criando backup do DocGate atual...${NC}"
    sudo mv /opt/docgate /opt/docgate_backup || error_exit "Erro ao renomear o DocGate. Verifique as permissões."
  else
    echo -e "${BOLD}Nenhuma instalação anterior do DocGate encontrada. Continuando com a nova instalação...${NC}"
  fi

  # Extrair o novo DocGate
  echo -e "${BLUE}Extraindo o DocGate v5...${NC}"
  sudo tar -xf dep/docgateV5.tar.gz -C /opt || error_exit "Erro ao extrair o DocGate. Verifique o arquivo tar."

  # Mensagem de sucesso e instruções
  echo -e "${GREEN}Instalação do DocGate v5 realizada com sucesso.${NC}"
  echo -e "Por favor, acesse o menu ${BOLD}(Ctrl+Alt+Espaço)${NC}, vá em: ${BOLD}\nDispositivos - Ativar Compartilhamento MFE/SAT${NC}\ne selecione ${BOLD}'Ativado'.${NC}\nPressione Enter para continuar..."
  read -p ""
}

# Configura biometria
configurar_biometria() {
  # Função para exibir mensagens de erro
  error_msg() {
    echo -e "${RED}$1${NC}" >&2
  }

  # Função para exibir mensagens de erro e abortar a execução
  error_exit() {
    echo -e "${RED}$1${NC}" >&2
    exit 1
  }

  # Pedir confirmação para configurar a biometria
  while true; do
    echo -n -e "${YELLOW}Deseja configurar a biometria? (S/n): ${NC}"
    read confirm
    case "${confirm,,}" in
      s|S) break ;;  # '' aceita o valor padrão como 'S'
      n) echo "Operação cancelada."; return 1 ;;
      *) error_msg "Opção inválida. Digite S ou N." ;;
    esac
  done

  # Aplica permissão na pasta 
  BIOMETRIA_DIR=/opt/ServidorBiometrico/
  if ! sudo chmod 777 -R "$BIOMETRIA_DIR"; then
    error_exit "Erro ao aplicar permissão a pasta $BIOMETRIA_DIR."
    sleep 3
  fi


  # Verificar se o arquivo config.properties existe
  CONFIG_FILE="/opt/ServidorBiometrico/config.properties"
  if [[ ! -f "$CONFIG_FILE" ]]; then
    error_exit "Arquivo config.properties não encontrado em /opt/ServidorBiometrico. Verifique a instalação."
  fi

  # Abrir o arquivo de configuração
  echo -e "${YELLOW}Abrindo o arquivo de configuração do servidor biométrico...${NC}"
  sudo subl "$CONFIG_FILE" || error_exit "Erro ao abrir o arquivo de configuração."

  # Esperar que o usuário termine de configurar
  echo -e "${YELLOW}Pressione Enter quando concluir a configuração.${NC}"
  read -p ""

  # Executar o script e verificar se foi bem-sucedido
  echo -e "${YELLOW}Inicializando o servidor biométrico...${NC}"
  BIOMETRIA_SCRIPT="/opt/ServidorBiometrico/Scanner/iniciaBiometriaFH80.sh"
  if ! sudo "$BIOMETRIA_SCRIPT"; then
    error_exit "Erro ao inicializar o servidor biométrico."
  fi

  # Mensagem de sucesso
  echo -e "${GREEN}Configuração da biometria realizada com sucesso!${NC}"

}

# ------------------------------------

# Limitar Consumo Tec55
limitar_consumo() {
  # Função para exibir mensagens de erro
  error_msg() {
    echo -e "${RED}$1${NC}" >&2
  }

  # Função para exibir mensagens de erro e abortar a execução
  error_exit() {
    echo -e "${RED}$1${NC}" >&2
    exit 1
  }

  # Pedir confirmação para configurar o limitador de consumo
  while true; do
    echo -n -e "${YELLOW}Deseja configurar o limitador de consumo para o TEC55? (S/n): ${NC}"
    read confirm
    case "${confirm,,}" in
      s|S) break ;;  # '' aceita o valor padrão como 'S'
      n|N) echo "Operação cancelada."; return 1 ;;
      *) error_msg "Opção inválida. Digite S ou N." ;;
    esac
  done

  # Atualizar pacotes e instalar cpulimit
  echo -e "${YELLOW}Atualizando pacotes e instalando cpulimit...${NC}"
  sleep 2
  if ! sudo apt update && sudo apt install -y cpulimit; then
    error_msg "Erro ao atualizar pacotes ou instalar o cpulimit."
  fi

  # Dar permissão de execução aos arquivos e copiá-los
  echo -e "${YELLOW}Aplicando permissões e copiando arquivos...${NC}"
  sleep 2
  if ! sudo chmod +x -R dep/tec55/* && sudo cp -R dep/tec55/* /usr/local/bin; then
    error_exit "Erro ao copiar os arquivos..."
  fi

  # Aplicar permissões adequadas ao diretório /opt/Gertec55
  echo -e "${YELLOW}Aplicando permissões ao diretório /opt/Gertec55...${NC}"
    if sudo chmod 777 -R /opt/Gertec55; then
      echo -e "${GREEN}Permissões aplicadas com sucesso.${NC}"
      sleep 2
    else
      error_exit "Erro ao aplicar permissões ao diretório /opt/Gertec55."
    fi

  # Mensagem de sucesso
  echo -e "${GREEN}Configuração do limitador de consumo para o TEC55 realizada com sucesso.${NC}"
  echo "Pressione Enter para continuar!"
  read -p ""
}

# ------------------------------------

# Instala VPN


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
