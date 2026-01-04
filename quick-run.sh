#!/bin/bash
#
# SysUtil - Instalação e Execução Rápida
# Uso: curl -fsSL https://raw.githubusercontent.com/matwdot/sysutil/master/quick-run.sh | bash
#

set -e

INSTALL_DIR="$HOME/sysutil"

# Se não estiver instalado, instalar primeiro
if [[ ! -d "$INSTALL_DIR" ]]; then
    echo "SysUtil não encontrado. Instalando..."
    curl -fsSL https://raw.githubusercontent.com/matwdot/sysutil/master/install.sh | bash
    echo ""
    echo "Iniciando SysUtil..."
    echo ""
fi

# Executar o SysUtil
if [[ -f "$INSTALL_DIR/sysutil.sh" ]]; then
    cd "$INSTALL_DIR"
    ./sysutil.sh
else
    echo "Erro: SysUtil não foi instalado corretamente"
    exit 1
fi