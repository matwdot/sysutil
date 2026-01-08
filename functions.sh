#!/bin/bash
#
# sysutil.sh - Script de utilitários para o SysPDV PDV em Linux
#
# Versão: 7.0
# Autor: Matheus Wesley
# GitHub: https://matheuswesley.github.io/devlinks
# GitHub Projeto: https://matwdot.github.
# Licença: MIT
#
# Este script contém um conjunto de funções para instalação, atualização e
# manutenção do sistema SysPDV PDV em ambientes Linux.
#
# *************************************************************

# IMPORTAÇÕES
# shellcheck disable=SC1091

. func/instalar_vpn.sh
. func/remover_vpn.sh
. func/remover_drive_mfe.sh
. func/configurar_perifericos.sh
. func/configurar_biometria.sh
. func/baixar_build.sh
. func/limitar_consumo.sh
# . func/requisitos.sh
. func/transferencia.sh
. func/db.sh
. func/fazer_backup_fdb.sh

# Utilitários
. func/utils/utilities.sh
. func/utils/menu_system.sh

# FUNÇÕES

# Instalar o SysPDV (Pacote Completo)
instalar_syspdv() {

  if confirm_action "Deseja instalar o SysPDV PDV?"; then
    info_msg "Iniciando a instalação do SysPDV"
    baixar_build
    configurar_perifericos
    instalar_vpn
  else
    error_msg "Instalação do SysPDV cancelada"
  fi
}

# Atualizar o SysPDV (Baixa e roda o instalador apenas)
atualizar_syspdv() {
  if confirm_action "Deseja atualizar o SysPDV PDV?"; then
    info_msg "Iniciando a atualização do SysPDV"
    fazer_backup_fdb
    baixar_build
  else
    error_msg "Instalação cancelada."
  fi
}
