#!/bin/bash
#set -x

# Recebe o diretório como parâmetro ou tenta detectar
if [ -n "$1" ] && [ -d "$1" ]; then
    SCRIPT_DIR="$1"
else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
fi

# Carrega as funções utilitárias do sistema
UTILS_PATH="${SCRIPT_DIR}/../../func/utils/utilities.sh"
if [ -f "$UTILS_PATH" ]; then
    source "$UTILS_PATH"
else
    # Fallback caso não encontre as funções
    error_msg() { echo -e "\033[1;31m✘ $1\033[0m" >&2; }
    success_msg() { echo -e "\033[1;32m✔ $1\033[0m"; }
    warning_msg() { echo -e "\033[1;33m➜ $1\033[0m"; }
    info_msg() { echo -e "\033[1;34m➜ $1\033[0m"; }
    bold_msg() { echo -e "\033[1m$1\033[0m"; }
    pause() { echo -n -e "\033[1;34m${1:-Pressione ENTER para continuar...}\033[0m"; read -r; }
fi

# Detecta a arquitetura do sistema
detect_architecture() {
    local arch
    arch=$(uname -m)
    
    case "$arch" in
        x86_64|amd64)
            echo "amd64"
            ;;
        i386|i686)
            echo "i386"
            ;;
        aarch64|arm64)
            echo "arm64"
            ;;
        armv7l|armhf)
            echo "armhf"
            ;;
        *)
            echo "unsupported"
            ;;
    esac
}

# Detecta o gerenciador de pacotes
detect_package_manager() {
    if command -v dpkg &> /dev/null; then
        echo "deb"
    elif command -v rpm &> /dev/null; then
        echo "rpm"
    else
        echo "unknown"
    fi
}

# Remove instalação antiga
remove_old_installation() {
    local pkg_manager="$1"
    
    info_msg "Removendo instalação antiga..."
    
    if [ "$pkg_manager" = "deb" ]; then
        dpkg --purge wnbtlscli 2>/dev/null
        apt-get remove -y wnbmonitor 2>/dev/null
        apt-get remove -y wnbtlscli 2>/dev/null
    elif [ "$pkg_manager" = "rpm" ]; then
        rpm -e wnbtlscli 2>/dev/null
        rpm -e wnbmonitor 2>/dev/null
    fi
    
    info_msg "Removendo diretórios antigos..."
    rm -rf /etc/wnbtlscli
    rm -rf /var/log/wnb
    
    success_msg "Instalação antiga removida."
}

# Instala o pacote correto
install_package() {
    local arch="$1"
    local pkg_manager="$2"
    local package=""
    
    info_msg "Instalando novo pacote..."
    
    if [ "$pkg_manager" = "deb" ]; then
        package="${SCRIPT_DIR}/wnbtlscli_2.5.1_${arch}.deb"
        if [ -f "$package" ]; then
            info_msg "Instalando pacote: $package"
            dpkg -i "$package"
        else
            error_msg "Pacote não encontrado: $package"
            info_msg "Arquivos disponíveis em ${SCRIPT_DIR}:"
            ls -la "${SCRIPT_DIR}"/*.deb 2>/dev/null || error_msg "Nenhum pacote .deb encontrado"
            return 1
        fi
    elif [ "$pkg_manager" = "rpm" ]; then
        if [ "$arch" = "amd64" ]; then
            package="${SCRIPT_DIR}/wnbtlscli-2.5.1_amd64.rpm"
            if [ -f "$package" ]; then
                info_msg "Instalando pacote: $package"
                rpm -Uvh "$package"
            else
                error_msg "Pacote RPM não encontrado"
                return 1
            fi
        else
            error_msg "Pacote RPM disponível apenas para amd64"
            return 1
        fi
    else
        error_msg "Gerenciador de pacotes não suportado"
        return 1
    fi
}

# ==========================================
# INÍCIO DO SCRIPT
# ==========================================

bold_msg "WNB TLS CLI - Instalador v2.5.1"

ARCH=$(detect_architecture)
PKG_MANAGER=$(detect_package_manager)

info_msg "Arquitetura detectada: $ARCH"
info_msg "Gerenciador de pacotes: $PKG_MANAGER"

if [ "$ARCH" = "unsupported" ]; then
    error_msg "Arquitetura não suportada: $(uname -m)"
    exit 1
fi

# 1. Para os serviços
info_msg "Parando serviços..."
systemctl stop wnbmonitor 2>/dev/null
systemctl stop wnbtlscli 2>/dev/null
success_msg "Serviços parados."

# 2. Exibe a chave TLS caso exista instalação antiga
if [ -f "/etc/wnbtlscli/registry" ]; then
    warning_msg "ATENÇÃO: Instalação anterior detectada!"
    info_msg "Chave TLS atual:"
    echo "------------------------------------------"
    cat /etc/wnbtlscli/registry
    echo "------------------------------------------"
    warning_msg "IMPORTANTE: Anote a chave acima antes de continuar!"
    pause "Pressione ENTER para continuar ou CTRL+C para cancelar..."
    
    # 3. Remove instalação antiga
    remove_old_installation "$PKG_MANAGER"
else
    info_msg "Nenhuma instalação anterior detectada."
fi

# 4. Instala o pacote
install_package "$ARCH" "$PKG_MANAGER" || exit 1

# Configura serviços
info_msg "Configurando serviços..."
systemctl enable wnbmonitor
systemctl enable wnbtlscli

if [ -f "/etc/wnbtlscli/registry" ]; then
    oldver=$(grep -c systemd /etc/wnbtlscli/registry)
    if [ "$oldver" = 0 ]; then
        echo "systemd: true" >> /etc/wnbtlscli/registry
        echo "log_level: 3" >> /etc/wnbtlscli/registry
    fi
    info_msg "Iniciando serviços..."
    systemctl start wnbmonitor
    success_msg "Instalação concluída com sucesso!"
else
    warning_msg "Execute o comando abaixo para registrar:"
    bold_msg "wnbupdate -k XXXX"
fi

exit 0
