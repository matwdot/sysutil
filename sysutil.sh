#!/bin/bash
#
# sysutil.sh - Script de utilitários para o SysPDV PDV em Linux
#
# Versão: 6.0
# Autor: Matheus Wesley
# GitHub: https://matheuswesley.github.io/devlinks
# GitHub Projeto: https://matwdot.github.
# Licença: MIT
#
# *************************************************************

# ---------------------
# Importações
# ---------------------
. ./functions.sh
. ./colors.sh
. ./func/utils/create_alias.sh

# ---------------------
# Função para capturar entrada do teclado
# ---------------------
get_input() {
  read -s -n 1 key
  if [[ $key == $'\x1b' ]]; then
    read -s -n 2 key
  fi
  echo "$key"
}

# Função de exibição do menu interativo
show_menu() {
  local highlight=$1
  shift
  local options=("$@")

  clear
  echo "------------------------------------------"
  echo -e "${BOLD}           SysUtil v7.0 beta${NC}"
  echo "------------------------------------------"

  for i in "${!options[@]}"; do
    if [[ $i -eq $highlight ]]; then
      [[ "${options[$i]}" == "Sair" ]] && echo -e "${RED}✘ ${options[$i]}${NC}" || echo -e "${GREEN}➜ ${options[$i]}${NC}"
    else
      echo "  ${options[$i]}"
    fi
  done

  echo "------------------------------------------"
  echo -e "Navegue com ${BOLD}↑${NC}/${BOLD}↓${NC} e selecione com ${BOLD}Enter${NC}."
  echo "------------------------------------------"
}

navigate_menu() {
  local options=("$@")
  local current_selection=0

  while true; do
    show_menu "$current_selection" "${options[@]}"
    case $(get_input) in
    '[A') ((current_selection > 0)) && ((current_selection--)) ;;
    '[B') ((current_selection < ${#options[@]} - 1)) && ((current_selection++)) ;;
    '') return $current_selection ;;
    '0' | 'q')
      clear
      exit 0
      ;;
    esac
  done
}

# Função para menu de SysPDV PDV
menu_syspdv() {
  local syspdv_options=(
    "Instalar SysPDV PDV"
    "Atualizar SysPDV PDV"
    "Voltar"
  )
  while true; do
    navigate_menu "${syspdv_options[@]}"
    case $? in
    0)
      clear
      instalar_syspdv
      echo -e "${GREEN}Instalação concluída!${NC}"
      ;;
    1)
      clear
      atualizar_syspdv
      echo -e "${GREEN}Atualização concluída!${NC}"
      ;;
    2) return ;;
    esac
  done
}

# Função para menu de VPN
menu_vpn() {
  local vpn_options=(
    "Instalar VPN"
    "Remover VPN"
    "Voltar"
  )
  while true; do
    navigate_menu "${vpn_options[@]}"
    case $? in
    0)
      clear
      instalar_vpn
      echo -e "${GREEN}VPN instalada com sucesso!${NC}"
      ;;
    1)
      clear
      remover_vpn
      echo -e "${GREEN}VPN removida com sucesso!${NC}"
      ;;
    2) return ;;
    esac
  done
}

# Função para menu de MFe
menu_mfe() {
  local mfe_options=(
    "Instalar Driver MFe"
    "Remover Driver MFe"
    "Configurar DocGate"
    "Voltar"
  )
  while true; do
    navigate_menu "${mfe_options[@]}"
    case $? in
    0)
      clear
      baixar_drive_mfe
      echo -e "${GREEN}MFe instalado com sucesso!${NC}"
      ;;
    1)
      clear
      remover_drive_mfe
      echo -e "${GREEN}MFe removido com sucesso!${NC}"
      ;;
    2)
      clear
      configurar_docgate
      echo -e "${GREEN}DocGate configurado com sucesso!${NC}"
      ;;
    3) return ;;
    esac
  done
}

# Menu principal
options=(
  "SysPDV PDV"
  "VPN Comnect"
  "MFe/DocGate"
  "Configurar Periféricos"
  "Configurar Biométrico"
  "Limitar Consumo Tec55"
  "Transferência de Arquivos via SCP"
  "Sair"
)

while true; do
  navigate_menu "${options[@]}"
  case $? in
  0) menu_syspdv ;;
  1) menu_vpn ;;
  2) menu_mfe ;;
  3)
    clear
    configurar_perifericos
    ;;
  4)
    clear
    configurar_biometria
    ;;
  5)
    clear
    limitar_consumo
    ;;
  6)
    clear
    transferencia
    ;;
  7)
    clear
    exit 0
    ;;
  *)
    echo -e "${RED}Opção inválida!${NC}"
    sleep 1
    clear
    ;;
  esac
done
