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
# *************************************************************

# Baixa a build do SysPDV
baixar_build() {
  read -r -p "Informe a BUILD para download: " build
  URL="https://objectstorage.us-ashburn-1.oraclecloud.com/n/casamagalhaes/b/syspdv/o/b$build/InstaladorSysPDV19_0_0_$build.exe"

  if ! [[ $URL =~ ^https://.* ]]; then
    echo -e "${RED}URL inválida.${NC}"
    return 1
  fi

  read -r -p "Informe o diretório (padrão: /home/pdv/Downloads): " DESTINO
  DESTINO=${DESTINO:-/home/pdv/Downloads}
  ARQUIVO="$DESTINO/InstaladorSysPDV19_0_0_$build.exe"

  echo -e "${YELLOW}Baixando a BUILD${NC} ${RED}$build${NC}${YELLOW} para ${NC}${GREEN}$DESTINO${NC}${YELLOW}. Aguarde!!${NC}"

  if curl --progress-bar --location --fail --output "$ARQUIVO" "$URL"; then
    success_msg "A BUILD $build foi baixada com sucesso."
    warning_msg "Iniciando instalação..."

    chmod +x "$ARQUIVO"
    wine "$ARQUIVO"
  else
    error_msg "Falha no download da BUILD $build."
    sleep 2
  fi
}
