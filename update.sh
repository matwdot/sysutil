#!/bin/bash
#
# SysUtil - Script de Atualização
# Uso: curl -fsSL https://matwdot.github.io/sysutil/update.sh | bash
#

set -e

INSTALL_DIR="$HOME/sysutil"
REPO_URL="https://github.com/matwdot/sysutil"

if [[ ! -d "$INSTALL_DIR" ]]; then
    echo "SysUtil não encontrado. Execute o instalador primeiro."
    exit 1
fi

echo "Atualizando SysUtil..."
cd "$INSTALL_DIR"
git pull origin master
chmod +x *.sh
find . -name "*.sh" -exec chmod +x {} \;

echo "SysUtil atualizado com sucesso!"