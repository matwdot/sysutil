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

# Baixa e instala o Driver MFe
remover_drive_mfe() {
  if confirm_action "Deseja remover o Drive MFe?"; then
    if cd /opt/sefaz/cco/; then
      if sudo ./remove-driver.sh; then
        sudo rm -rf /opt/sefaz
        success_msg "Driver MFe removido com sucesso."
        sleep 5
      else
        error_msg "Erro ao executar o script de remoção do driver MFe."
      fi
    else
      error_msg "Erro: Diretório /opt/sefaz/cco/ não encontrado."
    fi
  else
    error_msg "Remoção do Driver MFe cancelada."
  fi
}

