# Padrão de Import para utilities.sh

## Visão Geral

Este documento define o padrão de importação do módulo `utilities.sh` que deve ser usado em todos os scripts de funções do projeto SysUtil.

## Padrão de Import

Todos os scripts em `func/*.sh` devem seguir este padrão de importação no início do arquivo:

```bash
#!/bin/bash
# [Header comments...]

# Importar utilities se não estiver carregado
if [[ -z "$(type -t error_msg)" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck source=utils/utilities.sh
  source "${SCRIPT_DIR}/utils/utilities.sh" || {
    echo "ERRO: Não foi possível carregar utilities.sh"
    exit 1
  }
fi

# Resto do código...
```

## Explicação do Padrão

### 1. Verificação de Função Carregada
```bash
if [[ -z "$(type -t error_msg)" ]]; then
```
- Verifica se a função `error_msg` já está definida
- Evita recarregar `utilities.sh` múltiplas vezes
- Permite que o script seja executado diretamente ou importado por outro script

### 2. Determinação do Diretório do Script
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```
- Obtém o diretório absoluto onde o script atual está localizado
- Funciona independentemente de onde o script é executado
- Usa `${BASH_SOURCE[0]}` para obter o caminho do script atual

### 3. Source com Fallback
```bash
source "${SCRIPT_DIR}/utils/utilities.sh" || {
  echo "ERRO: Não foi possível carregar utilities.sh"
  exit 1
}
```
- Tenta carregar `utilities.sh` usando caminho relativo
- Se falhar, exibe mensagem de erro e sai com código 1
- Garante que o script não continue sem as funções utilitárias

### 4. Comentário ShellCheck
```bash
# shellcheck source=utils/utilities.sh
```
- Informa ao ShellCheck onde encontrar o arquivo source
- Melhora a análise estática do código
- Evita warnings desnecessários

## Benefícios do Padrão

1. **Evita Recarregamento**: Verifica se já foi carregado antes de importar
2. **Portabilidade**: Funciona independentemente do diretório de execução
3. **Fail-Safe**: Tem fallback caso o carregamento falhe
4. **Compatibilidade**: Funciona com execução direta ou via import
5. **Manutenibilidade**: Padrão consistente em todos os scripts

## Funções Disponíveis Após Import

### Mensagens
- `error_msg "mensagem"` - Mensagem de erro (vermelho com ✘)
- `success_msg "mensagem"` - Mensagem de sucesso (verde com ✔)
- `warning_msg "mensagem"` - Mensagem de aviso (amarelo com ➜)
- `info_msg "mensagem"` - Mensagem informativa (azul com ➜)
- `print_msg "mensagem"` - Mensagem de solicitação (azul com ➜, sem newline)
- `bold_msg "mensagem"` - Mensagem em negrito

### Validações
- `confirm_action "mensagem" [default]` - Confirmação S/N
- `check_root` - Verifica se é root
- `command_exists "comando"` - Verifica se comando existe
- `package_installed "pacote"` - Verifica se pacote está instalado
- `is_number "string"` - Valida se é número
- `is_valid_ip "ip"` - Valida endereço IP

### Operações de Arquivo
- `backup_file "arquivo" [dir_backup]` - Cria backup com timestamp
- `ensure_directory "diretorio"` - Garante que diretório existe

### Logs
- `log_message "nivel" "mensagem" [arquivo_log]` - Log genérico
- `log_error "mensagem" [arquivo_log]` - Log de erro
- `log_info "mensagem" [arquivo_log]` - Log informativo
- `log_warning "mensagem" [arquivo_log]` - Log de aviso

### Controle de Fluxo
- `pause [mensagem]` - Pausa com mensagem customizável
- `clear_screen` - Limpa a tela
- `exit_script [codigo]` - Saída limpa com código
- `die "mensagem" [codigo]` - Erro crítico e saída

## Exemplos de Uso

### Exemplo 1: Script Simples
```bash
#!/bin/bash

# Importar utilities
if [[ -z "$(type -t error_msg)" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "${SCRIPT_DIR}/utils/utilities.sh" || {
    echo "ERRO: Não foi possível carregar utilities.sh"
    exit 1
  }
fi

# Usar funções
info_msg "Iniciando operação..."

if ! command_exists "wget"; then
  error_msg "wget não está instalado"
  exit 1
fi

success_msg "Operação concluída!"
```

### Exemplo 2: Script com Validação
```bash
#!/bin/bash

# Importar utilities
if [[ -z "$(type -t error_msg)" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "${SCRIPT_DIR}/utils/utilities.sh" || {
    echo "ERRO: Não foi possível carregar utilities.sh"
    exit 1
  }
fi

# Verificar root
if ! check_root; then
  exit 1
fi

# Confirmar ação
if confirm_action "Deseja continuar?"; then
  info_msg "Continuando..."
  log_info "Usuário confirmou operação"
else
  warning_msg "Operação cancelada"
  exit 0
fi
```

### Exemplo 3: Script com Backup
```bash
#!/bin/bash

# Importar utilities
if [[ -z "$(type -t error_msg)" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "${SCRIPT_DIR}/utils/utilities.sh" || {
    echo "ERRO: Não foi possível carregar utilities.sh"
    exit 1
  }
fi

CONFIG_FILE="/etc/myapp/config.ini"

# Criar backup antes de modificar
if backup_path=$(backup_file "$CONFIG_FILE"); then
  log_info "Backup criado: $backup_path"
  
  # Modificar arquivo
  echo "nova_config=valor" >> "$CONFIG_FILE"
  success_msg "Configuração atualizada"
else
  error_msg "Falha ao criar backup"
  exit 1
fi
```

## Troubleshooting

### Erro: "utilities.sh: No such file or directory"
**Causa**: O caminho relativo está incorreto ou o script não está no diretório esperado.

**Solução**: Verifique se:
- O script está em `func/` e `utilities.sh` está em `func/utils/`
- O padrão de import usa `${SCRIPT_DIR}/utils/utilities.sh`

### Erro: "error_msg: command not found"
**Causa**: O `utilities.sh` não foi carregado corretamente.

**Solução**: 
- Verifique se o import está no início do script
- Execute o script com `bash -x` para debug
- Verifique permissões de leitura em `utilities.sh`

### Funções não funcionam quando script é importado
**Causa**: O `utilities.sh` pode não estar sendo carregado no contexto correto.

**Solução**:
- Use o padrão de verificação `if [[ -z "$(type -t error_msg)" ]]`
- Isso garante que funciona tanto em execução direta quanto importada

## Manutenção

### Adicionando Novas Funções
Ao adicionar novas funções em `utilities.sh`:
1. Documente a função com comentários
2. Adicione exemplo de uso neste documento
3. Teste em execução direta e via import
4. Atualize a lista de funções disponíveis

### Modificando o Padrão
Se precisar modificar o padrão de import:
1. Atualize este documento primeiro
2. Teste em um script de exemplo
3. Aplique em todos os scripts gradualmente
4. Documente a razão da mudança

## Referências

- Script utilities.sh: `func/utils/utilities.sh`
- Script de cores: `colors.sh`
- Design document: `.kiro/specs/integrar-funcoes-utilitarias/design.md`
- Requirements: `.kiro/specs/integrar-funcoes-utilitarias/requirements.md`
