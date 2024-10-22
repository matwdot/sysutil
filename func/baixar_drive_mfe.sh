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

# Baixa e instala o Driver MFe
baixar_drive_mfe() {

  echo -n -e "${YELLOW}Deseja instalar o Drive MFe? (S/n): ${NC}"
  read confirm
  while [[ "$confirm" != "S" && "$confirm" != "N" && "$confirm" != "s" && "$confirm" != "n" ]]; do
    echo -n -e "${RED}Opção inválida. (S = Sim | N = Não): ${NC}"
    read confirm
  done

  if [[ "$confirm" =~ [sS] ]]; then
    read -p "Informe a versão do driver (padrão: 02.05.18): " VERSAO
    VERSAO=${VERSAO:-02.05.18}
    URL="http://servicos.sefaz.ce.gov.br/internet/download/projetomfe/instalador-ce-sefaz-driver-linux-x86-$VERSAO.tar.gz"
    read -p "Informe o diretório (padrão: /home/pdv/Downloads): " DESTINO
    DESTINO=${DESTINO:-/home/pdv/Downloads}
    ARQUIVO="$DESTINO/instalador-ce-sefaz-driver-linux-x86-$VERSAO.tar.gz"
    DIR_EXTRACAO="$DESTINO"

    echo -e "${YELLOW}Baixando o Driver MFe${NC} ${RED}v$VERSAO${NC}${YELLOW} para ${NC}${GREEN}$DESTINO${NC}${YELLOW}. Aguarde!${NC}"

    curl --progress-bar --location --fail --output "$ARQUIVO" "$URL"
    if [ $? -eq 0 ]; then
      echo -e "\n${GREEN}O Driver MFe foi baixado com sucesso.${NC}"
      echo -e "${YELLOW}Descompactando...${NC}"
      tar -xf "$ARQUIVO" -C "$DIR_EXTRACAO"
      echo -e "${YELLOW}Iniciando instalação...${NC}"
      if [ $? -eq 0 ]; then
        if cd "$DIR_EXTRACAO/instalador-ce-sefaz-driver-linux-x86-$VERSAO"; then
          if [ -x "./instala-driver.sh" ]; then
            sudo ./instala-driver.sh 
            if [ $? -eq 0 ]; then
              echo -e "${GREEN}Instalação concluída com sucesso.${NC}"
              sleep 2
            else
              echo -e "${RED}Erro durante a instalação do driver.${NC}"
              sleep 2
            fi
          else
            echo -e "${RED}Erro: o script de instalação não foi encontrado ou não é executável.${NC}"
            sleep 2
          fi
        else
          echo -e "${RED}Erro: falha ao acessar o diretório de extração.${NC}"
          sleep 2
        fi
      else
        echo -e "${RED}Erro ao extrair o arquivo.${NC}"
        sleep 2
      fi

      rm "$ARQUIVO"  # Remover arquivo baixado
    else
      echo -e "${RED}Falha no download.${NC}"
  fi
  else
    echo "Instalação do Drive MFe cancelada"
  fi
}