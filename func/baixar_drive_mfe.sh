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

# Baixa e instala o Driver MFe
baixar_drive_mfe() {

  if confirm_action "Deseja instalar o Drive MFe?"; then
    read -r -p "Informe a versão do driver (padrão: 02.05.18): " VERSAO
    VERSAO=${VERSAO:-02.05.18}
    URL="http://servicos.sefaz.ce.gov.br/internet/download/projetomfe/instalador-ce-sefaz-driver-linux-x86-$VERSAO.tar.gz"
    read -r -p "Informe o diretório (padrão: /home/pdv/Downloads): " DESTINO
    DESTINO=${DESTINO:-/home/pdv/Downloads}

    ARQUIVO="$DESTINO/instalador-ce-sefaz-driver-linux-x86-$VERSAO.tar.gz"
    DIR_EXTRACAO="$DESTINO"
    DIR_INSTALACAO="$DIR_EXTRACAO/instalador-ce-sefaz-driver-linux-x86-$VERSAO"

    info_msg "Baixando o Driver MFe v$VERSAO para $DESTINO. Aguarde!!"

    # Função de Download
    baixar_arquivo() {
      local arquivo="$1"
      local url="$2"

      if curl --progress-bar --location --fail --output "$arquivo" "$url"; then
        success_msg "O Driver MFe foi baixado com sucesso."
        return 0
      else
        error_msg "Falha no download."
        return 1
      fi
    }

    # Função de Extração
    extrair_arquivo() {
      local arquivo="$1"
      local dir_extracao="$2"

      info_msg "Descompactando..."
      if tar -xf "$arquivo" -C "$dir_extracao"; then
        success_msg "Arquivo descompactado com sucesso."
        return 0
      else
        error_msg "Erro ao extrair o arquivo."
        return 1
      fi
    }

    # Função de Instalação
    instalar_driver() {
      local dir_instalacao="$1"
      local script_instalacao="./instala-driver.sh"

      if cd "$dir_instalacao"; then
        if [ -x "$script_instalacao" ]; then
          if sudo "$script_instalacao"; then
            success_msg "Instalação concluída com sucesso."
            return 0
          else
            error_msg "Erro durante a instalação do driver."
            return 1
          fi
        else
          error_msg "O script de instalação não foi encontrado ou não é executável."
          return 1
        fi
      else
        error_msg "Falha ao acessar o diretório de extração."
        return 1
      fi
    }

    # Executando as funções
    if baixar_arquivo "$ARQUIVO" "$URL"; then
      if extrair_arquivo "$ARQUIVO" "$DIR_EXTRACAO"; then
        info_msg "Iniciando instalação..."
        instalar_driver "$DIR_INSTALACAO"
      fi
      rm -f "$ARQUIVO"
    fi
  else
    echo "Instalação do Drive MFe cancelada"
  fi
}
