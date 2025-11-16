#!/bin/bash
#
# menu_system.sh - Sistema de menus para SysUtil
#
# Versão: 7.0
# Autor: Matheus Wesley
# GitHub: https://matheuswesley.github.io/devlinks
# GitHub Projeto: https://matwdot.github.io
# Licença: MIT
#
# Este arquivo contém todas as funções relacionadas ao sistema de menus
# (tradicional e fzf)
#
# *************************************************************

# ---------------------
# Função para capturar entrada do teclado (método tradicional)
# ---------------------
get_input() {
  read -s -n 1 key
  [[ $key == $'\x1b' ]] && read -s -n 2 key
  echo "$key"
}

# ---------------------
# Exibição do menu interativo (método tradicional)
# ---------------------
show_menu() {
  local highlight=$1
  shift
  local options=("$@")
  
  clear
  echo "------------------------------------------"
  echo -e "${BOLD}           SysUtil v7.0 beta${NC}"
  echo "------------------------------------------"
  
  for i in "${!options[@]}"; do
    if [[ $i -eq $highlight ]]; then
      if [[ "${options[$i]}" == "Sair" || "${options[$i]}" == "Voltar" ]]; then
        echo -e "${RED}✘ ${options[$i]}${NC}"
      else
        echo -e "${GREEN}➜ ${options[$i]}${NC}"
      fi
    else
      echo "  ${options[$i]}"
    fi
  done
  
  echo "------------------------------------------"
  echo -e "Navegue com ${BOLD}↑${NC}/${BOLD}↓${NC} e selecione com ${BOLD}Enter${NC}."
  echo "------------------------------------------"
}

# ---------------------
# Navegação do menu tradicional
# ---------------------
navigate_menu() {
  local options=("$@")
  local current_selection=0
  
  while true; do
    show_menu "$current_selection" "${options[@]}"
    
    case $(get_input) in
      '[A') 
        ((current_selection > 0)) && ((current_selection--))
        ;;
      '[B') 
        ((current_selection < ${#options[@]} - 1)) && ((current_selection++))
        ;;
      '') 
        return $current_selection
        ;;
      '0' | 'q')
        clear
        exit 0
        ;;
    esac
  done
}

# ---------------------
# Menu com fzf
# ---------------------
fzf_menu() {
  clear
  
  local title=$1
  shift
  local options=("$@")
  
  local selected=$(printf '%s\n' "${options[@]}" | fzf \
    --prompt="» " \
    --style full \
    --border=rounded \
    --margin=1 \
    --padding=1 \
    --reverse \
    --header="Digite para pesquisar | ESC para sair")
  
  # Retorna o índice da opção selecionada
  for i in "${!options[@]}"; do
    [[ "${options[$i]}" == "$selected" ]] && return $i
  done
  
  # Se ESC foi pressionado, retorna código especial
  return 255
}

# ---------------------
# Wrapper para escolher método de menu
# ---------------------
select_menu() {
  if $HAS_FZF; then
    fzf_menu "$@"
  else
    shift  # Remove o título (não usado no menu tradicional)
    navigate_menu "$@"
  fi
}

# ---------------------
# Função genérica para submenus
# ---------------------
submenu() {
  local title=$1
  shift
  
  # Copia os arrays recebidos via eval
  local menu_options=()
  local menu_functions=()
  
  # Primeiro array: opções
  while [[ $# -gt 0 && "$1" != "--" ]]; do
    menu_options+=("$1")
    shift
  done
  
  # Pula o separador "--"
  [[ "$1" == "--" ]] && shift
  
  # Segundo array: funções
  while [[ $# -gt 0 ]]; do
    menu_functions+=("$1")
    shift
  done
  
  local exit_index=$((${#menu_options[@]} - 1))
  
  while true; do
    select_menu "$title" "${menu_options[@]}"
    local result=$?
    
    # Se ESC no fzf ou escolheu Voltar
    [[ $result -eq 255 || $result -eq $exit_index ]] && return
    
    # Verifica se o índice é válido
    if [[ $result -ge 0 && $result -lt ${#menu_functions[@]} ]]; then
      clear
      ${menu_functions[$result]}
      echo -e "${GREEN}Operação concluída!${NC}"
      read -p "Pressione Enter para continuar..."
    fi
  done
}
