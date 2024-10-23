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

# Transferencia de arquvos via SCP

#!/bin/bash

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

    print_msg "Informe a pasta ou arquivo que deseja copiar (ex: /opt/Syspdv/TefDll):"
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
    else
      error_msg "Erro ao realizar a cópia do arquivo/pasta '$file'."
    fi
  else
    info_msg "Transferência de arquivos cancelada."
  fi
}
