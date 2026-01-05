#!/bin/bash
#
# SysUtil - Instalador
# Uso: curl -fsSL https://raw.githubusercontent.com/matwdot/sysutil/master/install.sh | bash
#

set -e

# Cores e estilos
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Símbolos
CHECK="✅"
CROSS="❌"
ARROW="➜"
GEAR="⚙️"
DOWNLOAD="📦"
ROCKET="🚀"
SPARKLE="✨"

INSTALL_DIR="$HOME/sysutil"

# Função para mostrar progresso
show_progress() {
    local step=$1
    local total=$2
    local message=$3
    local percentage=$((step * 100 / total))
    
    echo -e "\n${CYAN}[$step/$total] ${BOLD}$message${NC}"
    
    # Barra de progresso
    local filled=$((percentage / 5))
    local empty=$((20 - filled))
    printf "${BLUE}["
    printf "%*s" $filled | tr ' ' '█'
    printf "%*s" $empty | tr ' ' '░'
    printf "] ${WHITE}%d%%${NC}\n" $percentage
}

# Função para log com ícones
log_success() {
    echo -e "${GREEN}${CHECK} $1${NC}"
}

log_error() {
    echo -e "${RED}${CROSS} $1${NC}"
}

log_info() {
    echo -e "${BLUE}${ARROW} $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Header bonito
clear
echo -e "${BOLD}${PURPLE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║                    ${SPARKLE} SysUtil Installer ${SPARKLE}                    ║"
echo "║                                                              ║"
echo "║                        Versão 7.0                           ║"
echo "║              by Matheus Wesley - Casa Magalhães             ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${DIM}Instalador automático para SysPDV PDV Linux Utilities${NC}"
echo -e "${DIM}GitHub: https://github.com/matwdot/sysutil${NC}\n"

# Passo 1: Verificar dependências
show_progress 1 7 "Verificando dependências do sistema"
sleep 1

if ! command -v git >/dev/null 2>&1; then
    log_error "Git não encontrado"
    echo -e "${YELLOW}Instale o git primeiro:${NC}"
    echo -e "  ${WHITE}Ubuntu/Debian:${NC} sudo apt install git"
    echo -e "  ${WHITE}CentOS/RHEL:${NC} sudo yum install git"
    echo -e "  ${WHITE}macOS:${NC} xcode-select --install"
    exit 1
else
    log_success "Git encontrado $(git --version | cut -d' ' -f3)"
fi

if ! command -v curl >/dev/null 2>&1; then
    log_error "Curl não encontrado"
    exit 1
else
    log_success "Curl disponível"
fi

# Passo 2: Verificar instalação anterior
show_progress 2 7 "Verificando instalação anterior"
sleep 1

if [ -d "$INSTALL_DIR" ]; then
    log_warning "Instalação anterior encontrada"
    log_info "Removendo instalação anterior..."
    rm -rf "$INSTALL_DIR"
    log_success "Instalação anterior removida"
else
    log_info "Nenhuma instalação anterior encontrada"
fi

# Passo 3: Baixar repositório
show_progress 3 7 "Baixando SysUtil do GitHub"
log_info "Clonando repositório..."

if git clone https://github.com/matwdot/sysutil.git "$INSTALL_DIR" --quiet; then
    log_success "Repositório clonado com sucesso"
    
    # Mostrar informações do repositório
    cd "$INSTALL_DIR"
    commit_hash=$(git rev-parse --short HEAD)
    commit_date=$(git log -1 --format=%cd --date=short)
    echo -e "  ${DIM}Commit: $commit_hash ($commit_date)${NC}"
else
    log_error "Falha ao clonar repositório"
    exit 1
fi

# Passo 4: Configurar permissões
show_progress 4 7 "Configurando permissões dos arquivos"
sleep 1

log_info "Aplicando permissões executáveis..."
chmod +x *.sh
find . -name "*.sh" -exec chmod +x {} \;

script_count=$(find . -name "*.sh" | wc -l)
log_success "$script_count scripts configurados"

# Passo 5: Configurar PATH e alias
show_progress 5 7 "Configurando PATH e alias do sistema"
sleep 1

log_info "Configurando acesso global..."

# Remover entradas antigas se existirem
sed -i '/# SysUtil PATH/d' "$HOME/.bashrc" 2>/dev/null || true
sed -i '/export PATH.*sysutil/d' "$HOME/.bashrc" 2>/dev/null || true
sed -i '/alias sysutil/d' "$HOME/.bashrc" 2>/dev/null || true

# Adicionar novas configurações
{
    echo ""
    echo "# SysUtil PATH e Alias"
    echo "export PATH=\"$INSTALL_DIR:\$PATH\""
    echo "alias sysutil='cd $INSTALL_DIR && ./sysutil.sh'"
} >> "$HOME/.bashrc"

# Aplicar as mudanças no shell atual
alias sysutil="cd $INSTALL_DIR && ./sysutil.sh"

log_success "PATH configurado: $INSTALL_DIR"
log_success "Alias criado: sysutil"

# Passo 6: Aplicar configurações
show_progress 6 7 "Aplicando configurações do shell"
sleep 1

log_info "Executando source ~/.bashrc..."
source "$HOME/.bashrc" 2>/dev/null || true
log_success "Configurações aplicadas"

# Passo 7: Finalizar
show_progress 7 7 "Finalizando instalação"
sleep 1

echo -e "\n${BOLD}${GREEN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║                 ${CHECK} INSTALAÇÃO CONCLUÍDA! ${CHECK}                 ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${BOLD}${WHITE}Como usar:${NC}"
echo -e "  ${GREEN}${ROCKET} sysutil${NC}          ${DIM}(de qualquer lugar)${NC}"
echo -e "  ${GREEN}${ROCKET} cd ~/sysutil && ./sysutil.sh${NC}  ${DIM}(execução direta)${NC}"

echo -e "\n${BOLD}${WHITE}Recursos instalados:${NC}"
echo -e "  ${CYAN}•${NC} SysPDV PDV (instalação/atualização)"
echo -e "  ${CYAN}•${NC} VPN Connect (configuração)"
echo -e "  ${CYAN}•${NC} MFe/DocGate (drivers e configuração)"
echo -e "  ${CYAN}•${NC} Configuração de periféricos"
echo -e "  ${CYAN}•${NC} Configuração biométrica"
echo -e "  ${CYAN}•${NC} Limitação de consumo Tec55"
echo -e "  ${CYAN}•${NC} Transferência SCP"

echo -e "\n${BOLD}${YELLOW}${GEAR} Instalação finalizada!${NC}"
echo -e "${BOLD}${WHITE}Para iniciar o SysUtil, digite:${NC}"
echo -e "  ${GREEN}${ROCKET} sysutil${NC}"
echo -e "\n${DIM}Pressione Enter para continuar ou Ctrl+C para sair${NC}"
read -r