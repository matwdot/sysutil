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

# MENSAGENS PADRÃO

# shellcheck disable=SC2317
# Mensagem de erro
error_msg() {
  echo -e "${RED}✘ $1${NC}"
}

# Mensagem de sucesso
success_msg() {
  echo -e "${GREEN}✔ $1${NC}"
}

# Mensagem de atenção
warning_msg() {
  echo -e "${YELLOW}➜ $1${NC}"
}

# Mensagem informativa
info_msg() {
  echo -e "${BLUE}➜ $1${NC}"
}

# Mensagem neutra
bold_msg() {
  echo -e "{BOLD}$1${NC}"
}

# Função para confirmação de dados
confirm_action() {
  local message=$1
  trap 'echo -e "\n${RED}Operação cancelada pelo usuário.${NC}"; exit 1' INT

  while true; do
    echo -n -e "${YELLOW}${message} (S/n): ${NC}"
    read -r confirm
    case "${confirm,,}" in
    s) return 0 ;;
    n)
      echo "Operação cancelada."
      return 1
      ;;
    *) error_msg "Opção inválida. Digite S ou N." ;;
    esac
  done
}
