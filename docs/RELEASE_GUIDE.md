# Guia de Releases Automáticas

Este projeto usa **Release Please** para releases automáticas inteligentes.

## Release Please

**Arquivo:** `.github/workflows/release-please.yml`

### Como funciona:
- Usa conventional commits para determinar o tipo de release
- Cria PRs automáticos com changelog
- Release é criada quando o PR é merged
- Suporta versionamento semântico inteligente

### Conventional Commits:
```bash
feat: nova funcionalidade (minor bump)
fix: correção de bug (patch bump)
feat!: breaking change (major bump)
docs: atualização de documentação
refactor: refatoração de código
perf: melhoria de performance
test: adição de testes
ci: mudanças no CI/CD
chore: tarefas de manutenção
```

### Exemplos de commits:
```bash
git commit -m "feat: adicionar função de backup automático"
git commit -m "fix: corrigir erro na instalação do VPN"
git commit -m "docs: atualizar documentação de instalação"
git commit -m "feat!: remover suporte ao Ubuntu 18.04"
```

## Configuração

### Permissões necessárias:
O workflow precisa das seguintes permissões (já configuradas):
- `contents: write` - Para criar tags e releases
- `pull-requests: write` - Para criar PRs automáticos

### Arquivos de configuração:
- `.release-please-config.json`: Configuração do Release Please
- `.release-please-manifest.json`: Versão atual do projeto

### Assets incluídos nas releases:
- `sysutil` (executável principal)
- `sysutil.sh`
- `install.sh`
- `update.sh`
- `functions.sh`
- `colors.sh`

## Recomendação

O Release Please oferece controle preciso e profissional das releases:
- Gera changelogs mais organizados
- Permite revisão antes da release
- Segue padrões da indústria
- Facilita o versionamento semântico

## Ativação

Para ativar, faça um push para `master` ou `dev`:

```bash
git add .
git commit -m "feat: configurar releases automáticas"
git push origin master
```

A primeira execução criará a estrutura necessária e as próximas releases serão automáticas.

## Solução de Problemas

### Erro "GitHub Actions is not permitted to create or approve pull requests"
**SOLUÇÃO OBRIGATÓRIA**: Vá em Settings > Actions > General e:

1. **Workflow permissions**: Selecione "Read and write permissions"
2. **IMPORTANTE**: Marque "Allow GitHub Actions to create and approve pull requests"

Sem essa configuração, o Release Please não consegue criar os PRs automáticos.

### Erro "Resource not accessible by integration"
Se você receber este erro, verifique:

1. **Permissões do repositório**: Vá em Settings > Actions > General
2. **Workflow permissions**: Selecione "Read and write permissions"
3. **Allow GitHub Actions to create and approve pull requests**: Marque esta opção

### Primeira execução
Na primeira execução, o Release Please pode não criar uma release imediatamente. Ele precisa:
1. Analisar o histórico de commits
2. Criar a estrutura inicial
3. Nas próximas execuções, criará PRs e releases normalmente