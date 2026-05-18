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
    "protocol/core-spec.md",
    "protocol/schemas/state.schema.json",
    "protocol/schemas/event.schema.json",
    "protocol/schemas/review-report.schema.json",
    "protocol/schemas/plan-bundle.schema.json",
    "protocol/schemas/mod-bundle.schema.json",
    "protocol/schemas/run-log.schema.json",
    "protocol/schemas/progress-log.schema.json",
    ".claude/agentflows/CLAUDE.md",
    ".claude/agentflows/state.json",
    ".claude/agentflows/settings.json",
    ".claude/agentflows/tools/open-dashboard.sh",
    ".codex/agentflows/AGENTS.md",
    ".codex/agentflows/state.json",
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
Assert-NotMatch -Path "README.md" -Pattern 'state\.md' -Message "README should reference machine-readable state.json instead of state.md."
Assert-NotMatch -Path "docs/agentflow-usage-guide.md" -Pattern '\./tools/open-dashboard\.sh' -Message "Use actual .claude/.codex dashboard launcher paths."
Assert-NotMatch -Path "docs/agentflow-usage-guide.md" -Pattern 'echo "_run/" >> \.gitignore' -Message "Use scoped .claude/.codex runtime ignore paths instead of root _run/."
Assert-NotMatch -Path "README.md" -Pattern '/agentflow:build specs/.*/implementation-plan\.md' -Message "README should use the canonical plan bundle path for /agentflow:build."
Assert-NotMatch -Path "docs/agentflow-usage-guide.md" -Pattern '/agentflow:build specs/.*/implementation-plan\.md' -Message "Usage guide should use the canonical plan bundle path for /agentflow:build."
Assert-Match -Path "README.md" -Pattern '/agentflow:mod' -Message "README command table should include /agentflow:mod."
Assert-Match -Path "README.md" -Pattern 'validate-agentflow-template\.ps1' -Message "README should mention the template validation script."
Assert-Match -Path "README.md" -Pattern 'protocol/core-spec\.md' -Message "README should mention the core spec."
Assert-Match -Path "README.md" -Pattern 'plan-bundle\.json' -Message "README should mention canonical schema-backed planner outputs."
Assert-Match -Path ".codex/agentflows/AGENTS.md" -Pattern 'core-spec\.md' -Message "Codex adapter should inherit from the core spec."
Assert-Match -Path ".claude/agentflows/CLAUDE.md" -Pattern 'core-spec\.md' -Message "Claude adapter should inherit from the core spec."
Assert-Match -Path ".codex/agentflows/AGENTS.md" -Pattern 'plan-bundle\.json' -Message "Codex adapter should mention canonical planner bundles."
Assert-Match -Path ".codex/agentflows/AGENTS.md" -Pattern 'mod-bundle\.json' -Message "Codex adapter should mention canonical mod bundles."
Assert-Match -Path ".codex/agentflows/AGENTS.md" -Pattern 'progress-log\.json' -Message "Codex adapter should mention canonical progress logs."
Assert-Match -Path ".codex/agentflows/AGENTS.md" -Pattern 'run-log\.json' -Message "Codex adapter should mention canonical run logs."
Assert-Match -Path ".claude/agentflows/CLAUDE.md" -Pattern 'plan-bundle\.json' -Message "Claude adapter should mention canonical planner bundles."
Assert-Match -Path ".claude/agentflows/CLAUDE.md" -Pattern 'mod-bundle\.json' -Message "Claude adapter should mention canonical mod bundles."
Assert-Match -Path ".claude/agentflows/CLAUDE.md" -Pattern 'progress-log\.json' -Message "Claude adapter should mention canonical progress logs."
Assert-Match -Path ".claude/agentflows/CLAUDE.md" -Pattern 'run-log\.json' -Message "Claude adapter should mention canonical run logs."
Assert-Match -Path ".codex/agentflows/agents/feature-planner.md" -Pattern 'plan-bundle\.schema\.json' -Message "Codex planner should reference the plan bundle schema."
Assert-Match -Path ".claude/agentflows/agents/feature-planner.md" -Pattern 'plan-bundle\.schema\.json' -Message "Claude planner should reference the plan bundle schema."
Assert-Match -Path ".codex/agentflows/agents/mod-builder.md" -Pattern 'mod-bundle\.schema\.json' -Message "Codex mod builder should reference the mod bundle schema."
Assert-Match -Path "protocol/core-spec.md" -Pattern 'plan-bundle\.schema\.json' -Message "Core spec should reference the plan bundle schema."
Assert-Match -Path "protocol/core-spec.md" -Pattern 'mod-bundle\.schema\.json' -Message "Core spec should reference the mod bundle schema."
Assert-Match -Path "protocol/core-spec.md" -Pattern 'run-log\.schema\.json' -Message "Core spec should reference the run log schema."
Assert-Match -Path "protocol/core-spec.md" -Pattern 'progress-log\.schema\.json' -Message "Core spec should reference the progress log schema."
Assert-Match -Path ".codex/agentflows/agents/quality-evaluator.md" -Pattern 'review-report\.schema\.json' -Message "Codex evaluator should reference the review report schema."
Assert-Match -Path ".claude/agentflows/agents/quality-evaluator.md" -Pattern 'review-report\.schema\.json' -Message "Claude evaluator should reference the review report schema."

if ($errors.Count -gt 0) {
    Write-Host "agentFlow template validation failed:" -ForegroundColor Red
    foreach ($validationError in $errors) {
        Write-Host " - $validationError" -ForegroundColor Red
    }
    exit 1
}

Write-Host "agentFlow template validation passed." -ForegroundColor Green
