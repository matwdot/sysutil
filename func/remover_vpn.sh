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
# **************************************************************

# Instala VPN
remover_vpn() {
  if confirm_action "Deseja remover a VPN?"; then
    info_msg "Iniciando a remoção da VPN..."
    
    if ! sudo wnbmonitor --version > /dev/null 2>&1; then
      error_msg "Erro ao remover a VPN. Provavelmente já esteja removida."
      sleep 2
    else
      info_msg "Iniciando..."
      warning_msg "Realizando o backup da chave, se houver."
      
      if ! sudo cat /etc/wnbtlscli/registry > chave.txt; then
        error_msg "Erro ao salvar a chave."
      fi
      
      warning_msg "Removendo a VPN"
      if sudo dpkg --purge wnbtlscli && sudo apt remove -y wnbmonitor && sudo apt remove -y wnbtlscli; then
        warning_msg "Apagando as pastas"
        sudo rm -rf /etc/wnbtlscli /var/log/wnb
        sleep 2
        success_msg "VPN removida com sucesso. Por favor, reinicie o computador!"
      else
        error_msg "Erro ao remover os pacotes da VPN."
      fi
    fi
  else
    info_msg "Remoção da VPN cancelada."
  fi
}