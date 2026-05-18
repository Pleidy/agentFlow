# agentFlow 安装指南

## 安装（2 步）

agentFlow 同时提供 Claude Code 版和 Codex 版模板。安装时复制你需要的那一套即可。两套平台模板共同继承仓库中的 `protocol/core-spec.md` 和 `protocol/schemas/*.json`。

### 步骤 1：复制协议目录

```bash
# Claude Code 项目
cp -r /path/to/agentflow/protocol .
cp -r /path/to/agentflow/.claude/agentflows .claude/

# Codex 项目
cp -r /path/to/agentflow/protocol .
cp -r /path/to/agentflow/.codex/agentflows .codex/
```

### 步骤 2：创建项目根引导文件

项目根需要一个极简 `CLAUDE.md`，让 Claude Code 知道 `/agentflow` 命令的存在和路由：

```bash
cat > CLAUDE.md << 'EOF'
# agentFlow

本项目使用 agentFlow 多 Agent 编排协议。

协议文件位置：`.claude/agentflows/CLAUDE.md` — 当用户触发以下命令时，加载该协议并执行对应流程：

| 命令 | 功能 |
|------|------|
| `/agentflow` | 全流程：自动查找最近 spec，确认后执行 规划 → 实现 → 交付 |
| `/agentflow <spec>` | 全流程：使用指定 spec 路径 |
| `/agentflow:spec [想法\|路径]` | 交互式构建 spec，或审阅改进已有 spec |
| `/agentflow:mod [描述\|--full]` | 轻量修改：澄清 → 实现 → 门禁 |
| `/agentflow:plan <spec>` | 仅规划：产出架构设计与实现计划 |
| `/agentflow:build <plan>` | 仅实现：按计划编码 |
| `/agentflow:review` | 仅评审：对当前变更运行门禁 |

## 执行规则

1. 收到 `/agentflow` 指令后，**先读取** `protocol/core-spec.md`，再读取 `.claude/agentflows/CLAUDE.md`
2. 严格按照协议中的状态机、handoff 模板、门禁规则执行
3. 编排器只编排不生产 — 所有代码变更通过子 Agent 完成
4. Agent 启动方式：使用 `Agent` 工具，`subagent_type: "general-purpose"`，prompt = 角色定义（`.claude/agentflows/agents/*.md`）+ handoff 模板
EOF
```

## 验证

复制完成后，在 Claude Code 中输入：

```
/agentflow help
```

编排器应响应可用命令列表。

## 安装后立刻要做的事

1. 按你的项目技术栈修改 `.codex/agentflows/config.yaml` 中的 `commands.lint`、`commands.typecheck`、`commands.test`。
2. 如果你要启用自动 hooks，再按相同技术栈修改 `.codex/agentflows/hooks.json`。
3. 在业务项目的 `.gitignore` 中加入运行时目录：

```gitignore
.claude/agentflows/_run/
.codex/agentflows/_run/
```

模板仓库保留 `_run/.gitkeep` 和 `lessons.md` 只是为了保留目录结构；实际运行生成的日志文件不建议提交。

## 安装后结构

```
your-project/
├── CLAUDE.md                 # ← 引导文件（步骤 2 创建）
├── protocol/
│   ├── core-spec.md
│   └── schemas/
├── .claude/
│   └── agentflows/           # ← 协议目录（步骤 1 复制）
│       ├── CLAUDE.md          # Claude 适配层
│       ├── state.json         # 运行时状态
│       ├── settings.json      # 权限配置
│       ├── agents/            # 角色定义（prompt 模板）
│       ├── skills/            # 可选技能
│       ├── tools/             # 仪表盘
│       ├── specs/             # 需求规格
│       └── _run/              # 运行时日志
├── .codex/
│   └── agentflows/
│       ├── AGENTS.md          # Codex 适配层
│       ├── config.yaml        # 需要按项目修改命令
│       ├── hooks.json         # 可选，默认为空 hooks
│       ├── state.json
│       ├── agents/
│       ├── tools/
│       ├── specs/
│       └── _run/
├── src/
└── ...
```

## 首次使用

```bash
# 1. 写需求
/agentflow:spec "我的功能描述"

# 2. 执行全流程
/agentflow
```

## 为什么需要根目录 CLAUDE.md

Claude Code 启动时只读取项目根目录的 `CLAUDE.md`，不会自动扫描 `.claude/` 子目录。根目录文件作为“引导线”，告诉 Claude Code `/agentflow` 命令存在，并指向 `protocol/core-spec.md` + `.claude/agentflows/CLAUDE.md` 获取完整协议。核心规则集中在 `protocol/`，平台差异集中在 `.claude/agentflows/` 下。
