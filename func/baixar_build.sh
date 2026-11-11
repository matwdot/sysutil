#!/bin/bash
#
# sysutil.sh - Script de utilitários para o SysPDV PDV em Linux
#
# Versão: 8.0
# Autor: Matheus Wesley
# GitHub: https://matheuswesley.github.io/devlinks
# GitHub Projeto: https://matwdot.github.
# Licença: MIT
#
# Este script contém um conjunto de funções para instalação, atualização e
# manutenção do sistema SysPDV PDV em ambientes Linux.
#
# *************************************************************

# Import utilities if not loaded
if [[ -z "$(type -t error_msg)" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck source=utils/utilities.sh
  source "${SCRIPT_DIR}/utils/utilities.sh" || {
    echo "ERRO: Não foi possível carregar utilities.sh"
    exit 1
  }
fi

# Baixa a build do SysPDV
baixar_build() {
  read -r -p "Informe a BUILD para download: " build

  if ! is_number "$build"; then
    error_msg "Build inválida: deve ser um número."
    return 1
  fi

  URL="https://objectstorage.us-ashburn-1.oraclecloud.com/n/casamagalhaes/b/syspdv/o/b$build/InstaladorSysPDV19_0_0_$build.exe"

  if ! [[ $URL =~ ^https://.* ]]; then
    error_msg "URL inválida."
    return 1
  fi

  read -r -p "Informe o diretório (padrão: /home/pdv/Downloads): " DESTINO
  DESTINO=${DESTINO:-/home/pdv/Downloads}
  DESTINO=$(realpath -m "$DESTINO" 2>/dev/null || echo "$DESTINO")
  ARQUIVO="$DESTINO/InstaladorSysPDV19_0_0_$build.exe"

  warning_msg "Baixando a BUILD $build para $DESTINO. Aguarde!!"

  if curl --progress-bar --location --fail --output "$ARQUIVO" "$URL"; then
    success_msg "A BUILD $build foi baixada com sucesso."
    warning_msg "Iniciando instalação..."

    chmod +x "$ARQUIVO"
    wine "$ARQUIVO"
  else
    error_msg "Falha no download da BUILD $build."
  fi
}
