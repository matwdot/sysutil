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
# ***************************************************************

# Limitar Consumo Tec55
limitar_consumo() {
  # Pedir confirmação
  if confirm_action "Deseja configurar o limitador de consumo para o TEC55?"; then
    # Atualizar pacotes e instalar cpulimit
    info_msg "Atualizando pacotes e instalando cpulimit..."
    sleep 2
    if ! sudo apt update && sudo apt install -y cpulimit; then
      error_msg "Erro ao atualizar pacotes ou instalar o cpulimit."
    fi

    # Dar permissão de execução aos arquivos e copiá-los
    warning_msg "Aplicando permissões e copiando arquivos..."
    sleep 2
    if ! sudo chmod +x -R dep/tec55/* && sudo cp -R dep/tec55/* /usr/local/bin; then
      error_msg "Erro ao copiar os arquivos..."
    fi

    # Aplicar permissões ao diretório /opt/Gertec55
    warning_msg "Aplicando permissões ao diretório /opt/Gertec55..."
    if sudo chmod 777 -R /opt/Gertec55; then
      success_msg "Permissões aplicadas com sucesso."
      sleep 2
    else
      error_msg "Erro ao aplicar permissões ao diretório /opt/Gertec55."
    fi

    # Mensagem de sucesso
    success_msg "Configuração do limitador de consumo para o TEC55 realizada com sucesso."
  else
    info_msg "Configuração cancelada."
  fi
}
