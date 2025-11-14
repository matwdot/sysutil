#!/bin/bash
#
# sysutil.sh - Script de utilitários para o SysPDV PDV em Linux
#
# Versão: 5.2
# Autor: Matheus Wesley
# GitHub: https://matheuswesley.github.io/devlinks
# GitHub Projeto: https://matwdot.github.
# Licença: MIT
#
# Este script contém um conjunto de funções para instalação, atualização e
# manutenção do sistema SysPDV PDV em ambientes Linux.
#
# *************************************************************

# Variáveis
DIR_SYSPDV='/opt/Syspdv'
DIR_BACKUP=
CAD='syspdv_cad.fdb'
MOV='syspdv_mov.fdb'


# Realiza o backup dos FDBs
fazer_backup_fdb() {
  if confirm_action "Deseja realizar backup do CAD e MOV?"; then
    if cd $DIR_SYSPDV; then

      if sudo mkdir -p backup_fdbs; then
        info_msg "Criando pasta de backups"
      else
        error_msg "Erro ao criar pasta de backups"
      fi

      if sudo cp $CAD backup_fdbs; then
        info_msg "syspdv_cad.fdb - Salvo com sucesso!"
      else
        error_msg "Erro ao salvar o arquivo syspdv_cad.fdb"
      fi

      if sudo cp $MOV backup_fdbs; then
        info_msg "syspdv_mov.fdb - Salvo com sucesso!"
      else
        error_msg "Erro ao salvar o arquivo syspdv_cad.fdb"
      fi

      success_msg "Copia de segurança realizada com sucesso"

      sleep 2
    else
      error_msg "Erro: Diretório /opt/Syspdv não encontrado."
      sleep 2
    fi
  else
    error_msg "Processo de backup cancelado."
    sleep 2
  fi
}

