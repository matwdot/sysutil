#!/bin/bash

# Cores
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # Sem cor

# Função para capturar entrada do teclado
get_input() {
  read -s -n 1 key  # Captura apenas um caractere
  if [[ $key == $'\x1b' ]]; then  # Se for uma sequência de escape
    read -s -n 2 key  # Captura o próximo caractere (setas enviam 3 caracteres)
  fi
  echo "$key"
}

# Função para exibir o menu com a opção selecionada
show_menu() {
  local highlight=$1
  options=("$@")
  options=("${options[@]:1}")  # Remove o primeiro argumento

  clear
  echo "--------------------------------"
  echo -e "\033[1m       SysUtil v5.1\033[0m"
  echo "--------------------------------"

  for i in "${!options[@]}"; do
    if [[ $i -eq $highlight ]]; then
      echo -e "${GREEN}> ${options[$i]}${NC}"  # Opção selecionada
    else
      echo "  ${options[$i]}"
    fi
  done

  echo "--------------------------------"
  echo -e "Use\033[1m Enter\033[0m para selecionar, \033[1m0 ou q\033[0m para sair."
  echo "--------------------------------"
}

# Função principal para controlar a navegação no menu
navigate_menu() {
  local options=("$@")
  local current_selection=0

  while true; do
    show_menu "$current_selection" "${options[@]}"

    case $(get_input) in
      '[A')  # Tecla para cima (up)
        if ((current_selection > 0)); then
          ((current_selection--))
        fi
        ;;
      '[B')  # Tecla para baixo (down)
        if ((current_selection < ${#options[@]} - 1)); then
          ((current_selection++))
        fi
        ;;
      '')  # Enter
        return $current_selection
        ;;
      '0' | 'q')  # Tecla 0 ou q para sair
        clear
        exit 0
        ;;
    esac
  done
}

# Opções do menu
options=(
  "Instalar SysPDV PDV"
  "Atualizar SysPDV PDV"
  "Instalar VPN"
  "Instalar Driver MFe"
  "Configurar Periféricos"
  "Configurar DocGate (dev)"
  "Configurar Biométrico (dev)"
  "Transferência de Arquivos via SCP (dev)"
  "Sair"
)

# Executar o menu
while true; do
  navigate_menu "${options[@]}"
  selected_option=$?

  case $selected_option in
    0) clear; instalar_syspdv; echo -e "${GREEN}Instalação concluída!${NC}" ;;
    1) clear; atualizar_syspdv; echo -e "${GREEN}Atualização concluída!${NC}" ;;
    2) clear; instalar_vpn ;;
    3) clear; baixar_drive_mfe ;;
    4) clear; configurar_perifericos ;;
    5) echo -e "${YELLOW}Configurar DocGate (dev) ainda não implementado.${NC}" ;;
    6) echo -e "${YELLOW}Configurar Biométrico (dev) ainda não implementado.${NC}" ;;
    7) echo -e "${YELLOW}Transferência de Arquivos via SCP (dev) ainda não implementado.${NC}" ;;
    8) clear; exit 0 ;;
    *) echo -e "${RED}Opção inválida!${NC}"; sleep 1; clear ;;
  esac
done
