#!/bin/bash
#
# SysUtil - Atualizador
# Uso: curl -fsSL https://raw.githubusercontent.com/matwdot/sysutil/master/update.sh | sudo bash
#

set -e

INSTALL_DIR="${SYSUTIL_INSTALL_DIR:-/opt/sysutil}"
BIN_LINK="${SYSUTIL_BIN_LINK:-/usr/local/bin/sysutil}"

if [ "$(id -u)" -ne 0 ]; then
    echo "ERRO: execute como root:"
    echo "  curl -fsSL https://raw.githubusercontent.com/matwdot/sysutil/master/update.sh | sudo bash"
    exit 1
fi

if [ ! -d "$INSTALL_DIR/.git" ]; then
    echo "SysUtil não encontrado em $INSTALL_DIR. Execute o instalador primeiro:"
    echo "  curl -fsSL https://raw.githubusercontent.com/matwdot/sysutil/master/install.sh | sudo bash"
    exit 1
fi

# Atualiza a mesma versão que foi instalada (master = estável, dev = desenvolvimento)
BRANCH=$(git -C "$INSTALL_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "?")
echo "Atualizando SysUtil (versão: $BRANCH)..."
if ! git -C "$INSTALL_DIR" pull --ff-only; then
    echo "ERRO: não foi possível atualizar (há alterações locais em $INSTALL_DIR ou falta rede)."
    echo "Para reinstalar do zero, rode o instalador."
    exit 1
fi

find "$INSTALL_DIR" -name "*.sh" -exec chmod +x {} \;
chmod +x "$INSTALL_DIR/sysutil" 2>/dev/null || true
ln -sf "$INSTALL_DIR/sysutil" "$BIN_LINK"

echo "✓ SysUtil atualizado com sucesso!"
