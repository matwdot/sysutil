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
      echo -e "Abrindo: setty e 90-dispositivos-usb.rules"

      # Esperar que o usuário termine de configurar
      info_msg "${YELLOW}Pressione Enter quando concluir a configuração.${NC}"
      read -r -p ""

      # Aplica permissão na pasta
      if ! sudo chmod +x "$setty"; then
        error_msg "Erro ao aplicar permissão no arquivo $setty"
        sleep 2
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
