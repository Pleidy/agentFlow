# agentFlow

> 每个需求都能长成可运行的代码。
> Every requirement can grow into working code.

agentFlow 是一个**多 Agent 开发编排协议**。它定义了一套流水线，让多个 AI Agent（规划师、建造师、评估师）按照严格的规则协作，将一份需求规格文档转化为可交付的代码变更。

---

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
| `/agentflow:mod [描述\|--full]` | 轻量修改：澄清需求后改代码 + 门禁，无需 spec/plan |
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

---

## 安装

```bash
# Claude Code 项目
cp -r .claude/agentflows /path/to/your-project/.claude/
cp CLAUDE.md /path/to/your-project/

# Codex 项目
cp -r .codex/agentflows /path/to/your-project/.codex/
```

详见 [docs/agentflow-install.md](docs/agentflow-install.md)。

---

## 目录结构

```
├── CLAUDE.md                      # 项目根引导文件
├── .claude/agentflows/            # Claude Code 版协议
│   ├── CLAUDE.md                   # 完整编排协议
│   ├── state.md                    # 运行时状态机
│   ├── settings.json               # 权限配置
│   ├── agents/                     # Agent 角色定义
│   ├── skills/                     # 开发技能
│   ├── tools/                      # 仪表盘
│   ├── specs/                      # 需求规格
│   └── _run/                       # 运行时日志
├── .codex/agentflows/             # Codex 版协议
│   ├── AGENTS.md
│   ├── state.md
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
| [`.claude/agentflows/CLAUDE.md`](.claude/agentflows/CLAUDE.md) | Claude Code 版完整编排协议 |
| [`.codex/agentflows/AGENTS.md`](.codex/agentflows/AGENTS.md) | Codex 版完整编排协议 |

---

## 许可

MIT
