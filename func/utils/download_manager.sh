#!/bin/bash
# Download Manager - SysUtil
# Gerencia downloads de dependências sob demanda

# Importar utilities se não estiver carregado
if [[ -z "$(type -t error_msg)" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck source=utilities.sh
  source "${SCRIPT_DIR}/utilities.sh" || {
    echo "ERRO: Não foi possível carregar utilities.sh"
    exit 1
  }
fi

# Carregar configurações de download
load_download_config() {
    local config_file="$1"
    if [[ -f "$config_file" ]]; then
        # shellcheck source=/dev/null
        source "$config_file"
    else
        error_msg "Arquivo de configuração não encontrado: $config_file"
        return 1
    fi
}

# Criar diretório de downloads se não existir
ensure_downloads_dir() {
    if [[ -n "$DOWNLOADS_DIR" ]]; then
        ensure_directory "$DOWNLOADS_DIR"
    else
        error_msg "DOWNLOADS_DIR não está definido"
        return 1
    fi
}

# Verificar se arquivo já foi baixado
is_downloaded() {
    local filename="$1"
    local filepath="${DOWNLOADS_DIR}/${filename}"
    
    [[ -f "$filepath" ]]
}

# Baixar arquivo com verificação de integridade
download_file() {
    local url="$1"
    local filename="$2"
    local expected_sha256="$3"
    local filepath="${DOWNLOADS_DIR}/${filename}"
    
    # Verificar se já existe
    if is_downloaded "$filename"; then
        info_msg "Arquivo já existe: $filename"
        return 0
    fi
    
    info_msg "Baixando: $filename"
    info_msg "URL: $url"
    
    # Baixar com curl
    if ! curl --fail --location --progress-bar \
             --connect-timeout 30 \
             --max-time "${DOWNLOAD_TIMEOUT:-300}" \
             --output "$filepath" \
             "$url"; then
        error_msg "Falha ao baixar: $filename"
        rm -f "$filepath"
        return 1
    fi
    
    # Verificar integridade se hash fornecido
    if [[ -n "$expected_sha256" && "$expected_sha256" != "# TODO:"* ]]; then
        info_msg "Verificando integridade..."
        if ! echo "$expected_sha256  $filepath" | sha256sum -c -; then
            error_msg "Checksum inválido para: $filename"
            rm -f "$filepath"
            return 1
        fi
        success_msg "Integridade verificada: $filename"
    fi
    
    success_msg "Download concluído: $filename"
    return 0
}

# Baixar DocGate V5
download_docgate() {
    local config_file="${1:-config/downloads.conf}"
    
    if ! load_download_config "$config_file"; then
        return 1
    fi
    
    ensure_downloads_dir || return 1
    
    download_file "$DOCGATE_URL" "docgateV5.tar.gz" "$DOCGATE_SHA256"
}

# Baixar pacote VPN específico
download_vpn_package() {
    local package_type="$1"  # amd64_deb, arm64_deb, etc.
    local config_file="${2:-config/downloads.conf}"
    
    if ! load_download_config "$config_file"; then
        return 1
    fi
    
    ensure_downloads_dir || return 1
    
    case "$package_type" in
        "amd64_deb")
            download_file "$VPN_AMD64_DEB_URL" "wnbtlscli_2.5.1_amd64.deb" ""
            ;;
        "arm64_deb")
            download_file "$VPN_ARM64_DEB_URL" "wnbtlscli_2.5.1_arm64.deb" ""
            ;;
        "armhf_deb")
            download_file "$VPN_ARMHF_DEB_URL" "wnbtlscli_2.5.1_armhf.deb" ""
            ;;
        "i386_deb")
            download_file "$VPN_I386_DEB_URL" "wnbtlscli_2.5.1_i386.deb" ""
            ;;
        "amd64_rpm")
            download_file "$VPN_AMD64_RPM_URL" "wnbtlscli-2.5.1_amd64.rpm" ""
            ;;
        "installer_tar")
            download_file "$VPN_INSTALLER_TAR_URL" "installer-2_5_1.tar" ""
            ;;
        *)
            error_msg "Tipo de pacote VPN inválido: $package_type"
            return 1
            ;;
    esac
}

# Obter caminho do arquivo baixado
get_download_path() {
    local filename="$1"
    echo "${DOWNLOADS_DIR}/${filename}"
}

# Limpar cache de downloads
clean_downloads() {
    if [[ -d "$DOWNLOADS_DIR" ]]; then
        info_msg "Limpando cache de downloads..."
        rm -rf "$DOWNLOADS_DIR"
        success_msg "Cache limpo"
    else
        info_msg "Cache já está limpo"
    fi
}

# Listar arquivos baixados
list_downloads() {
    if [[ -d "$DOWNLOADS_DIR" ]]; then
        info_msg "Arquivos baixados:"
        ls -lh "$DOWNLOADS_DIR" 2>/dev/null || info_msg "Nenhum arquivo encontrado"
    else
        info_msg "Diretório de downloads não existe"
    fi
}

# Função principal para testes
main() {
    case "${1:-}" in
        "docgate")
            download_docgate
            ;;
        "vpn")
            download_vpn_package "${2:-amd64_deb}"
            ;;
        "clean")
            clean_downloads
            ;;
        "list")
            list_downloads
            ;;
        *)
            echo "Uso: $0 {docgate|vpn <tipo>|clean|list}"
            echo "Tipos VPN: amd64_deb, arm64_deb, armhf_deb, i386_deb, amd64_rpm, installer_tar"
            ;;
    esac
}

# Executar se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi