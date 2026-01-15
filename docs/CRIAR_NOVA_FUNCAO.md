# Como Criar uma Nova Função e Adicionar ao Menu

Este guia explica o passo a passo para criar uma nova função no SysUtil e integrá-la ao sistema de menus.

## Estrutura do Projeto

```
sysutil/
├── sysutil.sh          # Script principal com menus
├── functions.sh        # Importações de todas as funções
├── colors.sh           # Definições de cores
├── func/               # Pasta com as funções
│   ├── utils/          # Utilitários (menu_system, utilities)
│   └── *.sh            # Funções individuais
└── docs/               # Documentação
```

## Passo 1: Criar o Arquivo da Função

Crie um novo arquivo em `func/` seguindo o padrão de nomenclatura:

```bash
# Exemplo: func/minha_funcao.sh
```

### Template Básico

```bash
#!/bin/bash
#
# minha_funcao.sh - Descrição breve da função
#
# Versão: 7.0
# Autor: Seu Nome
# Licença: MIT
#
# *************************************************************

# IMPORTAÇÕES (se necessário)
# shellcheck disable=SC1091

minha_funcao() {
    # Solicita confirmação do usuário
    if confirm_action "Deseja executar esta ação?"; then
        
        # Sua lógica aqui
        info_msg "Executando ação..."
        
        # Exemplo de verificação
        if [ -d "/caminho/pasta" ]; then
            # Executa comando
            if sudo comando; then
                success_msg "Ação executada com sucesso."
            else
                error_msg "Erro ao executar ação."
                return 1
            fi
        else
            error_msg "Recurso não encontrado."
            return 1
        fi
    else
        error_msg "Ação cancelada pelo usuário."
    fi
}
```

## Passo 2: Importar a Função

Adicione o import no arquivo `functions.sh`:

```bash
# No arquivo functions.sh, adicione:
. func/minha_funcao.sh
```

## Passo 3: Adicionar ao Menu

### Opção A: Adicionar a um Submenu Existente

Edite a função do menu correspondente em `sysutil.sh`:

```bash
# Exemplo: Adicionar ao menu_mfe()
menu_mfe() {
  local mfe_options=(
    "Remover Driver MFe"
    "Remover DocGate"
    "Minha Nova Opção"    # <- Adicione aqui
    "Voltar"
  )
  while true; do
    navigate_menu "${mfe_options[@]}"
    case $? in
    0)
      clear
      remover_drive_mfe
      echo -e "${GREEN}MFe removido com sucesso!${NC}"
      ;;
    1)
      clear
      remover_docgate
      echo -e "${GREEN}DocGate removido com sucesso!${NC}"
      ;;
    2)                    # <- Adicione o case
      clear
      minha_funcao
      echo -e "${GREEN}Operação concluída!${NC}"
      ;;
    3) return ;;          # <- Atualize o índice do Voltar
    esac
  done
}
```

### Opção B: Criar um Novo Submenu

```bash
# Adicione no sysutil.sh
menu_novo() {
  local novo_options=(
    "Opção 1"
    "Opção 2"
    "Voltar"
  )
  while true; do
    navigate_menu "${novo_options[@]}"
    case $? in
    0)
      clear
      funcao_opcao1
      echo -e "${GREEN}Operação concluída!${NC}"
      ;;
    1)
      clear
      funcao_opcao2
      echo -e "${GREEN}Operação concluída!${NC}"
      ;;
    2) return ;;
    esac
  done
}
```

E adicione ao menu principal:

```bash
options=(
  "SysPDV PDV"
  "VPN Comnect"
  "MFe/DocGate"
  "Novo Menu"             # <- Adicione aqui
  "Configurar Periféricos"
  # ...
  "Sair"
)

# No case do menu principal, adicione:
case $? in
  # ...
  3) menu_novo ;;         # <- Adicione o case
  # Atualize os índices seguintes
esac
```

## Funções Utilitárias Disponíveis

### Mensagens (de `func/utils/utilities.sh`)

| Função | Descrição | Exemplo |
|--------|-----------|---------|
| `error_msg "texto"` | Mensagem de erro (vermelho) | `error_msg "Falha na operação"` |
| `success_msg "texto"` | Mensagem de sucesso (verde) | `success_msg "Concluído!"` |
| `warning_msg "texto"` | Mensagem de atenção (amarelo) | `warning_msg "Atenção!"` |
| `info_msg "texto"` | Mensagem informativa (azul) | `info_msg "Processando..."` |

### Validações

| Função | Descrição |
|--------|-----------|
| `confirm_action "pergunta"` | Solicita confirmação S/N |
| `check_root` | Verifica se é root |
| `command_exists "cmd"` | Verifica se comando existe |
| `package_installed "pkg"` | Verifica se pacote está instalado |

## Boas Práticas

1. **Sempre use `confirm_action`** antes de operações destrutivas
2. **Trate erros** com `return 1` e mensagens claras
3. **Use `info_msg`** para informar o progresso
4. **Verifique pré-requisitos** antes de executar (diretórios, comandos, etc.)
5. **Pare serviços** antes de remover arquivos relacionados
6. **Mantenha o padrão** de nomenclatura e comentários

## Exemplo Completo

Veja o arquivo `func/remover_docgate.sh` como referência de implementação.
