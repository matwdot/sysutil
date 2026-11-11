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

# Remove a VPN (guarda a chave antes de apagar)
remover_vpn() {
  if confirm_action "Deseja remover a VPN?"; then
    info_msg "Iniciando a remoção da VPN..."
    
    if ! sudo wnbmonitor --version > /dev/null 2>&1; then
      error_msg "Erro ao remover a VPN. Provavelmente já esteja removida."
      sleep 2
    else
      info_msg "Iniciando..."
      warning_msg "Realizando o backup da chave, se houver."

      local registry="/etc/wnbtlscli/registry"
      local key_dir="$HOME/.sysutil" chave
      chave="$key_dir/chave_vpn_$(date +%Y%m%d_%H%M%S).txt"
      mkdir -p "$key_dir" && chmod 700 "$key_dir"
      if sudo test -f "$registry"; then
        # install -m 600: copia como root e deixa a chave legível só pelo dono
        if sudo install -m 600 "$registry" "$chave" && [[ -s "$chave" ]]; then
          info_msg "Chave salva em: $chave"
        else
          error_msg "Erro ao salvar a chave. Remoção cancelada para não perdê-la."
          return 1
        fi
      else
        warning_msg "Nenhuma chave encontrada em $registry."
      fi

      warning_msg "Removendo a VPN"
      local pacote falhou=0
      for pacote in wnbtlscli wnbmonitor; do
        if dpkg -s "$pacote" > /dev/null 2>&1; then
          sudo dpkg --purge "$pacote" || falhou=1
        fi
      done

      if [[ $falhou -eq 0 ]]; then
        warning_msg "Apagando as pastas"
        sudo rm -rf /etc/wnbtlscli /var/log/wnb
        sleep 2
        success_msg "VPN removida com sucesso. Por favor, reinicie o computador!"
      else
        error_msg "Erro ao remover os pacotes da VPN."
        return 1
      fi
    fi
  else
    info_msg "Remoção da VPN cancelada."
  fi
}