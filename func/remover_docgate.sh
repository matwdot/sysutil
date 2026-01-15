#!/bin/bash
#
# sysutil.sh - Script de utilitários para o SysPDV PDV em Linux
#
# Versão: 7.0
# Autor: Matheus Wesley
# GitHub: https://matheuswesley.github.io/devlinks
# GitHub Projeto: https://matwdot.github.
# Licença: MIT
#
# Este script contém um conjunto de funções para instalação, atualização e
# manutenção do sistema SysPDV PDV em ambientes Linux.
#
# *************************************************************

# IMPORTAÇÕES
# shellcheck disable=SC1091


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
                sleep 1
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