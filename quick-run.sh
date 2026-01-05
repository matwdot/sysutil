#!/bin/bash
#
# SysUtil - Instalação e Execução Rápida
# Uso: curl -fsSL https://raw.githubusercontent.com/matwdot/sysutil/master/quick-run.sh | bash
#

set -e

INSTALL_DIR="$HOME/sysutil"

# Instalar se não existir
if [ ! -d "$INSTALL_DIR" ]; then
    echo "Instalando SysUtil..."
    curl -fsSL https://raw.githubusercontent.com/matwdot/sysutil/master/install.sh | bash
    echo ""
fi

# Executar
echo "Iniciando SysUtil..."
cd "$INSTALL_DIR"
./sysutil.sh