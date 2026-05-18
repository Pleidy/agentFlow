$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$errors = New-Object System.Collections.Generic.List[string]

function Assert-Exists {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $Path))) {
        $errors.Add("Missing required file: $Path")
    }
}

function Assert-NotExists {
    param([string]$Path, [string]$Message)
    if (Test-Path -LiteralPath (Join-Path $repoRoot $Path)) {
        $errors.Add($Message)
    }
}

function Assert-NotMatch {
    param([string]$Path, [string]$Pattern, [string]$Message)
    $fullPath = Join-Path $repoRoot $Path
    if (-not (Test-Path -LiteralPath $fullPath)) {
        $errors.Add("Missing file for content check: $Path")
        return
    }

    $content = Get-Content -LiteralPath $fullPath -Raw -Encoding UTF8
    if ($content -match $Pattern) {
        $errors.Add("${Path}: $Message")
    }
}

function Assert-Match {
    param([string]$Path, [string]$Pattern, [string]$Message)
    $fullPath = Join-Path $repoRoot $Path
    if (-not (Test-Path -LiteralPath $fullPath)) {
        $errors.Add("Missing file for content check: $Path")
        return
    }

    $content = Get-Content -LiteralPath $fullPath -Raw -Encoding UTF8
    if ($content -notmatch $Pattern) {
        $errors.Add("${Path}: $Message")
    }
}

$requiredFiles = @(
    "README.md",
    "docs/agentflow-install.md",
    "docs/agentflow-usage-guide.md",
    ".claude/agentflows/CLAUDE.md",
    ".claude/agentflows/settings.json",
    ".claude/agentflows/tools/open-dashboard.sh",
    ".codex/agentflows/AGENTS.md",
    ".codex/agentflows/config.yaml",
    ".codex/agentflows/hooks.json",
    ".codex/agentflows/tools/open-dashboard.sh"
)

foreach ($file in $requiredFiles) {
    Assert-Exists -Path $file
}

Assert-NotExists -Path ".claude/settings.local.json" -Message "Local Claude settings should not be committed."

Assert-NotMatch -Path ".codex/agentflows/config.yaml" -Pattern 'npm run lint|npx tsc --noEmit|npm test' -Message "Default Codex commands should stay unconfigured; avoid hard-coded Node commands."
Assert-NotMatch -Path ".codex/agentflows/hooks.json" -Pattern 'npm run lint|npx tsc --noEmit|npm test' -Message "Default Codex hooks should not hard-code Node commands."
Assert-NotMatch -Path "docs/agentflow-usage-guide.md" -Pattern 'cat state\.md' -Message "Use actual .claude/.codex state paths instead of root state.md."
Assert-NotMatch -Path "docs/agentflow-usage-guide.md" -Pattern '\./tools/open-dashboard\.sh' -Message "Use actual .claude/.codex dashboard launcher paths."
Assert-NotMatch -Path "docs/agentflow-usage-guide.md" -Pattern 'echo "_run/" >> \.gitignore' -Message "Use scoped .claude/.codex runtime ignore paths instead of root _run/."
Assert-Match -Path "README.md" -Pattern '/agentflow:mod' -Message "README command table should include /agentflow:mod."
Assert-Match -Path "README.md" -Pattern 'validate-agentflow-template\.ps1' -Message "README should mention the template validation script."

if ($errors.Count -gt 0) {
    Write-Host "agentFlow template validation failed:" -ForegroundColor Red
    foreach ($error in $errors) {
        Write-Host " - $error" -ForegroundColor Red
    }
    exit 1
}

Write-Host "agentFlow template validation passed." -ForegroundColor Green
