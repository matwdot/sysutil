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

# Configura DocGate
configurar_docgate() {
  # Pedir confirmação
  if confirm_action "Deseja configurar o DocGate v5?"; then
    # Verificar se o arquivo tar.gz existe
    if [[ ! -f "dep/docgateV5.tar.gz" ]]; then
      error_msg "Arquivo dep/docgateV5.tar.gz não encontrado. Verifique o caminho e tente novamente."
    fi

    # Fazer backup do diretório DocGate existente
    if [[ -d "/opt/docgate" ]]; then
      info_msg "Criando backup do DocGate atual..."
      sudo mv /opt/docgate /opt/docgate_backup || error_msg "Erro ao renomear o DocGate. Verifique as permissões."
    else
      bold_msg "Nenhuma instalação anterior do DocGate encontrada. Continuando com a nova instalação..."
    fi

    # Extrair o novo DocGate
    info_msg "${BLUE}Extraindo o DocGate v5...${NC}"
    sudo tar -xf dep/docgateV5.tar.gz -C /opt || error_msg "Erro ao extrair o DocGate. Verifique o arquivo tar."

    # Mensagem de sucesso e instruções
    success_msg "Instalação do DocGate v5 realizada com sucesso."

    # AQUI EM VEZ DE PEDIR PARA O USUARIO ABRIR O APP
    # ABRA VOCÊ MESMO PELO COMANDO
    echo -e "Por favor, acesse o menu ${BOLD}(Ctrl+Alt+Espaço)${NC}, vá em: ${BOLD}\nDispositivos - Ativar Compartilhamento MFE/SAT${NC}\ne selecione ${BOLD}'Ativado'.${NC}\nPressione Enter para continuar..."
    read -r -p ""
  else
    info_msg "Configuração do DocGate cancelado."
  fi
}
