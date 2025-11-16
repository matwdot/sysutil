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
  ALIAS_CMD="(cd ~/sysutil && ./sysutil.sh)"
  ALIAS_LINE="alias $ALIAS_NAME=\"$ALIAS_CMD\""
  PATH_LINE='export PATH="$PATH:$HOME/sysutil"'

  for RC_FILE in ~/.bashrc ~/.zshrc; do
    # Verifica se o alias já existe no arquivo de configuração
    if ! grep -Fxq "$ALIAS_LINE" "$RC_FILE"; then
      echo -e "\n# Alias sysutil" >>"$RC_FILE"
      echo "$ALIAS_LINE" >>"$RC_FILE"
      echo "Alias '$ALIAS_NAME' adicionado ao $RC_FILE com sucesso!"
    else
      echo "Alias '$ALIAS_NAME' já está presente no $RC_FILE"
    fi

    # Adiciona o diretório ao PATH se não estiver presente
    if ! grep -Fxq "$PATH_LINE" "$RC_FILE"; then
      echo -e "\n# Adiciona sysutil ao PATH" >>"$RC_FILE"
      echo "$PATH_LINE" >>"$RC_FILE"
      echo "Diretório '~/sysutil' adicionado ao PATH no $RC_FILE com sucesso!"
    else
      echo "O diretório '~/sysutil' já está no PATH no $RC_FILE"
    fi
  done

  # Recarrega os arquivos de configuração
  source ~/.bashrc 2>/dev/null
  source ~/.zshrc 2>/dev/null
}


# Executar função
# create_alias