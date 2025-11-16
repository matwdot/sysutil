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


# Define o nome do arquivo de log
LOG_FILE="requisitos.txt"

# A função requisitos agora só usa "echo" simples
requisitos() {
  echo "Verificando dependências..."

  # 1. curl
  if ! command -v curl &>/dev/null; then
    echo "Instalando curl..."
    sudo apt update && sudo apt install -y curl
    if [ $? -eq 0 ]; then
      echo "O curl foi instalado com sucesso."
    else
      echo "Falha na instalação do curl."
      exit 1
    fi
  else
    echo "dep: curl -> OK"
  fi
  
  # 2. libnotify (notify-send)
  if ! command -v notify-send &>/dev/null; then
    echo "Instalando libnotify-bin (para notify-send)..."
    sudo apt update && sudo apt install -y libnotify-bin
    if [ $? -eq 0 ]; then
      echo "O notify-send foi instalado com sucesso."
    else
      echo "Falha na instalação do notify-send."
      exit 1
    fi
  else
    echo "dep: libnotify-bin -> OK"
  fi
  
  sleep 2
  echo "Verificação de dependências concluída."
}

requisitos > "$LOG_FILE" 2>&1