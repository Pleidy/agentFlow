# /agentflow mod — 轻量修改

加载 `.claude/agentflows/skills/modify-feature/SKILL.md` 技能定义，激活轻量修改流程。不需要 spec，不需要架构设计。

## 模式

- **无参数** — 从上下文推断要改什么
- **<description>** — 聚焦澄清 → 实现 → 门禁
- **--full <description>** — 同上，额外产出 progress-log + review-report

## 约束

- 一次只问一个问题，最多 3 轮澄清
- 不改无关代码，不动已有风格
- 每行改动必须能追溯到用户描述
- 改动超过 3 个文件时建议改用 `/agentflow plan`

严格按照 `.claude/agentflows/skills/modify-feature/SKILL.md` 中的工作流执行。
