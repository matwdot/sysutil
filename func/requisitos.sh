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

# Requisitos
requisitos() {
  echo "Verificando dependências..."
  if ! command -v curl &>/dev/null; then
    echo "Instalando curl"
    sudo apt update && sudo apt install -y curl
    if [ $? -eq 0 ]; then
      echo "O curl foi instalado com sucesso."
    else
      echo "Falha na instalação do curl."
      exit 1
    fi
  else
    echo -e "${GREEN}dep: curl -> OK${NC}"
  fi
  # libnotify
  if ! command -v notify-send &>/dev/null; then
    echo "Instalando libnotify"
    sudo apt update && sudo apt install -y libnotify-bin
    if [ $? -eq 0 ]; then
      echo "O notify-send foi instalado com sucesso."
    else
      echo "Falha na instalação do notify-send."
      exit 1
    fi
  else
    echo -e "${GREEN}dep: curl -> OK${NC}"
    echo -e "${GREEN}dep: libnotify -> OK${NC}"
  fi
  sleep 2

}

# Execução da função
requisitos
