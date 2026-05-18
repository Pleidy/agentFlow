# agentFlow

> 每个需求都能长成可运行的代码。
> Every requirement can grow into working code.

agentFlow 是一个**多 Agent 开发编排协议**。它定义了一套流水线，让多个 AI Agent（规划师、建造师、评估师）按照严格的规则协作，将一份需求规格文档转化为可交付的代码变更。

---

## 协议结构

agentFlow 现在分成三层：

- `protocol/core-spec.md`：平台无关的核心规范，定义 MUST/SHOULD 规则、阶段、失败分类、gate 语义、repair loop 和模板边界
- `protocol/schemas/*.json`：机器可验证的状态、事件、评审报告 schema
- `.claude/agentflows/CLAUDE.md` 与 `.codex/agentflows/AGENTS.md`：平台适配层，只保留路径绑定、agent 生命周期和平台配置差异

运行态以 JSON 文件为准：

- `.claude/agentflows/state.json`
- `.codex/agentflows/state.json`
- `.../_agent/review-reports/taskXX-review.json`

## 核心设计

| 原则 | 说明 |
|------|------|
| **编排器只编排不生产** | 管理流水线、分派 Agent、判定门禁，绝不直接写交付代码 |
| **路径传递** | Agent 间只传文件路径，不复制需求正文或代码全文 |
| **文件即记忆** | 所有 Agent 输出写入文件系统，状态可恢复 |
| **评估师只读** | 评审代码但不修改，修复由建造师完成 |
| **失败恢复** | 评估 FAIL 后恢复同一 Agent 实例，最多 2 轮修复 |
| **上下文最小化** | 编排器不读 Builder 完整交付物，只看评审报告 |

### 流水线

```
你写 Spec  →  编排器启动  →  规划师设计架构  →  建造师写代码  →  评估师把关  →  你审查合并
   (人)         (自动)          (AI Agent)        (AI Agent)      (AI Agent)      (人)
```

### 角色

| 角色 | 职责 | 边界 |
|------|------|------|
| **Orchestrator** | 管理流水线、分派任务、判定门禁 | 不写交付代码 |
| **Feature Planner** | 分析需求，产出架构与实现计划 | 不写实现代码 |
| **Implementation Builder** | 按计划逐文件实现，修复评审问题 | 不评审自己的代码 |
| **Quality Evaluator** | 评审代码、运行门禁、判定 PASS/FAIL | 只读不写 |

---

## 命令

| 命令 | 功能 |
|------|------|
| `/agentflow` | 全流程：自动查找最近 spec，确认后 规划 → 实现 → 交付 |
| `/agentflow <spec>` | 全流程：使用指定 spec 路径 |
| `/agentflow:spec [想法\|路径]` | 剥洋葱式构建 spec，或审阅改进已有 spec |
| `/agentflow:mod [描述\|--full]` | 轻量修改：澄清 → 实现 → 门禁 |
| `/agentflow:plan <spec>` | 仅规划：产出架构设计与实现计划 |
| `/agentflow:build <plan>` | 仅实现：按计划编码 |
| `/agentflow:review` | 仅评审：对当前变更运行门禁 |

---

## 快速开始

```bash
# 1. 交互式写需求（七个维度层层深入）
/agentflow:spec "我的功能描述"

# 2. 执行全流程
/agentflow
```

### 分步执行

```bash
/agentflow:plan specs/xxx/feature-spec.md     # 先看架构和计划
/agentflow:build specs/xxx/implementation-plan.md  # 审查后实现
/agentflow:review                               # 最终评审
```

路径说明：上面的 `specs/...` 是逻辑路径。Claude Code 实际位于 `.claude/agentflows/specs/...`，Codex 实际位于 `.codex/agentflows/specs/...`。

---

## 安装

```bash
# Claude Code 项目
cp -r protocol /path/to/your-project/
cp -r .claude/agentflows /path/to/your-project/.claude/
cp CLAUDE.md /path/to/your-project/

# Codex 项目
cp -r protocol /path/to/your-project/
cp -r .codex/agentflows /path/to/your-project/.codex/
```

详见 [docs/agentflow-install.md](docs/agentflow-install.md)。

安装后请先按你的项目实际情况调整 `.codex/agentflows/config.yaml` 和 `.codex/agentflows/hooks.json`。模板默认不假设特定技术栈，未配置的 lint/typecheck/test 门禁应被视为 `SKIP`，而不是默认执行 Node 命令。

---

## 目录结构

```
├── CLAUDE.md                      # 项目根引导文件
├── protocol/                      # 平台无关核心规范与 schema
│   ├── core-spec.md
│   └── schemas/
├── .claude/agentflows/            # Claude Code 版协议
│   ├── CLAUDE.md                   # Claude 适配层
│   ├── state.json                  # 运行时状态
│   ├── settings.json               # 权限配置
│   ├── agents/                     # Agent 角色定义
│   ├── skills/                     # 开发技能
│   ├── tools/                      # 仪表盘
│   ├── specs/                      # 需求规格
│   └── _run/                       # 运行时日志
├── .codex/agentflows/             # Codex 版协议
│   ├── AGENTS.md                   # Codex 适配层
│   ├── state.json
│   ├── config.yaml
│   ├── hooks.json
│   ├── agents/
│   ├── tools/
│   ├── specs/
│   └── _run/
└── docs/                           # 文档
    ├── agentflow-usage-guide.md     # 使用指南
    └── agentflow-install.md         # 安装指南
```

---

## 文档

| 文档 | 内容 |
|------|------|
| [使用指南](docs/agentflow-usage-guide.md) | 完整操作手册：安装、写 spec、触发流程、故障排除 |
| [安装指南](docs/agentflow-install.md) | 2 步安装说明 |
| [`protocol/core-spec.md`](protocol/core-spec.md) | 平台无关核心规范 |
| [`.claude/agentflows/CLAUDE.md`](.claude/agentflows/CLAUDE.md) | Claude Code 适配层 |
| [`.codex/agentflows/AGENTS.md`](.codex/agentflows/AGENTS.md) | Codex 适配层 |

---

## 模板维护检查

```powershell
powershell -ExecutionPolicy Bypass -File scripts/validate-agentflow-template.ps1
```

这个检查会验证关键模板文件是否存在、文档是否仍在使用过时路径示例，以及是否误提交了本地配置。

---

## 许可

MIT
