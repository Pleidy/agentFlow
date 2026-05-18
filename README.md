# agentFlow

> 每个需求都应该长成可运行的代码。

agentFlow 是一套多 Agent 开发编排协议。它把需求、规划、实现、评审、恢复这些阶段拆成清晰的文件契约，让 Claude Code 和 Codex 都能按同一套核心规则运行。

## 协议结构

agentFlow 现在采用三层结构：

- `protocol/core-spec.md`
  平台无关的核心协议，定义阶段、MUST/SHOULD 规则、评审契约、恢复规则。
- `protocol/schemas/*.json`
  机器可校验的 schema，覆盖状态、事件、计划产物、mod 产物、运行日志、进度日志、评审报告。
- `.claude/agentflows/CLAUDE.md` 与 `.codex/agentflows/AGENTS.md`
  平台适配层，只负责路径绑定、Agent 生命周期和平台配置差异。

## Canonical Artifacts

以下 JSON 文件是权威产物：

- `state.json`
- `events.jsonl`
- `_agent/plan-bundle.json`
- `_agent/mod-bundle.json`
- `progress-log.json`
- `run-log.json`
- `_agent/review-reports/taskXX-review.json`

以下 Markdown 文件只作为可选的人类阅读镜像：

- `architecture.md`
- `implementation-plan.md`
- `_agent/design-contract.md`
- `progress-log.md`
- `run-log.md`
- `_agent/review-reports/taskXX-review.md`
- `_run/{feature}/mod-review.md`

如果 JSON 和 Markdown 同时存在，以 JSON 为准。

## 快速开始

```bash
# 1. 编写或补全需求
/agentflow:spec "我的功能描述"

# 2. 仅规划
/agentflow:plan specs/xxx/feature-spec.md

# 3. 审查 canonical 计划产物后再实现
/agentflow:build specs/xxx/_agent/plan-bundle.json

# 4. 小范围修改
/agentflow:mod "修复导出日期格式"

# 5. 只做评审
/agentflow:review
```

路径说明：

- `specs/...` 是逻辑路径
- Claude Code 实际位于 `.claude/agentflows/specs/...`
- Codex 实际位于 `.codex/agentflows/specs/...`

## 目录概览

```text
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
docs/
  agentflow-install.md
  agentflow-usage-guide.md
```

## 安装

复制 `protocol/` 和目标平台目录即可，详见 [docs/agentflow-install.md](docs/agentflow-install.md)。

安装后请根据项目实际情况调整：

- `.codex/agentflows/config.yaml`
- `.codex/agentflows/hooks.json`
- `.claude/agentflows/settings.json`

模板默认不假设特定技术栈。未配置的 lint、typecheck、test 门禁应记为 `SKIP_NOT_CONFIGURED`，而不是默认运行 Node 命令。

## 文档

- [使用指南](docs/agentflow-usage-guide.md)
- [安装指南](docs/agentflow-install.md)
- [核心协议](protocol/core-spec.md)
- [Claude 适配层](.claude/agentflows/CLAUDE.md)
- [Codex 适配层](.codex/agentflows/AGENTS.md)

## 模板校验

```powershell
powershell -ExecutionPolicy Bypass -File scripts/validate-agentflow-template.ps1
```

这个脚本会验证关键模板文件是否存在，并检查适配层、prompt、schema 引用和关键文档是否仍在使用过时约定。

## License

MIT
