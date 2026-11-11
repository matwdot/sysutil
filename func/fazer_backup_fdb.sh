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
CAD='syspdv_cad.fdb'
MOV='syspdv_mov.fdb'


# Realiza o backup dos FDBs
# Retorno: 0 = backup feito, 1 = falha, 2 = cancelado pelo usuário
fazer_backup_fdb() {
  if ! confirm_action "Deseja realizar backup do CAD e MOV?"; then
    error_msg "Processo de backup cancelado."
    sleep 2
    return 2
  fi

  if [[ ! -d "$DIR_SYSPDV" ]]; then
    error_msg "Erro: Diretório $DIR_SYSPDV não encontrado."
    sleep 2
    return 1
  fi

  local destino stamp arquivo origem copia
  stamp=$(date +%Y%m%d_%H%M%S)
  destino="$DIR_SYSPDV/backup_fdbs"

  if ! sudo mkdir -p "$destino"; then
    error_msg "Erro ao criar pasta de backups"
    sleep 2
    return 1
  fi
  info_msg "Pasta de backups: $destino"

  for arquivo in "$CAD" "$MOV"; do
    origem="$DIR_SYSPDV/$arquivo"
    copia="$destino/${arquivo%.fdb}_${stamp}.fdb"
    if sudo cp "$origem" "$copia" && [[ -s "$copia" ]]; then
      info_msg "$arquivo - Salvo com sucesso!"
    else
      error_msg "Erro ao salvar o arquivo $arquivo"
      sudo rm -f "$copia"
      sleep 2
      return 1
    fi
  done

  success_msg "Copia de segurança realizada com sucesso"
  sleep 2
  return 0
}
