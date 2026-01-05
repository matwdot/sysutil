#!/bin/bash
#
# SysUtil - Atualizador
# Uso: curl -fsSL https://raw.githubusercontent.com/matwdot/sysutil/master/update.sh | bash
#

set -e

INSTALL_DIR="$HOME/sysutil"

if [ ! -d "$INSTALL_DIR" ]; then
    echo "SysUtil não encontrado. Execute o instalador primeiro:"
    echo "curl -fsSL https://raw.githubusercontent.com/matwdot/sysutil/master/install.sh | bash"
    exit 1
fi

echo "Atualizando SysUtil..."
cd "$INSTALL_DIR"
git pull origin master
chmod +x *.sh
find . -name "*.sh" -exec chmod +x {} \;

echo "✓ SysUtil atualizado com sucesso!"