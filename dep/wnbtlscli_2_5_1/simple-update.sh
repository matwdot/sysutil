#!/bin/bash
#set -x

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
    
    echo ""
    echo "=========================================="
    echo " Removendo instalação antiga..."
    echo "=========================================="
    
    if [ "$pkg_manager" = "deb" ]; then
        dpkg --purge wnbtlscli 2>/dev/null
        apt-get remove -y wnbmonitor 2>/dev/null
        apt-get remove -y wnbtlscli 2>/dev/null
    elif [ "$pkg_manager" = "rpm" ]; then
        rpm -e wnbtlscli 2>/dev/null
        rpm -e wnbmonitor 2>/dev/null
    fi
    
    echo " Removendo diretórios antigos..."
    rm -rf /etc/wnbtlscli
    rm -rf /var/log/wnb
    
    echo " Instalação antiga removida."
}

# Instala o pacote correto
install_package() {
    local arch="$1"
    local pkg_manager="$2"
    local package=""
    
    echo ""
    echo "=========================================="
    echo " Instalando novo pacote..."
    echo "=========================================="
    
    if [ "$pkg_manager" = "deb" ]; then
        package="${SCRIPT_DIR}/wnbtlscli_2.5.1_${arch}.deb"
        if [ -f "$package" ]; then
            echo " Instalando pacote: $package"
            dpkg -i "$package"
        else
            echo " Erro: Pacote não encontrado para arquitetura $arch"
            return 1
        fi
    elif [ "$pkg_manager" = "rpm" ]; then
        if [ "$arch" = "amd64" ]; then
            package="${SCRIPT_DIR}/wnbtlscli-2.5.1_amd64.rpm"
            if [ -f "$package" ]; then
                echo " Instalando pacote: $package"
                rpm -Uvh "$package"
            else
                echo " Erro: Pacote RPM não encontrado"
                return 1
            fi
        else
            echo " Erro: Pacote RPM disponível apenas para amd64"
            return 1
        fi
    else
        echo " Erro: Gerenciador de pacotes não suportado"
        return 1
    fi
}

# ==========================================
# INÍCIO DO SCRIPT
# ==========================================

echo ""
echo "=========================================="
echo " WNB TLS CLI - Instalador v2.5.1"
echo "=========================================="

ARCH=$(detect_architecture)
PKG_MANAGER=$(detect_package_manager)

echo " Arquitetura detectada: $ARCH"
echo " Gerenciador de pacotes: $PKG_MANAGER"

if [ "$ARCH" = "unsupported" ]; then
    echo " Erro: Arquitetura não suportada: $(uname -m)"
    exit 1
fi

# 1. Para os serviços
echo ""
echo "=========================================="
echo " Parando serviços..."
echo "=========================================="
systemctl stop wnbmonitor 2>/dev/null
systemctl stop wnbtlscli 2>/dev/null
echo " Serviços parados."

# 2. Exibe a chave TLS caso exista instalação antiga
if [ -f "/etc/wnbtlscli/registry" ]; then
    echo ""
    echo "=========================================="
    echo " ATENÇÃO: Instalação anterior detectada!"
    echo "=========================================="
    echo " Chave TLS atual:"
    echo "------------------------------------------"
    cat /etc/wnbtlscli/registry
    echo "------------------------------------------"
    echo ""
    echo " IMPORTANTE: Anote a chave acima antes de continuar!"
    echo ""
    read -p " Pressione ENTER para continuar ou CTRL+C para cancelar..."
    
    # 3. Remove instalação antiga
    remove_old_installation "$PKG_MANAGER"
else
    echo ""
    echo " Nenhuma instalação anterior detectada."
fi

# 4. Instala o pacote
install_package "$ARCH" "$PKG_MANAGER" || exit 1

# Configura serviços
echo ""
echo "=========================================="
echo " Configurando serviços..."
echo "=========================================="
systemctl enable wnbmonitor
systemctl enable wnbtlscli

if [ -f "/etc/wnbtlscli/registry" ]; then
    oldver=$(grep -c systemd /etc/wnbtlscli/registry)
    if [ "$oldver" = 0 ]; then
        echo "systemd: true" >> /etc/wnbtlscli/registry
        echo "log_level: 3" >> /etc/wnbtlscli/registry
    fi
    echo " Iniciando serviços..."
    systemctl start wnbmonitor
    echo " Instalação concluída com sucesso!"
else
    echo ""
    echo "=========================================="
    echo " PRÓXIMO PASSO"
    echo "=========================================="
    echo " Execute o comando abaixo para registrar:"
    echo " wnbupdate -k XXXX"
    echo "=========================================="
fi

exit 0
