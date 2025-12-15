#!/bin/bash
#
# utilities.sh - Funções utilitárias para o SysPDV PDV em Linux
#
# Versão: 7.0
# Autor: Matheus Wesley
# GitHub: https://matheuswesley.github.io/devlinks
# GitHub Projeto: https://matwdot.github.
# Licença: MIT
#
# Este script contém funções auxiliares para mensagens, validações e
# operações comuns do sistema SysPDV PDV em ambientes Linux.
#
# *************************************************************

# Carrega as cores se não estiverem definidas
if [[ -z "${RED}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck source=../../colors.sh
  source "${SCRIPT_DIR}/../../colors.sh" 2>/dev/null || {
    RED='\033[1;31m'
    GREEN='\033[1;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[1;34m'
    BOLD='\033[1m'
    NC='\033[0m'
  }
fi

# *************************************************************
# MENSAGENS PADRÃO
# *************************************************************

# shellcheck disable=SC2317
# Mensagem de erro
error_msg() {
  echo -e "${RED}✘ $1${NC}" >&2
}

# Mensagem de sucesso
success_msg() {
  echo -e "${GREEN}✔ $1${NC}"
}

# Mensagem de atenção
warning_msg() {
  echo -e "${YELLOW}➜ $1${NC}"
}

# Mensagem informativa
info_msg() {
  echo -e "${BLUE}➜ $1${NC}"
}

# Mensagem solicitação
print_msg() {
  echo -e -n "${BLUE}➜ $1 ${NC}"
}

# Mensagem neutra
bold_msg() {
  echo -e "${BOLD}$1${NC}"
}

# *************************************************************
# FUNÇÕES DE VALIDAÇÃO E CONFIRMAÇÃO
# *************************************************************

# Função para confirmação de dados
confirm_action() {
  local message=$1
  local default="${2:-s}" # Padrão é 's' se não especificado
  
  trap 'echo -e "\n${RED}Operação cancelada pelo usuário.${NC}"; return 1' INT

  while true; do
    if [[ "$default" == "s" ]]; then
      echo -n -e "${YELLOW}${message} (S/n): ${NC}"
    else
      echo -n -e "${YELLOW}${message} (s/N): ${NC}"
    fi
    
    read -r confirm
    
    # Se vazio, usa o padrão
    [[ -z "$confirm" ]] && confirm="$default"
    
    # Converte para minúsculas
    confirm=$(echo "$confirm" | tr '[:upper:]' '[:lower:]')
    
    case "$confirm" in
      s|sim|y|yes) 
        trap - INT
        return 0 
        ;;
      n|nao|não|no) 
        echo "Operação cancelada."
        trap - INT
        return 1
        ;;
      *) 
        error_msg "Opção inválida. Digite S para Sim ou N para Não." 
        ;;
    esac
  done
}

# Verifica se o script está sendo executado como root
check_root() {
  if [[ $EUID -ne 0 ]]; then
    error_msg "Este script precisa ser executado como root (sudo)."
    return 1
  fi
  return 0
}

# Verifica se um comando existe
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Verifica se um pacote está instalado (dpkg/rpm)
package_installed() {
  local package=$1
  if command_exists dpkg; then
    dpkg -l "$package" 2>/dev/null | grep -q "^ii"
  elif command_exists rpm; then
    rpm -q "$package" >/dev/null 2>&1
  else
    return 1
  fi
}

# Valida se uma string é um número
is_number() {
  [[ "$1" =~ ^[0-9]+$ ]]
}

# Valida se uma string é um IP válido
is_valid_ip() {
  local ip=$1
  local regex='^([0-9]{1,3}\.){3}[0-9]{1,3}$'
  
  if [[ $ip =~ $regex ]]; then
    local IFS='.'
    read -ra octets <<< "$ip"
    for octet in "${octets[@]}"; do
      if ((octet > 255)); then
        return 1
      fi
    done
    return 0
  fi
  return 1
}

# *************************************************************
# FUNÇÕES DE SISTEMA
# *************************************************************

# Pausa a execução e aguarda o usuário pressionar Enter
pause() {
  local message="${1:-Pressione ENTER para continuar...}"
  echo -n -e "${BLUE}${message}${NC}"
  read -r
}

# Limpa a tela
clear_screen() {
  clear
}

# *************************************************************
# FUNÇÕES DE CONTROLE DE FLUXO
# *************************************************************

# Função de saída limpa
exit_script() {
  local exit_code="${1:-0}"
  clear
  exit "$exit_code"
}

# Função para tratar erros críticos
die() {
  error_msg "$1"
  exit "${2:-1}"
}

# *************************************************************
# FUNÇÕES DE ARQUIVO E DIRETÓRIO
# *************************************************************

# Cria um backup de um arquivo
backup_file() {
  local file=$1
  local backup_dir="${2:-.}"
  
  if [[ ! -f "$file" ]]; then
    error_msg "Arquivo não encontrado: $file"
    return 1
  fi
  
  local timestamp=$(date +%Y%m%d_%H%M%S)
  local filename=$(basename "$file")
  local backup_path="${backup_dir}/${filename}.backup_${timestamp}"
  
  if cp "$file" "$backup_path"; then
    success_msg "Backup criado: $backup_path"
    echo "$backup_path"
    return 0
  else
    error_msg "Falha ao criar backup de $file"
    return 1
  fi
}

# Verifica se um diretório existe, se não, cria
ensure_directory() {
  local dir=$1
  if [[ ! -d "$dir" ]]; then
    if mkdir -p "$dir" 2>/dev/null; then
      success_msg "Diretório criado: $dir"
      return 0
    else
      error_msg "Falha ao criar diretório: $dir"
      return 1
    fi
  fi
  return 0
}

# *************************************************************
# FUNÇÕES DE LOG
# *************************************************************

# Registra mensagem em arquivo de log
log_message() {
  local level=$1
  local message=$2
  local log_file="${3:-/var/log/sysutil.log}"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  
  echo "[${timestamp}] [${level}] ${message}" >> "$log_file" 2>/dev/null
}

# Wrapper para log de erro
log_error() {
  log_message "ERROR" "$1" "$2"
}

# Wrapper para log de info
log_info() {
  log_message "INFO" "$1" "$2"
}

# Wrapper para log de warning
log_warning() {
  log_message "WARNING" "$1" "$2"
}
