#!/bin/bash
#
# SysUtil - Script de Instalação Rápida
# Uso: curl -fsSL https://raw.githubusercontent.com/matwdot/sysutil/master/install.sh | bash
#
# Versão: 6.0
# Autor: Matheus Wesley
#

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# Configurações
REPO_URL="https://github.com/matwdot/sysutil"
INSTALL_DIR="$HOME/sysutil"
TEMP_DIR="/tmp/sysutil-install"

# Função para log
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

error() {
    echo -e "${RED}[ERRO]${NC} $1" >&2
    exit 1
}

warning() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

# Verificar se o sistema é suportado
check_system() {
    if [[ "$OSTYPE" != "linux-gnu"* ]] && [[ "$OSTYPE" != "darwin"* ]]; then
        error "Este script funciona em sistemas Linux e macOS"
    fi
    
    # Verificar se tem curl ou wget
    if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
        error "curl ou wget é necessário para baixar os arquivos"
    fi
    
    # Verificar se tem git
    if ! command -v git >/dev/null 2>&1; then
        warning "Git não encontrado. Tentando instalar..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS - sugerir instalação via Homebrew ou Xcode
            error "Git não encontrado. Instale via: 'xcode-select --install' ou 'brew install git'"
        elif command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update && sudo apt-get install -y git
        elif command -v yum >/dev/null 2>&1; then
            sudo yum install -y git
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y git
        else
            error "Não foi possível instalar o git automaticamente"
        fi
    fi
}

# Baixar e instalar o SysUtil
install_sysutil() {
    log "Iniciando instalação do SysUtil..."
    
    # Remover instalação anterior se existir
    if [[ -d "$INSTALL_DIR" ]]; then
        warning "Removendo instalação anterior..."
        rm -rf "$INSTALL_DIR"
    fi
    
    # Criar diretório temporário
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"
    
    # Clonar repositório
    log "Baixando arquivos do repositório..."
    git clone "$REPO_URL" . || error "Falha ao clonar repositório"
    
    # Mover para diretório de instalação
    log "Instalando em $INSTALL_DIR..."
    mkdir -p "$INSTALL_DIR"
    cp -r . "$INSTALL_DIR/"
    
    # Tornar scripts executáveis
    find "$INSTALL_DIR" -name "*.sh" -exec chmod +x {} \;
    chmod +x "$INSTALL_DIR/sysutil"
    
    # Criar link simbólico para execução global
    if [[ -w "/usr/local/bin" ]] || [[ "$OSTYPE" == "darwin"* ]]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # No macOS, usar sudo se necessário
            sudo ln -sf "$INSTALL_DIR/sysutil.sh" "/usr/local/bin/sysutil" 2>/dev/null || {
                warning "Não foi possível criar link em /usr/local/bin"
                log "Execute manualmente: sudo ln -sf $INSTALL_DIR/sysutil.sh /usr/local/bin/sysutil"
            }
        else
            ln -sf "$INSTALL_DIR/sysutil.sh" "/usr/local/bin/sysutil"
        fi
        log "Link simbólico criado em /usr/local/bin/sysutil"
    else
        warning "Não foi possível criar link em /usr/local/bin (sem permissão)"
        log "Execute manualmente: sudo ln -sf $INSTALL_DIR/sysutil.sh /usr/local/bin/sysutil"
    fi
    
    # Limpar arquivos temporários
    cd /
    rm -rf "$TEMP_DIR"
    
    log "Instalação concluída com sucesso!"
    log "Execute 'sysutil' ou '$INSTALL_DIR/sysutil.sh' para iniciar"
}

# Função principal
main() {
    echo -e "${BOLD}${BLUE}"
    echo "=================================================="
    echo "           SysUtil - Instalador v6.0"
    echo "=================================================="
    echo -e "${NC}"
    
    check_system
    install_sysutil
    
    echo -e "${GREEN}"
    echo "=================================================="
    echo "           Instalação Concluída!"
    echo "=================================================="
    echo -e "${NC}"
    echo "Para executar o SysUtil, digite:"
    echo -e "${BOLD}  sysutil${NC}"
    echo ""
    echo "Ou execute diretamente:"
    echo -e "${BOLD}  $INSTALL_DIR/sysutil.sh${NC}"
}

# Executar instalação
main "$@"