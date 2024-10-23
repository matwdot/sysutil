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
instalar_vpn() {

  if confirm_action "Deseja instalar a VPN?"; then
    info_msg "Iniciando a instalação da VPN..."
    if ! sudo ./dep/wnbinstall.sh -i; then
      error_msg "Erro ao instalar a VPN. Verifique permissões e tente novamente."
      sleep 2
    else
      info_msg "Informe a chave da VPN: "
      read -r key
      sudo wnbmonitor -k "$key" && sudo wnbmonitor -r
      sleep 2
      success_msg "VPN instalada com sucesso!"
    fi
  else
    info_msg "Configuração da VPN cancelada."
  fi
}
