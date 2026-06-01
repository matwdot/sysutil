#!/bin/bash
#
# configurar_perifericos.sh - Configuração de periféricos USB/Serial
#
# Versão: 8.0
# Autor: Matheus Wesley
# GitHub: https://matheuswesley.github.io/devlinks
# GitHub Projeto: https://matwdot.github.
# Licença: MIT
#
# *************************************************************

# Import peripherals if not loaded
if [[ -z "$(type -t listar_dispositivos)" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck source=utils/peripherals.sh
  source "${SCRIPT_DIR}/utils/peripherals.sh" || {
    echo "ERRO: Não foi possível carregar peripherals.sh"
    exit 1
  }
fi

# Menu principal de configuração de periféricos
configurar_perifericos() {
  local opcoes=(
    "Configurar dispositivo específico"
    "Editar regras manualmente (subl/nano)"
    "Voltar"
  )

  while true; do
    clear
    select_menu "Configuração de Periféricos" "${opcoes[@]}"
    local escolha=$?

    case $escolha in
      0)
        clear
        configurar_dispositivo_interativo
        ;;
      1)
        clear
        editar_regras_manualmente
        ;;
      2|255)
        clear
        return
        ;;
    esac
  done
}

# Fluxo original: edição manual com Sublime Text ou nano
editar_regras_manualmente() {
  if confirm_action "Deseja configurar os periféricos manualmente?"; then
    if command -v subl &>/dev/null; then
      editor="subl"
    else
      warning_msg "Sublime Text não encontrado. Utilizando o editor padrão (nano)."
      editor="nano"
    fi

    if $editor "$SETTY_FILE" && $editor "$RULES_FILE"; then
      info_msg "Abrindo: $SETTY_FILE e $RULES_FILE"
      info_msg "Pressione Enter quando concluir a configuração."
      read -r -p ""

      if ! sudo chmod +x "$SETTY_FILE"; then
        error_msg "Erro ao aplicar permissão no arquivo $SETTY_FILE"
      else
        sudo "$SETTY_FILE"
      fi
    else
      error_msg "Erro ao abrir os arquivos de configuração."
    fi
  else
    info_msg "Configuração de periféricos cancelada."
  fi
}
