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
# *************************************************************

# Import utilities if not loaded
if [[ -z "$(type -t error_msg)" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck source=utils/utilities.sh
  source "${SCRIPT_DIR}/utils/utilities.sh" || {
    echo "ERRO: Não foi possível carregar utilities.sh"
    exit 1
  }
fi

# Variáveis
DIR_SYSPDV='/opt/Syspdv'
CAD='syspdv_cad.fdb'
MOV='syspdv_mov.fdb'


# Realiza o backup dos FDBs
fazer_backup_fdb() {
  if confirm_action "Deseja realizar backup do CAD e MOV?"; then
    if cd "$DIR_SYSPDV"; then

      if ! sudo mkdir -p backup_fdbs; then
        error_msg "Erro ao criar pasta de backups"
        return 1
      fi
      info_msg "Criando pasta de backups"

      if ! sudo cp "$CAD" backup_fdbs/; then
        error_msg "Erro ao salvar o arquivo $CAD"
        return 1
      fi
      info_msg "syspdv_cad.fdb - Salvo com sucesso!"

      if ! sudo cp "$MOV" backup_fdbs/; then
        error_msg "Erro ao salvar o arquivo $MOV"
        return 1
      fi
      info_msg "syspdv_mov.fdb - Salvo com sucesso!"

      success_msg "Copia de segurança realizada com sucesso"
    else
      error_msg "Erro: Diretório /opt/Syspdv não encontrado."
    fi
  else
    error_msg "Processo de backup cancelado."
  fi
}

