#!/bin/bash
#
# menu_system.sh - Sistema de menus para SysUtil
#
# Versão: 8.0
# Autor: Matheus Wesley
# GitHub: https://matheuswesley.github.io/devlinks
# GitHub Projeto: https://matwdot.github.io
# Licença: MIT
#
# Este arquivo contém todas as funções relacionadas ao sistema de menus
# (menu em Bash puro, igual no Ubuntu 18.04 e 22.04; sem fzf)
#
# *************************************************************

# ---------------------
# Captura uma tecla. Setas chegam como "[A" (cima) e "[B" (baixo).
# ESC sozinho devolve "ESC" (não fica esperando mais teclas).
# ---------------------
get_input() {
  local key rest wait=1
  # Timeout fracionado só existe no bash 4+ (Ubuntu 18.04 e 22.04 têm)
  ((BASH_VERSINFO[0] >= 4)) && wait=0.1
  # Entrada fechada (sem teclado, ex.: ssh caiu). get_input roda em $(...),
  # então não pode dar exit aqui: devolve "EOF" e o navigate_menu encerra.
  if ! IFS= read -rsn1 key; then
    echo "EOF"
    return 0
  fi
  if [[ $key == $'\x1b' ]]; then
    if IFS= read -rsn2 -t "$wait" rest; then
      key="$rest"
    else
      key="ESC"
    fi
  fi
  echo "$key"
}

# ---------------------
# Banner da marca (fonte "poison", centralizado na moldura do menu)
# ---------------------
# Versão vem de config/version.sh ($VERSION), a fonte única
SYSUTIL_VERSION="${VERSION:-8.0.0}"
MENU_WIDTH=64

show_banner() {
  local version="v${SYSUTIL_VERSION}"
  local cols art_width=61
  local art=(
    ' @@@@@@   @@@ @@@   @@@@@@   @@@  @@@  @@@@@@@  @@@  @@@'
    '@@@@@@@   @@@ @@@  @@@@@@@   @@@  @@@  @@@@@@@  @@@  @@@'
    '!@@       @@! !@@  !@@       @@!  @@@    @@!    @@!  @@!'
    '!@!       !@! @!!  !@!       !@!  @!@    !@!    !@!  !@!'
    '!!@@!!     !@!@!   !!@@!!    @!@  !@!    @!!    !!@  @!!'
    ' !!@!!!     @!!!    !!@!!!   !@!  !!!    !!!    !!!  !!!'
    '     !:!    !!:         !:!  !!:  !!!    !!:    !!:  !!:'
    '    !:!     :!:        !:!   :!:  !:!    :!:    :!:   :!:'
    ':::: ::      ::    :::: ::   ::::: ::     ::     ::   :: ::::'
    ':: : :       :     :: : :     : :  :      :     :    : :: : :'
  )
  local pad line

  cols=$(tput cols 2>/dev/null || echo 80)
  if [[ $cols -lt $MENU_WIDTH ]]; then
    # terminal estreito: título simples
    printf -v pad '%*s' $(((cols - 8 - ${#version}) / 2 > 0 ? (cols - 8 - ${#version}) / 2 : 0)) ''
    echo -e "${pad}${BOLD}SysUtil${NC} ${version}"
    return
  fi

  printf -v pad '%*s' $(((MENU_WIDTH > art_width ? MENU_WIDTH - art_width : 0) / 2)) ''
  for line in "${art[@]}"; do
    echo -e "${BOLD}${pad}${line}${NC}"
  done

  printf -v pad '%*s' $(((MENU_WIDTH - ${#version}) / 2)) ''
  echo "${pad}${version}"
}

menu_line() {
  printf -v _line '%*s' "$MENU_WIDTH" ''
  echo "${_line// /-}"
}

# ---------------------
# Símbolos: Unicode se o terminal for UTF-8, ASCII caso contrário
# ---------------------
case "${LC_ALL:-${LC_CTYPE:-$LANG}}" in
  *[Uu][Tt][Ff]-8* | *[Uu][Tt][Ff]8*)
    MENU_WARN="⚠"; MENU_ARROW="➜"; MENU_EXIT="✘"; MENU_UP="↑"; MENU_DOWN="↓" ;;
  *)
    MENU_WARN="!"; MENU_ARROW=">"; MENU_EXIT="x"; MENU_UP="^"; MENU_DOWN="v" ;;
esac

# ---------------------
# Aviso de que o SysUtil está rodando como root
# ---------------------
show_root_notice() {
  [[ "$(id -u)" -eq 0 ]] || return 0
  if [[ -n "${SUDO_USER:-}" && "$SUDO_USER" != "root" ]]; then
    echo -e " ${YELLOW}${MENU_WARN} Executando como root (aberto por: ${SUDO_USER})${NC}"
  else
    echo -e " ${YELLOW}${MENU_WARN} Executando como root${NC}"
  fi
}

# ---------------------
# Exibição do menu
# ---------------------
show_menu() {
  local highlight=$1
  shift
  local options=("$@")
  local i label

  clear
  menu_line
  show_banner
  menu_line
  show_root_notice
  [[ -n "$MENU_TITLE" ]] && echo -e "  ${BOLD}${MENU_TITLE}${NC}" && echo

  for i in "${!options[@]}"; do
    label="${options[$i]}"
    if [[ $i -eq $highlight ]]; then
      if [[ "$label" == "Sair" || "$label" == "Voltar" ]]; then
        echo -e "${RED} ${MENU_EXIT} $((i + 1))) ${label}${NC}"
      else
        echo -e "${GREEN} ${MENU_ARROW} $((i + 1))) ${label}${NC}"
      fi
    else
      echo "   $((i + 1))) ${label}"
    fi
  done

  menu_line
  echo -e " ${BOLD}${MENU_UP}${NC}/${BOLD}${MENU_DOWN}${NC} navegar   ${BOLD}Enter${NC} selecionar   ${BOLD}1-9${NC} atalho   ${BOLD}q${NC} voltar/sair"
  menu_line
}

# ---------------------
# Navegação do menu
# Retorna (via $?) o índice escolhido. "q" e ESC escolhem a última opção
# (Sair/Voltar).
# ---------------------
navigate_menu() {
  local options=("$@")
  local last=$((${#options[@]} - 1))
  local current_selection=0
  local key

  while true; do
    show_menu "$current_selection" "${options[@]}"
    key=$(get_input)

    case "$key" in
      '[A' | 'OA' | k)
        ((current_selection > 0)) && ((current_selection--))
        ;;
      '[B' | 'OB' | j)
        ((current_selection < last)) && ((current_selection++))
        ;;
      '')
        return $current_selection
        ;;
      q | Q | ESC)
        return $last
        ;;
      EOF)
        echo
        exit 0
        ;;
      [1-9])
        if ((key <= ${#options[@]})); then
          return $((key - 1))
        fi
        ;;
    esac
  done
}

# ---------------------
# Seleciona uma opção: $1 = título, demais = opções
# ---------------------
select_menu() {
  MENU_TITLE="$1"
  shift
  navigate_menu "$@"
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
    
    # Escolheu Voltar (ou q/ESC)
    [[ $result -eq $exit_index ]] && return
    
    # Verifica se o índice é válido
    if [[ $result -ge 0 && $result -lt ${#menu_functions[@]} ]]; then
      clear
      ${menu_functions[$result]}
      echo -e "${GREEN}Operação concluída!${NC}"
      read -r -p "Pressione Enter para continuar..."
    fi
  done
}
