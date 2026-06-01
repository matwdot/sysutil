#!/bin/bash
#
# peripherals.sh - Gerenciamento de configuração de periféricos USB/Serial
#
# Versão: 8.0
# Autor: Matheus Wesley
# GitHub: https://matheuswesley.github.io/devlinks
# Licença: MIT
#
# *************************************************************

# Import utilities if not loaded
if [[ -z "$(type -t error_msg)" ]]; then
  SCRIPT_DIR_PERIPH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck source=utils/utilities.sh
  source "${SCRIPT_DIR_PERIPH}/utilities.sh" || {
    echo "ERRO: Não foi possível carregar utilities.sh"
    exit 1
  }
  unset SCRIPT_DIR_PERIPH
fi

# Import menu system if not loaded
if [[ -z "$(type -t select_menu)" ]]; then
  SCRIPT_DIR_PERIPH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck source=utils/menu_system.sh
  source "${SCRIPT_DIR_PERIPH}/menu_system.sh" 2>/dev/null || true
  unset SCRIPT_DIR_PERIPH
fi

# Arquivos de configuração
RULES_FILE="/etc/udev/rules.d/90-dispositivos-usb.rules"
SETTY_FILE="/usr/local/bin/setty"

# *************************************************************
# LISTAGEM DE DISPOSITIVOS
# *************************************************************

# Lista todos os nomes de dispositivos disponíveis nas regras udev
listar_dispositivos() {
  local rules_file="${1:-$RULES_FILE}"

  if [[ ! -f "$rules_file" ]]; then
    error_msg "Arquivo de regras udev não encontrado: $rules_file"
    return 1
  fi

  grep -P '^# [[:alpha:][:digit:]]' "$rules_file" 2>/dev/null | \
    sed 's/^# //' | \
    grep -vE '^-+$|Regras UDEV'
}

# *************************************************************
# LEITURA DE IDs
# *************************************************************

# Obtém o idVendor de um dispositivo nas regras udev
obter_id_vendor() {
  local dispositivo="$1"
  local rules_file="${2:-$RULES_FILE}"

  local linha_num
  linha_num=$(grep -F -x -n "# $dispositivo" "$rules_file" 2>/dev/null | head -1 | cut -d: -f1)
  [[ -z "$linha_num" ]] && return 1

  local kernel_line
  kernel_line=$(tail -n +"$linha_num" "$rules_file" | grep -m1 '^KERNEL==')
  [[ -z "$kernel_line" ]] && return 1

  echo "$kernel_line" | sed -n 's/.*idVendor}=="\([^"]*\)".*/\1/p'
}

# Obtém o idProduct de um dispositivo nas regras udev
obter_id_product() {
  local dispositivo="$1"
  local rules_file="${2:-$RULES_FILE}"

  local linha_num
  linha_num=$(grep -F -x -n "# $dispositivo" "$rules_file" 2>/dev/null | head -1 | cut -d: -f1)
  [[ -z "$linha_num" ]] && return 1

  local kernel_line
  kernel_line=$(tail -n +"$linha_num" "$rules_file" | grep -m1 '^KERNEL==')
  [[ -z "$kernel_line" ]] && return 1

  echo "$kernel_line" | sed -n 's/.*idProduct}=="\([^"]*\)".*/\1/p'
}

# *************************************************************
# VALIDAÇÃO
# *************************************************************

# Valida hexadecimal de 4 dígitos
validar_hex() {
  local valor="$1"
  [[ "$valor" =~ ^[0-9a-fA-F]{4}$ ]]
}

# *************************************************************
# APLICAÇÃO DE ALTERAÇÕES
# *************************************************************

# Mostra preview da alteração antes de aplicar
mostrar_alteracao() {
  local dispositivo="$1"
  local vendor_atual="$2"
  local product_atual="$3"
  local vendor_novo="$4"
  local product_novo="$5"

  echo ""
  bold_msg "Resumo das alterações:"
  echo ""
  printf "  %-30s ${YELLOW}%s${NC} → ${GREEN}%s${NC}\n" \
    "$dispositivo" \
    "${vendor_atual}:${product_atual}" \
    "${vendor_novo}:${product_novo}"
  echo ""
}

# Aplica a alteração nos arquivos e recarrega os serviços
aplicar_alteracao() {
  local dispositivo="$1"
  local vendor_atual="$2"
  local product_atual="$3"
  local vendor_novo="$4"
  local product_novo="$5"

  # Backup dos arquivos
  info_msg "Criando backup dos arquivos..."
  backup_file "$RULES_FILE" || {
    error_msg "Falha ao criar backup de $RULES_FILE"
    return 1
  }
  backup_file "$SETTY_FILE" || {
    error_msg "Falha ao criar backup de $SETTY_FILE"
    return 1
  }

  # Atualiza regras udev
  if sudo sed -i "s/${vendor_atual}/${vendor_novo}/g" "$RULES_FILE" && \
     sudo sed -i "s/${product_atual}/${product_novo}/g" "$RULES_FILE"; then
    success_msg "Regras udev atualizadas"
  else
    error_msg "Erro ao atualizar regras udev"
    return 1
  fi

  # Atualiza setty (apenas se o padrão existir no arquivo)
  if grep -q "${vendor_atual}:${product_atual}" "$SETTY_FILE" 2>/dev/null; then
    if sudo sed -i "s/${vendor_atual}:${product_atual}/${vendor_novo}:${product_novo}/g" "$SETTY_FILE"; then
      success_msg "Arquivo setty atualizado"
    else
      error_msg "Erro ao atualizar setty"
      return 1
    fi
  else
    warning_msg "Dispositivo não encontrado no setty (apenas regras udev foram alteradas)"
  fi

  # Recarrega regras udev
  if command_exists udevadm; then
    sudo udevadm control --reload-rules 2>/dev/null
    sudo udevadm trigger 2>/dev/null
    success_msg "Regras udev recarregadas"
  fi

  # Reexecuta setty
  if [[ -x "$SETTY_FILE" ]]; then
    sudo "$SETTY_FILE"
    success_msg "Setty reexecutado"
  fi

  return 0
}

# *************************************************************
# FLUXO INTERATIVO
# *************************************************************

# Fluxo interativo para configurar um dispositivo específico
configurar_dispositivo_interativo() {
  local dispositivos=()

  while IFS= read -r dev; do
    dispositivos+=("$dev")
  done < <(listar_dispositivos)

  if [[ ${#dispositivos[@]} -eq 0 ]]; then
    error_msg "Nenhum dispositivo encontrado em $RULES_FILE"
    pause
    return 1
  fi

  # Monta array para o menu (adiciona Voltar no final)
  local opcoes=("${dispositivos[@]}" "Voltar")
  local voltar_index=$((${#opcoes[@]} - 1))

  while true; do
    clear
    bold_msg "Dispositivos disponíveis:"
    echo ""

    select_menu "Selecione o dispositivo" "${opcoes[@]}"
    local escolha=$?

    # ESC ou Voltar
    if [[ $escolha -eq 255 || $escolha -eq $voltar_index ]]; then
      clear
      return
    fi

    local dispositivo="${dispositivos[$escolha]}"
    local vendor_atual product_atual

    vendor_atual=$(obter_id_vendor "$dispositivo")
    product_atual=$(obter_id_product "$dispositivo")

    if [[ -z "$vendor_atual" || -z "$product_atual" ]]; then
      error_msg "Não foi possível ler as configurações de: $dispositivo"
      pause
      continue
    fi

    clear
    bold_msg "Dispositivo: $dispositivo"
    echo ""
    info_msg "Configuração atual:"
    echo "  idVendor:  ${YELLOW}${vendor_atual}${NC}"
    echo "  idProduct: ${YELLOW}${product_atual}${NC}"
    echo ""

    print_msg "Novo idVendor (Enter para manter ${vendor_atual}):"
    read -r novo_vendor
    [[ -z "$novo_vendor" ]] && novo_vendor="$vendor_atual"

    print_msg "Novo idProduct (Enter para manter ${product_atual}):"
    read -r novo_product
    [[ -z "$novo_product" ]] && novo_product="$product_atual"

    # Validação do vendor
    if [[ "$novo_vendor" != "$vendor_atual" ]] && ! validar_hex "$novo_vendor"; then
      error_msg "idVendor inválido. Use 4 dígitos hexadecimais (ex: 067b)"
      pause
      continue
    fi

    # Validação do product
    if [[ "$novo_product" != "$product_atual" ]] && ! validar_hex "$novo_product"; then
      error_msg "idProduct inválido. Use 4 dígitos hexadecimais (ex: 2303)"
      pause
      continue
    fi

    # Se nenhuma alteração foi feita
    if [[ "$novo_vendor" == "$vendor_atual" && "$novo_product" == "$product_atual" ]]; then
      info_msg "Nenhuma alteração necessária."
      pause
      continue
    fi

    # Preview
    mostrar_alteracao "$dispositivo" "$vendor_atual" "$product_atual" "$novo_vendor" "$novo_product"

    # Confirmação
    if confirm_action "Aplicar esta alteração?"; then
      aplicar_alteracao "$dispositivo" "$vendor_atual" "$product_atual" "$novo_vendor" "$novo_product"
    else
      info_msg "Alteração cancelada."
    fi

    pause
  done
}
