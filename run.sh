#!/bin/bash
#
# SysUtil - Execução Rápida
# Uso: curl -fsSL https://matwdot.github.io/sysutil/run.sh | bash
#

set -e

INSTALL_DIR="$HOME/sysutil"

# Se não estiver instalado, instalar primeiro
if [[ ! -d "$INSTALL_DIR" ]]; then
    echo "SysUtil não encontrado. Instalando..."
    curl -fsSL https://matwdot.github.io/sysutil/install.sh | bash
fi

# Executar o SysUtil
cd "$INSTALL_DIR"
./sysutil.sh