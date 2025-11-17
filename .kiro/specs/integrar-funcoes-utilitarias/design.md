# Design Document

## Overview

Este documento descreve o design para integração das funções utilitárias existentes em `func/utils/utilities.sh` nos scripts de funções do projeto SysUtil. A solução visa padronizar o código, eliminar duplicações e melhorar a manutenibilidade através do uso consistente de funções utilitárias em todos os scripts.

O projeto SysUtil possui 12 scripts de funções principais que atualmente utilizam mensagens e validações de forma inconsistente. A integração das funções utilitárias padronizará:
- Mensagens de erro, sucesso, aviso e informação
- Validações de entrada (IP, números, comandos, pacotes)
- Operações com arquivos (backup, criação de diretórios)
- Sistema de logs para auditoria e troubleshooting

## Architecture

### Current Structure

```
sysutil/
├── func/
│   ├── baixar_build.sh
│   ├── baixar_drive_mfe.sh
│   ├── configurar_biometria.sh
│   ├── configurar_docgate.sh
│   ├── configurar_perifericos.sh
│   ├── db.sh
│   ├── fazer_backup_fdb.sh
│   ├── instalar_vpn.sh
│   ├── limitar_consumo.sh
│   ├── remover_drive_mfe.sh
│   ├── remover_vpn.sh
│   ├── transferencia.sh
│   └── utils/
│       ├── utilities.sh (✓ já existe)
│       ├── menu_system.sh
│       └── create_alias.sh
├── functions.sh (importa todos os scripts)
├── colors.sh
└── sysutil_new (script principal)
```

### Import Chain

```
sysutil_new
    ↓
functions.sh
    ↓
[func/*.sh scripts]
    ↓
func/utils/utilities.sh (já importa colors.sh)
```

### Design Principles

1. **Single Source of Truth**: Todas as funções utilitárias devem estar centralizadas em `utilities.sh`
2. **Backward Compatibility**: Manter compatibilidade com código existente
3. **Fail-Safe**: Funções devem ter fallback caso utilities.sh não seja carregado
4. **Minimal Changes**: Modificar apenas o necessário para integração
5. **No Breaking Changes**: Manter interfaces públicas das funções existentes

## Components and Interfaces

### 1. Utilities Module (func/utils/utilities.sh)

**Status**: Já implementado e funcional

**Funções Disponíveis**:

#### Message Functions
```bash
error_msg()    # Mensagem de erro (vermelho com ✘)
success_msg()  # Mensagem de sucesso (verde com ✔)
warning_msg()  # Mensagem de aviso (amarelo com ➜)
info_msg()     # Mensagem informativa (azul com ➜)
print_msg()    # Mensagem de solicitação (azul com ➜, sem newline)
bold_msg()     # Mensagem em negrito
```

#### Validation Functions
```bash
confirm_action()     # Confirmação S/N com default configurável
check_root()         # Verifica se é root
command_exists()     # Verifica se comando existe
package_installed()  # Verifica se pacote está instalado (dpkg/rpm)
is_number()          # Valida se string é número
is_valid_ip()        # Valida endereço IP
```

#### File Operations
```bash
backup_file()        # Cria backup com timestamp
ensure_directory()   # Garante que diretório existe
```

#### Log Functions
```bash
log_message()   # Log genérico com nível
log_error()     # Log de erro
log_info()      # Log informativo
log_warning()   # Log de aviso
```

#### Control Flow Functions
```bash
pause()         # Pausa com mensagem customizável
clear_screen()  # Limpa a tela
exit_script()   # Saída limpa com código
die()           # Erro crítico e saída
```

### 2. Function Scripts Modifications

Cada script em `func/*.sh` será modificado para:

1. **Importar utilities.sh** no início (se ainda não importa)
2. **Substituir echo formatado** por funções de mensagem
3. **Adicionar validações** onde apropriado
4. **Adicionar logs** para operações críticas
5. **Usar backup_file** onde há criação de backups
6. **Usar ensure_directory** onde há criação de diretórios

### 3. Import Pattern

Cada script de função deve seguir este padrão de importação:

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

**Rationale**: 
- Verifica se utilities já foi carregado (evita recarregar)
- Usa caminho relativo ao script atual
- Tem fallback caso falhe o carregamento
- Compatível com execução direta ou via import

## Data Models

### Message Format

```
error_msg:   "✘ <mensagem>" (vermelho)
success_msg: "✔ <mensagem>" (verde)
warning_msg: "➜ <mensagem>" (amarelo)
info_msg:    "➜ <mensagem>" (azul)
print_msg:   "➜ <mensagem> " (azul, sem newline)
bold_msg:    "<mensagem>" (negrito)
```

### Log Format

```
[YYYY-MM-DD HH:MM:SS] [LEVEL] message
```

Exemplo:
```
[2025-11-16 14:30:45] [INFO] VPN instalada com sucesso
[2025-11-16 14:31:12] [ERROR] Falha ao baixar build 12345
[2025-11-16 14:32:00] [WARNING] Arquivo de backup já existe
```

### Backup File Naming

```
<filename>.backup_<YYYYMMDD_HHMMSS>
```

Exemplo:
```
syspdv_cad.fdb.backup_20251116_143045
```

## Error Handling

### Strategy

1. **Graceful Degradation**: Se utilities.sh não carregar, usar fallback básico
2. **Error Propagation**: Funções retornam códigos de erro apropriados
3. **User Feedback**: Sempre informar o usuário sobre erros
4. **Logging**: Registrar erros críticos em log

### Error Codes

```bash
0   - Sucesso
1   - Erro genérico
2   - Arquivo não encontrado
3   - Permissão negada
4   - Operação cancelada pelo usuário
255 - Erro crítico (usado por die())
```

### Error Handling Pattern

```bash
if ! operation; then
  error_msg "Descrição do erro"
  log_error "Detalhes técnicos do erro"
  return 1
fi
```

## Testing Strategy

### Unit Testing Approach

Devido à natureza de scripts bash e dependências de sistema, o teste será manual e focado em:

1. **Smoke Tests**: Verificar que cada função carrega sem erros
2. **Integration Tests**: Executar cada função principal e verificar saída
3. **Regression Tests**: Garantir que funcionalidades existentes continuam funcionando

### Test Scenarios

#### 1. Import Tests
- Executar cada script diretamente
- Importar scripts via functions.sh
- Verificar que utilities.sh é carregado corretamente

#### 2. Message Function Tests
- Verificar que mensagens aparecem com formatação correta
- Testar cada tipo de mensagem (error, success, warning, info)

#### 3. Validation Function Tests
- Testar confirm_action com diferentes entradas
- Testar is_valid_ip com IPs válidos e inválidos
- Testar command_exists com comandos existentes e inexistentes

#### 4. File Operation Tests
- Testar backup_file com arquivo existente
- Testar backup_file com arquivo inexistente
- Testar ensure_directory com diretório novo e existente

#### 5. Log Function Tests
- Verificar que logs são gravados em /var/log/sysutil.log
- Verificar formato de timestamp
- Verificar níveis de log (INFO, ERROR, WARNING)

### Test Execution Plan

1. **Fase 1**: Modificar um script de teste (ex: db.sh - mais simples)
2. **Fase 2**: Testar execução direta e via menu
3. **Fase 3**: Se bem-sucedido, aplicar em scripts restantes
4. **Fase 4**: Teste de regressão completo do sistema

### Manual Test Checklist

Para cada script modificado:

```
[ ] Script carrega sem erros
[ ] Função principal executa corretamente
[ ] Mensagens aparecem formatadas
[ ] Validações funcionam corretamente
[ ] Logs são gravados (quando aplicável)
[ ] Operações de arquivo funcionam (quando aplicável)
[ ] Compatibilidade com menu principal mantida
[ ] Nenhuma regressão em funcionalidades existentes
```

## Implementation Priority

### High Priority (Core Functions)
1. `baixar_build.sh` - Função crítica de instalação
2. `instalar_vpn.sh` - Instalação de componente essencial
3. `fazer_backup_fdb.sh` - Operação de backup crítica

### Medium Priority (Configuration)
4. `configurar_perifericos.sh`
5. `configurar_biometria.sh`
6. `configurar_docgate.sh`
7. `baixar_drive_mfe.sh`

### Low Priority (Maintenance)
8. `remover_vpn.sh`
9. `remover_drive_mfe.sh`
10. `limitar_consumo.sh`
11. `transferencia.sh`
12. `db.sh`

## Migration Map

### Script-by-Script Changes

#### 1. baixar_build.sh
**Current Issues**:
- Usa echo direto com cores
- Não valida URL adequadamente
- Não faz log de operações

**Changes**:
- Substituir echo por funções de mensagem
- Adicionar validação de URL
- Adicionar logs de download e instalação
- Usar ensure_directory para diretório de destino

#### 2. instalar_vpn.sh
**Current Issues**:
- Usa echo direto com cores
- Não verifica se comando existe antes de usar
- Não faz log de instalação

**Changes**:
- Substituir echo por funções de mensagem
- Usar command_exists para verificar dpkg
- Usar package_installed para verificar se já instalado
- Adicionar logs de instalação

#### 3. fazer_backup_fdb.sh
**Current Issues**:
- Usa echo direto com cores
- Não usa função de backup padronizada
- Não faz log de backups

**Changes**:
- Substituir echo por funções de mensagem
- Usar backup_file para criar backups
- Adicionar logs de backup
- Usar ensure_directory para pasta de backup

#### 4. configurar_perifericos.sh
**Current Issues**:
- Usa echo direto com cores
- Não verifica se editor existe

**Changes**:
- Substituir echo por funções de mensagem
- Usar command_exists para verificar editor
- Adicionar logs de configuração

#### 5. configurar_biometria.sh
**Current Issues**:
- Usa echo direto com cores
- Não verifica se diretório existe antes de chmod

**Changes**:
- Substituir echo por funções de mensagem
- Usar ensure_directory para verificar diretório
- Adicionar logs de configuração

#### 6. configurar_docgate.sh
**Current Issues**:
- Usa echo direto com cores
- Não usa função de backup padronizada

**Changes**:
- Substituir echo por funções de mensagem
- Usar backup_file para backup do DocGate
- Adicionar logs de configuração

#### 7. baixar_drive_mfe.sh
**Current Issues**:
- Usa echo direto com cores
- Funções internas poderiam usar utilities

**Changes**:
- Substituir echo por funções de mensagem
- Refatorar funções internas para usar utilities
- Adicionar logs de download e instalação

#### 8. remover_vpn.sh
**Current Issues**:
- Usa echo direto com cores
- Não verifica se comando existe

**Changes**:
- Substituir echo por funções de mensagem
- Usar command_exists para verificar wnbmonitor
- Adicionar logs de remoção

#### 9. remover_drive_mfe.sh
**Current Issues**:
- Usa echo direto com cores
- Não verifica se diretório existe

**Changes**:
- Substituir echo por funções de mensagem
- Adicionar verificação de diretório
- Adicionar logs de remoção

#### 10. limitar_consumo.sh
**Current Issues**:
- Usa echo direto com cores
- Não verifica se pacote já está instalado

**Changes**:
- Substituir echo por funções de mensagem
- Usar package_installed para verificar cpulimit
- Adicionar logs de configuração

#### 11. transferencia.sh
**Current Issues**:
- Usa echo direto com cores
- Não valida IP
- Validações manuais de entrada vazia

**Changes**:
- Substituir echo por funções de mensagem
- Usar is_valid_ip para validar IP
- Adicionar logs de transferência

#### 12. db.sh
**Current Issues**:
- Função vazia (placeholder)

**Changes**:
- Implementar com funções de mensagem
- Adicionar estrutura básica com utilities

## Design Decisions

### Decision 1: Import Strategy
**Decision**: Usar verificação de função carregada antes de importar

**Rationale**: 
- Evita recarregar utilities.sh múltiplas vezes
- Permite execução direta ou via import
- Mantém compatibilidade com estrutura atual

**Alternatives Considered**:
- Import incondicional: Poderia causar overhead
- Variável de controle: Mais complexo de manter

### Decision 2: Backward Compatibility
**Decision**: Manter todas as interfaces públicas existentes

**Rationale**:
- Evita quebrar código que depende dos scripts
- Permite migração gradual
- Reduz risco de regressões

**Alternatives Considered**:
- Refatoração completa: Muito arriscado
- Criar novos scripts: Duplicação de código

### Decision 3: Logging Strategy
**Decision**: Adicionar logs apenas para operações críticas

**Rationale**:
- Não sobrecarregar o sistema de logs
- Focar em operações que precisam auditoria
- Manter performance

**Alternatives Considered**:
- Log de tudo: Muito verboso
- Sem logs: Dificulta troubleshooting

### Decision 4: Error Handling
**Decision**: Usar códigos de retorno padrão e mensagens consistentes

**Rationale**:
- Facilita debugging
- Permite automação futura
- Melhora experiência do usuário

**Alternatives Considered**:
- Apenas mensagens: Dificulta automação
- Apenas códigos: Dificulta uso manual

### Decision 5: Testing Approach
**Decision**: Testes manuais focados em smoke e regression

**Rationale**:
- Scripts bash são difíceis de testar automaticamente
- Dependem de sistema e permissões
- Testes manuais são mais práticos para este contexto

**Alternatives Considered**:
- Testes automatizados com bats: Overhead de setup
- Sem testes: Muito arriscado

## Security Considerations

1. **File Permissions**: Verificar permissões antes de operações críticas
2. **Input Validation**: Validar todas as entradas do usuário
3. **Path Traversal**: Usar caminhos absolutos ou relativos seguros
4. **Command Injection**: Evitar eval e expansão não controlada
5. **Log Sensitivity**: Não logar informações sensíveis (senhas, chaves)

## Performance Considerations

1. **Import Overhead**: Verificação de função carregada minimiza reimports
2. **Log I/O**: Logs são assíncronos e não bloqueiam operações
3. **Validation**: Validações são rápidas e não impactam UX
4. **Backup Operations**: Backups são síncronos mas informam progresso

## Future Enhancements

1. **Structured Logging**: Adicionar logs em formato JSON para parsing
2. **Log Rotation**: Implementar rotação automática de logs
3. **Remote Logging**: Enviar logs para servidor central
4. **Automated Tests**: Criar suite de testes automatizados com bats
5. **Configuration File**: Permitir configuração de comportamento via arquivo
6. **Internationalization**: Suporte a múltiplos idiomas nas mensagens
