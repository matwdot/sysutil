#!/bin/bash
#
# SysUtil - Instalador v8.0
# Uso:
#   Versão estável (master):
#     curl -fsSL https://raw.githubusercontent.com/matwdot/sysutil/master/install.sh | sudo bash
#   Versão de desenvolvimento (dev):
#     curl -fsSL https://raw.githubusercontent.com/matwdot/sysutil/master/install.sh | sudo bash -s -- --dev
#   Com o arquivo baixado:
#     sudo bash install.sh [--dev]
#

# Instala em /opt/sysutil (para todos os usuários) e cria o comando
# /usr/local/bin/sysutil. Precisa de root.

set -e

# Cores básicas (compatível com terminais antigos)
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
CYAN='\033[36m'
BOLD='\033[1m'
NC='\033[0m'

INSTALL_DIR="${SYSUTIL_INSTALL_DIR:-/opt/sysutil}"
BIN_LINK="${SYSUTIL_BIN_LINK:-/usr/local/bin/sysutil}"
REPO_URL="${SYSUTIL_REPO:-https://github.com/matwdot/sysutil.git}"
BRANCH="${SYSUTIL_BRANCH:-master}"
NEW_DIR="${INSTALL_DIR}.new"
OLD_DIR="${INSTALL_DIR}.old"
TOTAL_STEPS=7
CURRENT_STEP=0
BAR_WIDTH=40

# Opções
for arg in "$@"; do
    case "$arg" in
        --dev) BRANCH="dev" ;;
        -h | --help)
            echo "Uso: sudo bash install.sh [--dev]"
            echo "  (sem opção)  instala a versão estável (branch master)"
            echo "  --dev        instala a versão de desenvolvimento (branch dev)"
            exit 0
            ;;
        *)
            echo "Opção desconhecida: $arg (use --dev ou --help)"
            exit 1
            ;;
    esac
done

# Pastas de usuário onde pode haver instalação/alias da versão antiga
if [ -n "${SYSUTIL_HOMES:-}" ]; then
    HOMES="$SYSUTIL_HOMES"
else
    HOMES="/root $(ls -d /home/* 2>/dev/null | tr '\n' ' ')"
fi

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
    rm -rf "$NEW_DIR"
    exit 1
}

# Precisa de root (a instalação vai para /opt)
if [ "$(id -u)" -ne 0 ]; then
    printf "${RED}ERRO:${NC} execute como root:\n"
    echo "  curl -fsSL https://raw.githubusercontent.com/matwdot/sysutil/master/install.sh | sudo bash"
    exit 1
fi

# Header compacto (clear falha sem terminal, ex.: TERM=dumb; não pode parar o set -e)
clear 2>/dev/null || true
echo -e "${BOLD}${CYAN}"
echo "+------------------------------------------+"
echo "|        SysUtil Instalador v8.0           |"
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

# Passo 3: Baixar para uma pasta temporária (a instalação atual fica intacta)
update_progress "Baixando do GitHub ($BRANCH)..."
rm -rf "$NEW_DIR"
git clone --branch "$BRANCH" "$REPO_URL" "$NEW_DIR" --quiet 2>/dev/null || die "Falha ao baixar a versao '$BRANCH'. A instalacao atual foi mantida."

# Passo 4: Trocar a instalação (com volta atrás se falhar)
update_progress "Instalando em $INSTALL_DIR..."
rm -rf "$OLD_DIR"
if [ -d "$INSTALL_DIR" ]; then
    mv "$INSTALL_DIR" "$OLD_DIR" || die "Nao foi possivel mover a instalacao atual."
fi
if ! mv "$NEW_DIR" "$INSTALL_DIR"; then
    [ -d "$OLD_DIR" ] && mv "$OLD_DIR" "$INSTALL_DIR"
    die "Falha ao instalar. A instalacao anterior foi restaurada."
fi
rm -rf "$OLD_DIR"

# Passo 5: Configurar permissões
update_progress "Configurando permissoes..."
find "$INSTALL_DIR" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
chmod +x "$INSTALL_DIR/sysutil" 2>/dev/null || true

# Passo 6: Criar o comando e limpar alias/PATH da versão antiga
update_progress "Configurando sistema..."
mkdir -p "$(dirname "$BIN_LINK")"
ln -sf "$INSTALL_DIR/sysutil" "$BIN_LINK" || die "Falha ao criar o comando $BIN_LINK"

OLD_INSTALLS=""
for h in $HOMES; do
    for rc in "$h/.bashrc" "$h/.zshrc"; do
        [ -f "$rc" ] || continue
        if grep -qE '^# SysUtil|^# Alias sysutil|^# Adiciona sysutil|export PATH=.*sysutil|^alias sysutil=' "$rc" 2>/dev/null; then
            # guarda uma cópia (.sysutil.bak) antes de remover as linhas antigas
            sed -i.sysutil.bak \
                -e '/^# SysUtil/d' \
                -e '/^# Alias sysutil/d' \
                -e '/^# Adiciona sysutil/d' \
                -e '/export PATH=.*sysutil/d' \
                -e '/^alias sysutil=/d' "$rc" 2>/dev/null || true
        fi
    done
    [ -d "$h/sysutil" ] && OLD_INSTALLS="$OLD_INSTALLS $h/sysutil"
done

# Passo 7: Finalizar
update_progress "Concluido!"

# Resultado final
echo ""
echo ""
echo -e "${GREEN}+------------------------------------------+"
echo -e "|          INSTALACAO CONCLUIDA!           |"
echo -e "+------------------------------------------+${NC}"
echo ""
echo -e "Instalado em: ${BOLD}$INSTALL_DIR${NC}"
if [ "$BRANCH" = "master" ]; then
    echo -e "Versão:       ${BOLD}estável${NC} (master)"
else
    echo -e "Versão:       ${YELLOW}${BOLD}desenvolvimento${NC} ($BRANCH)"
fi
echo -e "Para abrir:    ${GREEN}sysutil${NC}  (pede sudo sozinho se precisar)"
echo ""
echo -e "Se o terminal ainda usar o alias antigo, abra um novo terminal"
echo -e "ou execute: ${BOLD}unalias sysutil; hash -r${NC}"
if [ -n "$OLD_INSTALLS" ]; then
    echo ""
    echo -e "${YELLOW}Pastas antigas sem uso (pode apagar depois de conferir):${NC}"
    for d in $OLD_INSTALLS; do echo "  $d"; done
fi
echo ""
