#!/bin/bash
#
# SysUtil - Instalador v7.0.1
# Uso: curl -fsSL https://raw.githubusercontent.com/matwdot/sysutil/master/install.sh | bash
#

set -e

# Cores básicas (compatível com terminais antigos)
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
CYAN='\033[36m'
BOLD='\033[1m'
NC='\033[0m'

INSTALL_DIR="$HOME/sysutil"
TOTAL_STEPS=7
CURRENT_STEP=0
BAR_WIDTH=40

# Limpa linha e mostra barra de progresso
update_progress() {
    local msg="$1"
    CURRENT_STEP=$((CURRENT_STEP + 1))
    local pct=$((CURRENT_STEP * 100 / TOTAL_STEPS))
    local filled=$((pct * BAR_WIDTH / 100))
    local empty=$((BAR_WIDTH - filled))
    
    # Move cursor para linha da barra e limpa
    printf "\r\033[K"
    printf "${CYAN}[${NC}"
    printf "%${filled}s" | tr ' ' '#'
    printf "%${empty}s" | tr ' ' '-'
    printf "${CYAN}]${NC} %3d%% ${BOLD}%s${NC}" "$pct" "$msg"
}

# Mensagem de status abaixo da barra
status_msg() {
    printf "\n  ${GREEN}>${NC} %s\n" "$1"
    printf "\033[A\033[A"  # Volta 2 linhas para manter barra no topo
}

# Erro fatal
die() {
    printf "\n${RED}ERRO:${NC} %s\n" "$1"
    exit 1
}

# Header compacto
clear
echo -e "${BOLD}${CYAN}"
echo "+------------------------------------------+"
echo "|        SysUtil Instalador v7.0.1         |"
echo "|     by Matheus Wesley - Casa Magalhaes   |"
echo "+------------------------------------------+"
echo -e "${NC}"
echo ""

# Reserva espaço para barra e status
echo ""
echo ""

# Passo 1: Verificar git
update_progress "Verificando git..."
sleep 0.3
command -v git >/dev/null 2>&1 || die "Git nao encontrado. Instale: sudo apt install git"

# Passo 2: Verificar curl
update_progress "Verificando curl..."
sleep 0.3
command -v curl >/dev/null 2>&1 || die "Curl nao encontrado. Instale: sudo apt install curl"

# Passo 3: Remover instalação anterior
update_progress "Preparando diretorio..."
sleep 0.3
[ -d "$INSTALL_DIR" ] && rm -rf "$INSTALL_DIR"

# Passo 4: Clonar repositório
update_progress "Baixando do GitHub..."
git clone https://github.com/matwdot/sysutil.git "$INSTALL_DIR" --quiet 2>/dev/null || die "Falha ao clonar repositorio"

# Passo 5: Configurar permissões
update_progress "Configurando permissoes..."
sleep 0.3
cd "$INSTALL_DIR"
chmod +x *.sh 2>/dev/null || true
find . -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true

# Passo 6: Configurar PATH e alias
update_progress "Configurando sistema..."
sleep 0.3
sed -i '/# SysUtil/d' "$HOME/.bashrc" 2>/dev/null || true
sed -i '/export PATH.*sysutil/d' "$HOME/.bashrc" 2>/dev/null || true
sed -i '/alias sysutil/d' "$HOME/.bashrc" 2>/dev/null || true

cat >> "$HOME/.bashrc" << EOF

# SysUtil
export PATH="$INSTALL_DIR:\$PATH"
alias sysutil='cd $INSTALL_DIR && ./sysutil.sh'
EOF

# Passo 7: Finalizar
update_progress "Concluido!"

# Resultado final
echo ""
echo ""
echo -e "${GREEN}+------------------------------------------+"
echo -e "|          INSTALACAO CONCLUIDA!           |"
echo -e "+------------------------------------------+${NC}"
echo ""
echo -e "É a ${BOLD}primeira instalação?${NC}"
echo -e "1. Execute: ${BOLD}source ~/.bashrc${NC}"
echo -e "2. Depois:  ${BOLD}sysutil${NC}"
echo ""
echo -e "Caso contrário:"
echo -e "Execute: ${GREEN}sysutil${NC}"
echo ""
