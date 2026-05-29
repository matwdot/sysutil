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
# *************************************************************

# Import utilities if not loaded
if [[ -z "$(type -t error_msg)" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck source=utils/utilities.sh
  source "${SCRIPT_DIR}/utils/utilities.sh" || {
    echo "ERRO: Não foi possível carregar utilities.sh"
    exit 1
  }
fi

# Configura periféricos
configurar_perifericos() {

  if confirm_action "Deseja configurar os periféricos?"; then

    # Verifica se o Sublime está instalado, caso não ativa o nano
    if command -v subl &>/dev/null; then
      editor="subl"
    else
      error_msg "Sublime Text não encontrado. Utilizando o editor padrão (nano)."
      editor="nano"
    fi

    # Define variaveis para os arquivos setty e 90-dispositivos
    setty=/usr/local/bin/setty
    dispositivos=/etc/udev/rules.d/90-dispositivos-usb.rules

    if $editor $setty && $editor $dispositivos; then
      info_msg "Abrindo: setty e 90-dispositivos-usb.rules"

      # Esperar que o usuário termine de configurar
      info_msg "Pressione Enter quando concluir a configuração."
      read -r -p ""

      # Aplica permissão na pasta
      if ! sudo chmod +x "$setty"; then
        error_msg "Erro ao aplicar permissão no arquivo $setty"
      else
        sudo setty
      fi

    else
      error_msg "Erro ao abrir os arquivos de configuração."
    fi
  else
    info_msg "Configuração de periféricos cancelada."
  fi
}
