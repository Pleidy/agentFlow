# agentFlow 安装指南

## 安装（3 步）

### 步骤 1：复制协议目录

```bash
cp -r .claude/agentflows /path/to/your-project/.claude/
```

### 步骤 2：复制命令注册

```bash
cp -r .claude/commands /path/to/your-project/.claude/
```

### 步骤 3：复制引导文件

```bash
cp CLAUDE.md /path/to/your-project/
```

## 验证

重启 Claude Code 后，输入 `/agentflow help`。编排器应响应可用命令列表。

## 安装后结构

```
your-project/
├── CLAUDE.md
├── .claude/
│   ├── commands/              # 命令注册
│   │   ├── agentflow.md              → /agentflow
│   │   ├── agentflow-spec.md         → /agentflow spec
│   │   ├── agentflow-mod.md          → /agentflow mod
│   │   ├── agentflow-plan.md         → /agentflow plan
│   │   ├── agentflow-build.md        → /agentflow build
│   │   └── agentflow-review.md       → /agentflow review
│   ├── agentflows/            # 编排协议
│   │   ├── CLAUDE.md
│   │   ├── agents/
│   │   ├── skills/
│   │   ├── tools/
│   │   ├── specs/
│   │   └── _run/
│   └── settings.json          # 权限 + 模型分配
├── src/
└── ...
```

## 首次使用

```bash
# 1. 写需求
/agentflow spec "我的功能描述"

# 2. 执行全流程
/agentflow
```

## 工作原理

- `.claude/commands/` — Claude Code 标准命令注册。每个 `.md` 文件 = 一个命令，文件内容 = 命令的行为指令
- `.claude/agentflows/` — 完整编排协议（状态机、Agent 角色、技能定义、运行时文件）
- `CLAUDE.md`（项目根） — 命令速查表 + 执行规则概要
