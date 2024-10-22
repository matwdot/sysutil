#!/bin/bash
# ****************************************************************
# Script de Instalação/Atualização do SysPDV PDV para Linux
# Versão: 5.2
# Desenvolvido por: Matheus Wesley
# Contatos: https://matheuswesley.github.io/devlinks
#
# ****************************************************************
# Arquivo principal
#
# ****************************************************************

# Instala VPN
instalar_vpn() {
  echo -n -e "${YELLOW}Deseja instalar a VPN? (S/n): ${NC}"
  read confirm
  while [[ "$confirm" != "S" && "$confirm" != "N" && "$confirm" != "s" && "$confirm" != "n" ]]; do
    echo -n -e "${RED}Opção inválida. (S = Sim | N = Não): ${NC}"
    read confirm
  done

  if [[ "$confirm" =~ [sS] ]]; then
    echo "Iniciando a instalação da VPN..."
    if ! sudo ./dep/wnbinstall.sh -i; then
      echo -e "${RED}Erro ao instalar a VPN. Verifique permissões e tente novamente.${NC}"
      sleep 2
    else
      echo -n -e "${GREEN}Informe a chave da VPN: ${NC}"
      read key
      sudo wnbmonitor -k "$key" && sudo wnbmonitor -r
      sleep 2
      echo -e "${GREEN}VPN instalada com sucesso!${NC}"
    fi
  else
    echo -e "${RED}Configuração da VPN cancelada.${NC}"
    sleep 2
  fi
}