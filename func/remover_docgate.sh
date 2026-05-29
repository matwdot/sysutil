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

remover_docgate() {
    if confirm_action "Deseja remover o DocGate?"; then
        # Verificar se a pasta /opt/docgate existe
        if [ -d "/opt/docgate" ]; then
            # Encerrar processo do docgate se estiver rodando
            local docgate_pid
            docgate_pid=$(pgrep -f "/opt/docgate" 2>/dev/null)
            
            if [ -n "$docgate_pid" ]; then
                info_msg "Encerrando processo do DocGate (PID: $docgate_pid)..."
                sudo kill -9 $docgate_pid 2>/dev/null
            fi
            
            # Remover a pasta /opt/docgate
            if sudo rm -rf /opt/docgate; then
                success_msg "DocGate removido com sucesso."
                read -r -p "Pressione Enter para continuar..."
            else
                error_msg "Erro ao remover a pasta /opt/docgate."
                read -r -p "Pressione Enter para continuar..."
                return 1
            fi
        else
            error_msg "A pasta /opt/docgate não existe."
            read -r -p "Pressione Enter para continuar..."
            return 1
        fi
    else
        read -r -p "Pressione Enter para continuar..."
        error_msg "Remoção do DocGate cancelada."
    fi
}