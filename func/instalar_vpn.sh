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
instalar_vpn() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  local vpn_installer="${script_dir}/dep/wnbtlscli_2_5_1/simple-update.sh"

  if confirm_action "Deseja instalar a VPN?"; then
    info_msg "Iniciando a instalação da VPN..."
    
    # Verifica se o script de instalação existe
    if [ ! -f "$vpn_installer" ]; then
      error_msg "Script de instalação não encontrado: $vpn_installer"
      return 1
    fi
    
    # Executa o instalador passando o diretório como parâmetro
    local vpn_dir="${script_dir}/dep/wnbtlscli_2_5_1"
    if sudo bash "$vpn_installer" "$vpn_dir"; then
      # Verifica se precisa registrar a chave
      if [ ! -f "/etc/wnbtlscli/registry" ]; then
        info_msg "Informe a chave da VPN: "
        read -r key
        if [ -n "$key" ]; then
          sudo wnbupdate -k "$key" && sudo wnbmonitor -r
          success_msg "VPN instalada e registrada com sucesso!"
        else
          warning_msg "Chave não informada. Execute manualmente: sudo wnbupdate -k SUA_CHAVE"
        fi
      else
        success_msg "VPN instalada com sucesso!"
      fi
    else
      error_msg "Erro ao instalar a VPN. Verifique o log acima."
      return 1
    fi
  else
    info_msg "Instalação da VPN cancelada."
  fi
}
