# agentFlow 安装指南

## 1. 复制模板

agentFlow 同时提供 Claude Code 和 Codex 两套适配层，但共享同一份核心协议和 schema。

```bash
# Claude Code 项目
cp -r /path/to/agentflow/protocol .
cp -r /path/to/agentflow/.claude/agentflows .claude/

# Codex 项目
cp -r /path/to/agentflow/protocol .
cp -r /path/to/agentflow/.codex/agentflows .codex/
```

## 2. 准备根引导文件

如果你使用 Claude Code，项目根目录需要一个轻量 `CLAUDE.md`，用于把 `/agentflow` 系列命令路由到：

- `protocol/core-spec.md`
- `.claude/agentflows/CLAUDE.md`

根引导文件不应该重复整份协议，它只需要声明入口和加载路径。

## 3. 配置平台文件

安装后请立刻按项目技术栈调整这些文件：

- `.claude/agentflows/settings.json`
- `.codex/agentflows/config.yaml`
- `.codex/agentflows/hooks.json`

原则：

- 未配置的门禁命令保持空字符串
- Evaluator 遇到未配置命令时应记录 `SKIP_NOT_CONFIGURED`
- 模板仓库不要提交本机专用配置

## 4. 配置 `.gitignore`

业务项目里建议忽略运行时目录：

```gitignore
.claude/agentflows/_run/
.codex/agentflows/_run/
```

模板仓库保留 `_run/.gitkeep` 仅用于保留目录结构；真实运行产物通常不应提交。

## 5. 了解权威产物

安装完成后，请先记住新的 schema-first 约定。

权威 JSON 产物：

- `.claude/agentflows/state.json` / `.codex/agentflows/state.json`
- `specs/{feature}/_agent/plan-bundle.json`
- `specs/{feature}/_agent/mod-bundle.json`
- `specs/{feature}/progress-log.json`
- `_run/{feature}/run-log.json`
- `specs/{feature}/_agent/review-reports/taskXX-review.json`

可选 Markdown 镜像：

- `architecture.md`
- `implementation-plan.md`
- `_agent/design-contract.md`
- `progress-log.md`
- `run-log.md`
- `taskXX-review.md`

如果两者同时存在，JSON 永远是恢复、评审、续跑的依据。

## 6. 验证安装

```bash
/agentflow help
```

然后运行模板校验脚本：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/validate-agentflow-template.ps1
```

## 7. 安装后的目录

```text
your-project/
  protocol/
    core-spec.md
    schemas/
  .claude/agentflows/
    CLAUDE.md
    state.json
    agents/
    skills/
    specs/
    _run/
  .codex/agentflows/
    AGENTS.md
    state.json
    config.yaml
    hooks.json
    agents/
    specs/
    _run/
```
