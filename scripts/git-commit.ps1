# Função para commit no padrão Conventional Commits (Release Please)
# Adicione ao seu $PROFILE do PowerShell para usar globalmente

function git-commit {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("feat", "fix", "ci", "docs", "chore", "refactor", "perf", "style", "test", "build")]
        [string]$Type,
        
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [switch]$Push,
        [switch]$NoPush
    )
    
    # Tabela de tipos e seus efeitos
    $typeInfo = @{
        "feat"     = @{ emoji = "✨"; desc = "Nova funcionalidade"; release = "minor (7.0 → 7.1)" }
        "fix"      = @{ emoji = "🐛"; desc = "Correção de bug"; release = "patch (7.0.0 → 7.0.1)" }
        "ci"       = @{ emoji = "👷"; desc = "CI/CD"; release = "não gera release" }
        "docs"     = @{ emoji = "📚"; desc = "Documentação"; release = "não gera release" }
        "chore"    = @{ emoji = "🔨"; desc = "Manutenção"; release = "não gera release" }
        "refactor" = @{ emoji = "♻️"; desc = "Refatoração"; release = "não gera release" }
        "perf"     = @{ emoji = "⚡"; desc = "Performance"; release = "não gera release" }
        "style"    = @{ emoji = "💄"; desc = "Estilo/Formatação"; release = "não gera release" }
        "test"     = @{ emoji = "🧪"; desc = "Testes"; release = "não gera release" }
        "build"    = @{ emoji = "🔧"; desc = "Build"; release = "não gera release" }
    }
    
    $info = $typeInfo[$Type]
    $commitMsg = "${Type}: ${Message}"
    
    Write-Host ""
    Write-Host "$($info.emoji) Tipo: $Type - $($info.desc)" -ForegroundColor Cyan
    Write-Host "📦 Release Please: $($info.release)" -ForegroundColor Yellow
    Write-Host ""
    
    # git add -A
    Write-Host "➜ Adicionando alterações..." -ForegroundColor Blue
    git add -A
    
    # git commit
    Write-Host "➜ Criando commit: $commitMsg" -ForegroundColor Blue
    git commit -m $commitMsg
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "✘ Erro no commit" -ForegroundColor Red
        return
    }
    
    Write-Host "✔ Commit criado com sucesso!" -ForegroundColor Green
    
    # Push automático (a menos que -NoPush seja especificado)
    if (-not $NoPush) {
        $branch = git branch --show-current
        Write-Host "➜ Enviando para origin/$branch..." -ForegroundColor Blue
        git push origin $branch
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✔ Push realizado com sucesso!" -ForegroundColor Green
        } else {
            Write-Host "✘ Erro no push. Tente: git pull --rebase origin $branch" -ForegroundColor Red
        }
    }
}

# Alias curto
Set-Alias -Name gc -Value git-commit -Option AllScope -Force

Write-Host "Função git-commit carregada!" -ForegroundColor Green
Write-Host ""
Write-Host "Uso: git-commit -Type <tipo> -Message 'descrição'" -ForegroundColor Cyan
Write-Host "Exemplo: git-commit -Type feat -Message 'adicionar nova funcionalidade'" -ForegroundColor Gray
Write-Host ""
Write-Host "Tipos disponíveis:" -ForegroundColor Yellow
Write-Host "  feat, fix      → Geram release" -ForegroundColor White
Write-Host "  ci, docs, chore, refactor, perf, style, test, build → Não geram release" -ForegroundColor Gray
Write-Host ""
Write-Host "Opções:" -ForegroundColor Yellow
Write-Host "  -NoPush        → Não faz push automático" -ForegroundColor Gray
