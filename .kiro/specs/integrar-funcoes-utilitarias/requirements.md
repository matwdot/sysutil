# Requirements Document

## Introduction

Este documento define os requisitos para integrar as funções utilitárias existentes em `func/utils/utilities.sh` nos scripts de funções do projeto SysUtil. O objetivo é padronizar o tratamento de mensagens, validações, logs e operações de arquivo em todo o projeto, eliminando código duplicado e melhorando a manutenibilidade.

## Glossary

- **SysUtil**: Sistema de utilitários para o SysPDV PDV em Linux
- **Utilities Module**: Módulo de funções utilitárias localizado em `func/utils/utilities.sh`
- **Function Scripts**: Scripts individuais de funções localizados no diretório `func/`
- **Message Functions**: Funções de mensagens padronizadas (error_msg, success_msg, warning_msg, info_msg, print_msg, bold_msg)
- **Validation Functions**: Funções de validação (confirm_action, check_root, command_exists, package_installed, is_number, is_valid_ip)
- **File Operations**: Funções de operações com arquivos (backup_file, ensure_directory)
- **Log Functions**: Funções de registro de logs (log_message, log_error, log_info, log_warning)

## Requirements

### Requirement 1

**User Story:** Como desenvolvedor do SysUtil, eu quero que todos os scripts de funções utilizem as funções de mensagens padronizadas do Utilities Module, para que haja consistência visual e facilidade de manutenção em todo o projeto.

#### Acceptance Criteria

1. WHEN a Function Script precisa exibir uma mensagem de erro, THE Function Script SHALL utilizar a função error_msg do Utilities Module
2. WHEN a Function Script precisa exibir uma mensagem de sucesso, THE Function Script SHALL utilizar a função success_msg do Utilities Module
3. WHEN a Function Script precisa exibir uma mensagem de aviso, THE Function Script SHALL utilizar a função warning_msg do Utilities Module
4. WHEN a Function Script precisa exibir uma mensagem informativa, THE Function Script SHALL utilizar a função info_msg do Utilities Module
5. WHEN a Function Script precisa solicitar entrada do usuário, THE Function Script SHALL utilizar a função print_msg do Utilities Module

### Requirement 2

**User Story:** Como desenvolvedor do SysUtil, eu quero que todos os scripts de funções importem o Utilities Module corretamente, para que as funções utilitárias estejam disponíveis em todos os contextos de execução.

#### Acceptance Criteria

1. THE Function Scripts SHALL importar o Utilities Module no início do arquivo usando source relativo
2. WHEN o Utilities Module é importado, THE Function Script SHALL verificar se a importação foi bem-sucedida
3. THE Function Scripts SHALL garantir que as cores estejam disponíveis através do Utilities Module
4. WHEN um Function Script é executado diretamente, THE script SHALL ter acesso a todas as funções do Utilities Module
5. WHEN um Function Script é importado por outro script, THE Utilities Module SHALL ser carregado apenas uma vez

### Requirement 3

**User Story:** Como desenvolvedor do SysUtil, eu quero substituir as chamadas diretas de echo com formatação de cores por funções de mensagens padronizadas, para que o código seja mais legível e manutenível.

#### Acceptance Criteria

1. WHEN um Function Script contém echo com formatação ${RED}, THE script SHALL substituir por error_msg
2. WHEN um Function Script contém echo com formatação ${GREEN}, THE script SHALL substituir por success_msg
3. WHEN um Function Script contém echo com formatação ${YELLOW}, THE script SHALL substituir por warning_msg
4. WHEN um Function Script contém echo com formatação ${BLUE}, THE script SHALL substituir por info_msg
5. WHEN um Function Script contém echo com formatação ${BOLD}, THE script SHALL substituir por bold_msg

### Requirement 4

**User Story:** Como desenvolvedor do SysUtil, eu quero que as operações de backup de arquivos utilizem a função backup_file do Utilities Module, para que haja padronização e tratamento de erros consistente.

#### Acceptance Criteria

1. WHEN um Function Script precisa criar backup de um arquivo, THE script SHALL utilizar a função backup_file do Utilities Module
2. WHEN a função backup_file é chamada, THE Function Script SHALL verificar o código de retorno para tratamento de erros
3. THE backup_file function SHALL criar backups com timestamp no formato YYYYMMDD_HHMMSS
4. WHEN um backup é criado com sucesso, THE backup_file function SHALL retornar o caminho do arquivo de backup
5. IF o arquivo original não existe, THEN THE backup_file function SHALL exibir mensagem de erro e retornar código de erro

### Requirement 5

**User Story:** Como desenvolvedor do SysUtil, eu quero que as validações de entrada utilizem as funções de validação do Utilities Module, para que haja consistência no tratamento de dados de entrada.

#### Acceptance Criteria

1. WHEN um Function Script precisa validar um endereço IP, THE script SHALL utilizar a função is_valid_ip do Utilities Module
2. WHEN um Function Script precisa verificar se um comando existe, THE script SHALL utilizar a função command_exists do Utilities Module
3. WHEN um Function Script precisa verificar se um pacote está instalado, THE script SHALL utilizar a função package_installed do Utilities Module
4. WHEN um Function Script precisa validar se uma entrada é numérica, THE script SHALL utilizar a função is_number do Utilities Module
5. WHEN um Function Script precisa verificar permissões de root, THE script SHALL utilizar a função check_root do Utilities Module

### Requirement 6

**User Story:** Como desenvolvedor do SysUtil, eu quero que operações críticas registrem logs utilizando as funções de log do Utilities Module, para que seja possível rastrear problemas e auditar operações.

#### Acceptance Criteria

1. WHEN um Function Script executa uma operação crítica com sucesso, THE script SHALL registrar um log informativo usando log_info
2. WHEN um Function Script encontra um erro, THE script SHALL registrar um log de erro usando log_error
3. WHEN um Function Script identifica uma situação de atenção, THE script SHALL registrar um log de aviso usando log_warning
4. THE log functions SHALL incluir timestamp no formato YYYY-MM-DD HH:MM:SS
5. THE log functions SHALL gravar os logs no arquivo /var/log/sysutil.log por padrão

### Requirement 7

**User Story:** Como desenvolvedor do SysUtil, eu quero que a criação de diretórios utilize a função ensure_directory do Utilities Module, para que haja tratamento consistente de criação de diretórios.

#### Acceptance Criteria

1. WHEN um Function Script precisa garantir que um diretório existe, THE script SHALL utilizar a função ensure_directory do Utilities Module
2. WHEN o diretório não existe, THE ensure_directory function SHALL criar o diretório com mkdir -p
3. WHEN o diretório é criado com sucesso, THE ensure_directory function SHALL exibir mensagem de sucesso
4. IF a criação do diretório falha, THEN THE ensure_directory function SHALL exibir mensagem de erro e retornar código de erro
5. WHEN o diretório já existe, THE ensure_directory function SHALL retornar sucesso sem exibir mensagens

### Requirement 8

**User Story:** Como desenvolvedor do SysUtil, eu quero que todos os scripts de funções mantenham compatibilidade com a estrutura atual do projeto, para que a integração não quebre funcionalidades existentes.

#### Acceptance Criteria

1. THE Function Scripts SHALL manter todas as funcionalidades existentes após a integração
2. THE Function Scripts SHALL manter compatibilidade com os scripts principais (sysutil, sysutil_new, sysutil.sh)
3. WHEN um Function Script é modificado, THE script SHALL ser testado para garantir que não há regressões
4. THE Function Scripts SHALL manter os mesmos nomes de funções públicas
5. THE Function Scripts SHALL manter a mesma interface de entrada e saída das funções
