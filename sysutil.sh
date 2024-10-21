#!/bin/bash
# ****************************************************************
# Script de Instalação/Atualização do SysPDV PDV para Linux
# Versão: 5.2
# Desenvolvido por: Matheus Wesley
# Contatos: https://matheuswesley.github.io/devlinks
#
# ****************************************************************
# Arquivo principal
#
# ****************************************************************

# ---------------------
# Importações
# ---------------------
. ./functions.sh
. ./colors.sh


# ---------------------
# Menu principal
# ---------------------

# Função para capturar entrada do teclado
get_input() {
  read -s -n 1 key  # Captura apenas um caractere
  if [[ $key == $'\x1b' ]]; then  # Se for uma sequência de escape
    read -s -n 2 key  # Captura o próximo caractere (setas enviam 3 caracteres)
  fi
  echo "$key"
}

# Função de exibição do menu interativo
show_menu() {
  local highlight=$1
  options=("$@")
  options=("${options[@]:1}")

  clear
  echo "------------------------------------------"
  echo -e "${BOLD}              SysUtil v5.2${NC}"
  echo "------------------------------------------"

  for i in "${!options[@]}"; do
    if [[ $i -eq $highlight ]]; then
      echo -e "${GREEN}> ${options[$i]}${NC}"
    else
      echo "  ${options[$i]}"
    fi
  done

  echo "------------------------------------------"
  echo -e "Navegue com ${BOLD}↑${NC}/${BOLD}↓${NC} e selecione com ${BOLD}Enter${NC}."
  echo "------------------------------------------"

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
    5) clear; echo -e "${YELLOW}Configurar DocGate (dev) ainda não implementado.${NC}"; sleep 2 ;;
    6) clear; echo -e "${YELLOW}Configurar Biométrico (dev) ainda não implementado.${NC}"; sleep 2 ;;
    7) clear; echo -e "${YELLOW}Transferência de Arquivos via SCP (dev) ainda não implementado.${NC}"; sleep 2 ;;
    8) clear; exit 0 ;;
    *) echo -e "${RED}Opção inválida!${NC}"; sleep 1; clear ;;
  esac
done