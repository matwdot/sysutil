#!/bin/bash
#
# sysutil.sh - Script de utilitários para o SysPDV PDV em Linux
#
# Versão: 8.0
# Autor: Matheus Wesley
# GitHub: https://matheuswesley.github.io/devlinks
# GitHub Projeto: https://matwdot.github.
# Licença: MIT
#
# Este script contém um conjunto de funções para instalação, atualização e
# manutenção do sistema SysPDV PDV em ambientes Linux.
#
# **************************************************************

# Import utilities if not loaded
if [[ -z "$(type -t error_msg)" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck source=utils/utilities.sh
  source "${SCRIPT_DIR}/utils/utilities.sh" || {
    echo "ERRO: Não foi possível carregar utilities.sh"
    exit 1
  }
fi

# Instala VPN
remover_vpn() {
  if confirm_action "Deseja remover a VPN?"; then
    info_msg "Iniciando a remoção da VPN..."
    
    if ! sudo wnbmonitor --version > /dev/null 2>&1; then
      error_msg "Erro ao remover a VPN. Provavelmente já esteja removida."
    else
      info_msg "Iniciando..."
      warning_msg "Realizando o backup da chave, se houver."
      
      local key_dir="$HOME/.sysutil"
      mkdir -p "$key_dir" 2>/dev/null
      if ! sudo cat /etc/wnbtlscli/registry > "$key_dir/chave.txt" 2>/dev/null; then
        error_msg "Erro ao salvar a chave."
      else
        chmod 600 "$key_dir/chave.txt"
      fi
      
      warning_msg "Removendo a VPN"
      if sudo dpkg --purge wnbtlscli && sudo apt remove -y wnbmonitor && sudo apt remove -y wnbtlscli; then
        warning_msg "Apagando as pastas"
        sudo rm -rf /etc/wnbtlscli /var/log/wnb
        success_msg "VPN removida com sucesso. Por favor, reinicie o computador!"
      else
        error_msg "Erro ao remover os pacotes da VPN."
      fi
    fi
  else
    info_msg "Remoção da VPN cancelada."
  fi
}