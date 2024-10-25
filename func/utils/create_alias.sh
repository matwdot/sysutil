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

# Script que irá criar um alias e adicionar ao .bashrc

create_alias() {
  ALIAS_NAME="sysutil"
  ALIAS_CMD="~/sysutil/sysutil.sh"
  ALIAS_LINE="alias $ALIAS_NAME=\"$ALIAS_CMD\""

  # Verifica se o alias já existe no .bashrc
  if grep -Fxq "alias $ALIAS_NAME=\"$ALIAS_CMD\"" ~/.bashrc; then
    echo "Alias '$ALIAS_NAME' já está presente no .bashrc"
    read -p ""
  else
    # Adiciona o alias ao .bashrc
    echo -e "\n# Alias sysutil" >>~/.bashrc
    echo -e "\n$ALIAS_LINE" >>~/.bashrc

    echo "Adicionado com sucesso!"
    read -p ""

    # Recarrega o .bashrc para atualizar as alterações
    source ~/.bashrc
  fi
}

# Executar função
create_alias