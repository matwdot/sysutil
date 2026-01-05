#!/bin/bash
#
# SysUtil - Instalador e Executor
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

# Criar link simbólico
echo -e "${GREEN}Criando link simbólico...${NC}"
if sudo ln -sf "$INSTALL_DIR/sysutil.sh" /usr/local/bin/sysutil 2>/dev/null; then
    echo -e "${GREEN}✓ Link criado: /usr/local/bin/sysutil${NC}"
else
    echo -e "${YELLOW}⚠ Execute manualmente: sudo ln -sf $INSTALL_DIR/sysutil.sh /usr/local/bin/sysutil${NC}"
fi

echo ""
echo -e "${BOLD}${GREEN}✓ Instalação concluída!${NC}"
echo -e "${BOLD}${BLUE}Iniciando SysUtil...${NC}"
echo ""

# Executar o SysUtil
./sysutil.sh