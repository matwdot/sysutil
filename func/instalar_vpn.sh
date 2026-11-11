#!/bin/bash
#
# sysutil.sh - Script de utilitários para o SysPDV PDV em Linux
#
# Versão: 5.2
# Autor: Matheus Wesley
# GitHub: https://matheuswesley.github.io/devlinks
# GitHub Projeto: https://matwdot.github.
# Licença: MIT
#
# Este script contém um conjunto de funções para instalação, atualização e
# manutenção do sistema SysPDV PDV em ambientes Linux.
#
# **************************************************************

# Arquivo com a versão do sistema (pode ser trocado em testes)
OS_RELEASE_FILE="${SYSUTIL_OS_RELEASE:-/etc/os-release}"

# Pacote da VPN para o Ubuntu 18.04 (SysPDV é sempre 32 bits)
VPN_DEB_1804="dep/wnbtlscli_2_5_1/wnbtlscli_2.5.1_i386.deb"

# Mostra a versão do Ubuntu ("18.04", "22.04"...) ou nada se não for Ubuntu
ubuntu_version() {
  [[ -r "$OS_RELEASE_FILE" ]] || return 1
  local id version
  # shellcheck source=/dev/null
  id=$(. "$OS_RELEASE_FILE" && echo "$ID")
  # shellcheck source=/dev/null
  version=$(. "$OS_RELEASE_FILE" && echo "$VERSION_ID")
  [[ "$id" == "ubuntu" && -n "$version" ]] || return 1
  echo "$version"
}

# Pede a chave e registra a VPN. $1 = comando que recebe a chave
registrar_chave_vpn() {
  local cmd="$1" key
  info_msg "Informe a chave da VPN: "
  read -r key
  if [[ -z "$key" ]]; then
    error_msg "Nenhuma chave informada. Registre depois com: $cmd -k <chave>"
    return 1
  fi
  if sudo "$cmd" -k "$key" && sudo wnbmonitor -r; then
    sleep 2
    success_msg "VPN instalada com sucesso!"
  else
    error_msg "VPN instalada, mas houve erro ao registrar a chave."
    return 1
  fi
}

# Ubuntu 18.04: pacote .deb local (i386)
instalar_vpn_1804() {
  info_msg "Iniciando a instalação da VPN para versão 18.04..."
  if [[ ! -f "$VPN_DEB_1804" ]]; then
    error_msg "Pacote não encontrado: $VPN_DEB_1804"
    return 1
  fi
  if ! sudo dpkg -i "$VPN_DEB_1804"; then
    error_msg "Erro ao instalar a VPN. Verifique permissões e tente novamente."
    sleep 2
    return 1
  fi
  registrar_chave_vpn wnbupdate
}

# Ubuntu 22.04 ou superior: instalador on-line do fornecedor
instalar_vpn_2204() {
  info_msg "Iniciando a instalação da VPN para versão 22.04 ou superior..."
  if ! sudo bash ./dep/wnbinstall.sh -i; then
    error_msg "Erro ao instalar a VPN. Verifique permissões e tente novamente."
    sleep 2
    return 1
  fi
  registrar_chave_vpn wnbmonitor
}

# Instala VPN (escolhe o método pela versão do Ubuntu)
instalar_vpn() {
  if ! confirm_action "Deseja instalar a VPN?"; then
    info_msg "Configuração da VPN cancelada."
    return 0
  fi

  local versao
  versao=$(ubuntu_version)

  case "$versao" in
    18.04)
      info_msg "Ubuntu 18.04 detectado."
      instalar_vpn_1804
      ;;
    22.04)
      info_msg "Ubuntu 22.04 detectado."
      instalar_vpn_2204
      ;;
    *)
      # Versão não suportada oficialmente: pergunta, como antes
      warning_msg "Versão do sistema não reconhecida (${versao:-desconhecida})."
      if confirm_action "Utiliza a versão 18.04?" "n"; then
        instalar_vpn_1804
      else
        instalar_vpn_2204
      fi
      ;;
  esac
}
