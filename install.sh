#!/bin/bash
#
# SysUtil - Instalador
# Uso: curl -fsSL https://raw.githubusercontent.com/matwdot/sysutil/master/install.sh | bash
#

set -e

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

INSTALL_DIR="$HOME/sysutil"

echo -e "${BOLD}${BLUE}SysUtil - Instalador v6.0${NC}"
echo "=================================="

# Verificar se git está instalado
if ! command -v git >/dev/null 2>&1; then
    echo -e "${RED}Erro: Git não encontrado${NC}"
    echo "Instale o git primeiro:"
    echo "  Ubuntu/Debian: sudo apt install git"
    echo "  CentOS/RHEL: sudo yum install git"
    echo "  macOS: xcode-select --install"
    exit 1
fi

# Verificar se existe instalação anterior e remover
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Removendo instalação anterior...${NC}"
    rm -rf "$INSTALL_DIR"
fi

# Baixar a versão mais recente
echo -e "${GREEN}Baixando SysUtil mais recente...${NC}"
git clone https://github.com/matwdot/sysutil.git "$INSTALL_DIR"

# Configurar permissões
echo -e "${GREEN}Configurando permissões...${NC}"
cd "$INSTALL_DIR"
chmod +x *.sh
find . -name "*.sh" -exec chmod +x {} \;

# Adicionar ao PATH e criar alias
echo -e "${GREEN}Configurando PATH e alias...${NC}"

# Remover entradas antigas se existirem
sed -i '/# SysUtil PATH/d' "$HOME/.bashrc" 2>/dev/null || true
sed -i '/export PATH.*sysutil/d' "$HOME/.bashrc" 2>/dev/null || true
sed -i '/alias sysutil/d' "$HOME/.bashrc" 2>/dev/null || true

# Adicionar novas configurações
echo "" >> "$HOME/.bashrc"
echo "# SysUtil PATH e Alias" >> "$HOME/.bashrc"
echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$HOME/.bashrc"
echo "alias sysutil='cd $INSTALL_DIR && ./sysutil.sh'" >> "$HOME/.bashrc"

# Aplicar as mudanças no shell atual
alias sysutil="cd $INSTALL_DIR && ./sysutil.sh"

echo -e "${GREEN}✓ PATH e alias configurados${NC}"

# Fazer source do .bashrc
echo -e "${GREEN}Aplicando configurações...${NC}"
source "$HOME/.bashrc" 2>/dev/null || true

echo ""
echo -e "${BOLD}${GREEN}✓ Instalação concluída!${NC}"
echo -e "${BOLD}${BLUE}Iniciando SysUtil...${NC}"
echo ""
echo -e "${BOLD}${BLUE}Para iniciar digite...${NC}"
echo "  sysutil"
echo ""