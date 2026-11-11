#!/bin/bash
#
# sysutil.sh - Script de utilitários para o SysPDV PDV em Linux
#
# Versão: 7.0
# Autor: Matheus Wesley
# GitHub: https://matheuswesley.github.io/devlinks
# GitHub Projeto: https://matwdot.github.io
# Licença: MIT
#
# *************************************************************

# ---------------------
# Importações
# ---------------------
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"

# Precisa de root: se não for, reexecuta com sudo antes de carregar qualquer coisa
if [[ "$(id -u)" -ne 0 ]]; then
  echo "SysUtil precisa ser executado como root."
  if command -v sudo >/dev/null 2>&1; then
    echo "Reexecutando com sudo..."
    exec sudo bash "$SCRIPT_PATH" "$@"
  fi
  echo "ERRO: sudo não encontrado. Execute 'su -' (ou 'sudo su') e rode o sysutil de novo." >&2
  exit 1
fi

# Terminal desconhecido neste sistema (ex.: xterm-ghostty, xterm-kitty via SSH):
# sem isso o "clear" falha e o menu fica desenhado um embaixo do outro.
if ! tput -T "${TERM:-dumb}" clear >/dev/null 2>&1; then
  for t in xterm-256color xterm linux; do
    if tput -T "$t" clear >/dev/null 2>&1; then
      export TERM="$t"
      break
    fi
  done
fi

# Roda a partir da pasta do script, de qualquer lugar (alias, PATH ou link)
cd "$(dirname "$SCRIPT_PATH")" || exit 1

. ./colors.sh
. ./functions.sh

# ---------------------
# Menu de SysPDV PDV
# ---------------------
menu_syspdv() {
  local options=(
    "Instalar SysPDV PDV"
    "Atualizar SysPDV PDV"
    "Voltar"
  )
  
  local functions=(
    "instalar_syspdv"
    "atualizar_syspdv"
  )
  
  submenu "SysPDV PDV" "${options[@]}" -- "${functions[@]}"
}

# ---------------------
# Menu de VPN
# ---------------------
menu_vpn() {
  local options=(
    "Instalar VPN"
    "Remover VPN"
    "Voltar"
  )
  
  local functions=(
    "instalar_vpn"
    "remover_vpn"
  )
  
  submenu "VPN Comnect" "${options[@]}" -- "${functions[@]}"
}

# ---------------------
# Menu de MFe
# ---------------------
menu_mfe() {
  local options=(
    "Remover Driver MFe"
    "Voltar"
  )
  
  local functions=(
    "remover_drive_mfe"
  )
  
  submenu "MFe/DocGate" "${options[@]}" -- "${functions[@]}"
}

# ---------------------
# Menu principal
# ---------------------
main() {
  local options=(
    "SysPDV PDV"
    "VPN Comnect"
    "MFe/DocGate"
    "Configurar Periféricos"
    "Configurar Biométrico"
    "Limitar Consumo Tec55"
    "Transferência de Arquivos via SCP"
    "Manutenção via banco"
    "Sair"
  )
  
  local functions=(
    "menu_syspdv"
    "menu_vpn"
    "menu_mfe"
    "configurar_perifericos"
    "configurar_biometria"
    "limitar_consumo"
    "transferencia"
    "db_access"
    "exit_script"
  )
  
  local exit_index=$((${#options[@]} - 1))
  
  while true; do
    select_menu "Menu principal" "${options[@]}"
    local result=$?
    
    # Escolheu Sair (ou q/ESC)
    if [[ $result -eq $exit_index ]]; then
      clear
      exit 0
    fi
    
    # Verifica se o índice é válido
    if [[ $result -ge 0 && $result -lt ${#functions[@]} ]]; then
      local func="${functions[$result]}"
      
      # Funções de submenu não precisam de clear/pause
      if [[ "$func" == menu_* ]]; then
        $func
      else
        clear
        $func
        read -r -p "Pressione Enter para continuar..."
      fi
    else
      echo -e "${RED}Opção inválida!${NC}"
      sleep 1
    fi
  done
}

# ---------------------
# Executa o menu principal
# ---------------------
main