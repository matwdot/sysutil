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
# **************************************************************

# Import utilities if not loaded
if [[ -z "$(type -t error_msg)" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck source=utils/utilities.sh
  source "${SCRIPT_DIR}/utils/utilities.sh" || {
    echo "ERRO: Não foi possível carregar utilities.sh"
    exit 1
  }
fi

# Transferencia de arquivos via SCP

# Função de transferência de arquivos
transferencia() {
  if confirm_action "Deseja realizar a transferência de arquivos?"; then

    # Solicitar informações do usuário
    print_msg "Informe o IP da máquina Host:"
    read -r host

    # Verificar se o host foi informado
    if [[ -z "$host" ]]; then
      error_msg "Erro: o IP do Host não foi informado."
      return 1
    fi

    if ! is_valid_ip "$host"; then
      error_msg "IP inválido: $host"
      return 1
    fi

    print_msg "Informe a pasta ou arquivo que deseja copiar (ex: /opt/Syspdv/TefDll)  :"
    read -r file

    # Verificar se o arquivo/pasta foi informado
    if [[ -z "$file" ]]; then
      error_msg "Erro: a pasta ou arquivo não foi informado."
      return 1
    fi

    print_msg "Informe o local onde deseja salvar:"
    read -r dir_local

    # Verificar se o diretório local foi informado
    if [[ -z "$dir_local" ]]; then
      error_msg "Erro: o diretório local não foi informado."
      return 1
    fi

    # Realizar a transferência de arquivos
    if scp -r "root@$host:$file" "$dir_local"; then
      success_msg "Cópia do arquivo/pasta '$file' realizada com sucesso."
      info_msg "Pressione ENTER para continuar..."
      read -r -p ""
    else
      error_msg "Erro ao realizar a cópia do arquivo/pasta '$file'."
    fi
  else
    info_msg "Transferência de arquivos cancelada."
  fi
}
