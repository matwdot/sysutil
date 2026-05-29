# Changelog

## [8.0.0](https://github.com/matwdot/sysutil/releases/tag/v8.0.0) (2026-05-29)

### ♻️ Refatorações (Breaking)

* **Entrypoint único**: `sysutil.sh` removido. O único entrypoint é `sysutil` (sem extensão).
* **Menu duplicado eliminado**: Funções inline `get_input`, `show_menu`, `navigate_menu` removidas de `sysutil.sh`.
  Sistema de menus vive exclusivamente em `func/utils/menu_system.sh`.
* **`create_alias.sh` movido** para `scripts/create_alias.sh` — não é mais sourced a cada execução,
  executado apenas uma vez pelo instalador.
* **Versão centralizada**: Nova `config/version.sh` com `$VERSION="8.0.0"`. Todos os scripts
  que exibem versão sourceiam este arquivo.

### 🗑️ Remoções

* **`func/db.sh`** — placeholder vazio removido junto com a opção "Manutenção via banco" do menu.
* **`func/requisitos.sh`** — arquivo órfão, comentado em `functions.sh` há releases.
* **`dep/docgateV5.tar.gz`** — movido para GitHub Release asset (`v8.0-deps`).
  Download sob demanda via `download_manager.sh` com verificação SHA256.
* **`dep/wnbtlscli_2_5_1/*.deb`, `*.rpm`, `*.tar`** — movidos para GitHub Release asset (`v8.0-deps`).
  Disponíveis para download via `download_manager.sh vpn <tipo>`.
* **`sleep` arbitrários** removidos de todos os módulos funcionais.

### 🔒 Segurança

* **`chmod 777 -R` substituído por `chmod 755 -R`** em `configurar_biometria.sh` e `limitar_consumo.sh`.
* **Chave da VPN isolada**: salva em `~/.sysutil/chave.txt` com permissão 600
  (`remover_vpn.sh`), em vez do diretório de trabalho atual.
* **Validação de IP** com `is_valid_ip()` adicionada em `transferencia.sh`.
* **Build numérica validada** com `is_number()` em `baixar_build.sh`.
* **Sanitização de caminho** com `realpath -m` no diretório destino de `baixar_build.sh`.

### ✨ Melhorias

* **Mensagens padronizadas**: Todos os 10 módulos em `func/*.sh` agora usam
  `error_msg`, `success_msg`, `info_msg`, `warning_msg` de `utilities.sh`.
* **Import guard consistente**: Todos os módulos usam o padrão
  `if [[ -z "$(type -t error_msg)" ]]` para carregar `utilities.sh` com fallback.
* **Tratamento de erros**: Verificação de retorno em operações críticas
  (`sudo`, `cp`, `curl`, `scp`) com mensagens específicas e `return 1`.
* **`package_installed`**: Usado em `limitar_consumo.sh` para evitar
  `apt update` desnecessário quando `cpulimit` já está presente.
* **Variáveis protegidas com quotes** em `fazer_backup_fdb.sh`.

### 🔧 Infraestrutura

* **Release-please manifest** atualizado para `8.0.0`.
* **`.gitignore`** atualizado: dependências binárias VPN/DocGate agora ignoradas.
* **Tamanho do repositório**: ~187MB → ~97MB (redução de 48%).

---

## [7.0.1](https://github.com/matwdot/sysutil/releases/tag/v7.0.1) (2026-01-15)

### ✨ Novas Funcionalidades

* **Download Manager**: Sistema completo para gerenciamento de dependências sob demanda com verificação de integridade SHA256
* **Remoção DocGate**: Nova função `remover_docgate()` para remoção segura do DocGate com encerramento automático de processos
* **Sistema de Logs**: Funções `log_info()`, `log_error()` e `log_warning()` para registro de operações em `/var/log/sysutil.log`
* **Validação de IP**: Função `is_valid_ip()` para validação de endereços IP
* **Backup de Arquivos**: Função `backup_file()` com timestamp automático
* **Verificação de Pacotes**: Função `package_installed()` para verificar pacotes dpkg/rpm

### ♻️ Refatorações

* **Estrutura do Projeto**: Reorganização completa com documentação centralizada em `docs/`
* **Sistema de Menus**: Modularização do sistema de menus em `func/utils/menu_system.sh`
* **Utilities**: Centralização de funções utilitárias em `func/utils/utilities.sh`
* **Importações**: Padrão de importação consistente com fallback para cores padrão
* **Instalador**: Novo instalador v7.0 com barra de progresso visual e verificação de dependências

### 🐛 Correções

* **instalar_vpn.sh**: Correção na lógica de verificação de chave VPN existente
* **remover_vpn.sh**: Melhoria no tratamento de erros durante remoção
* **Mensagens**: Padronização de mensagens usando `error_msg()`, `success_msg()`, `info_msg()` e `warning_msg()`

### 📚 Documentação

* **ANALISE_E_MELHORIAS.md**: Análise detalhada do projeto com recomendações
* **REORGANIZACAO_PROJETO.md**: Documentação da reorganização estrutural
* **DOCUMENTACAO.md**: Documentação técnica principal
* **RELEASE_GUIDE.md**: Guia para releases automáticas
* **IMPORT_PATTERN.md**: Padrão de importação do utilities.sh
* **CRIAR_NOVA_FUNCAO.md**: Guia para criação de novas funções

### 🔧 Build

* **Release Please**: Configuração de releases automáticas com changelog em português
* **GitHub Actions**: Workflow para CI/CD automatizado
* **.gitignore**: Regras para ignorar cache de downloads e arquivos temporários

### 🔨 Manutenção

* **Configuração de Downloads**: Arquivo `config/downloads.conf` com URLs e hashes de dependências
* **Versão**: Atualização para versão 7.0.1 em todos os arquivos do projeto

---

## [7.0.0](https://github.com/matwdot/sysutil/releases/tag/v7.0.0) (2026-01-08)

### ✨ Novas Funcionalidades

* Sistema de menus interativo com suporte a fzf
* Módulo de utilities centralizado
* Suporte a múltiplas arquiteturas para VPN (amd64, arm64, armhf, i386)

### ♻️ Refatorações

* Refatoração completa do sistema de menus
* Padronização de mensagens de feedback

---

## 1.0.0 (2026-01-08)

### Features

* configurar releases automáticas com Release Please ([42e7cd3](https://github.com/matwdot/sysutil/commit/42e7cd3bf5501c3d01ee3c715bf07dee058ec03b))
* continuando a reestruturação do projeto ([2c7822a](https://github.com/matwdot/sysutil/commit/2c7822abd6435196001722c1317fa95be32d6859))
* Criação Script para o instalação e execução rapida do sysutil. ([1a882f3](https://github.com/matwdot/sysutil/commit/1a882f359839dbbcf1870b12fce6f2741295d23a))
* Manuenção no Codigo ([b8b3ea3](https://github.com/matwdot/sysutil/commit/b8b3ea38d81df0cee5b0bc0427e0feca96657fe2))

### Bug Fixes

* Corrigindo erro de logica na função instala_vpn.sh ([92cbdcb](https://github.com/matwdot/sysutil/commit/92cbdcb61909a3743e8ffeb4b0c664616bface34))
* logica função instala_vpn ([1323812](https://github.com/matwdot/sysutil/commit/1323812a8c8f6a3c8cca4c27aa76c38f1175458e))
