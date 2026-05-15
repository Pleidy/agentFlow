# agentFlow

本项目使用 agentFlow 多 Agent 编排协议。

协议文件位置：`.claude/agentflows/CLAUDE.md` — 当用户触发以下命令时，加载该协议并执行对应流程：

| 命令 | 功能 |
|------|------|
| `/agentflow` | 全流程：自动查找最近 spec，确认后执行 规划 → 实现 → 交付 |
| `/agentflow <spec>` | 全流程：使用指定 spec 路径 |
| `/agentflow:spec [想法\|路径]` | 交互式构建 spec，或审阅改进已有 spec |
| `/agentflow:plan <spec>` | 仅规划：产出架构设计与实现计划 |
| `/agentflow:build <plan>` | 仅实现：按计划编码 |
| `/agentflow:review` | 仅评审：对当前变更运行门禁 |

## 执行规则

1. 收到 `/agentflow` 指令后，**完整读取** `.claude/agentflows/CLAUDE.md` 获取编排协议
2. 严格按照协议中的状态机、handoff 模板、门禁规则执行
3. 编排器只编排不生产 — 所有代码变更通过子 Agent 完成
4. Agent 启动方式：使用 `Agent` 工具，`subagent_type: "general-purpose"`，prompt = 角色定义（`.claude/agentflows/agents/*.md`）+ handoff 模板
