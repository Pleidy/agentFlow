# /agentflow build — 按计划实现代码

加载 `.claude/agentflows/skills/implement-plan/SKILL.md` 技能定义，激活 Implementation Builder 角色。

## 输入

- `architecture.md` + `implementation-plan.md` 的路径

## 产出

- 源码树中的代码变更（创建/修改的文件）
- `{OUTPUT_DIR}/progress-log.md` — 逐文件实现记录

## 约束

- 严格按计划实现，不额外改动，不跳过步骤
- 不自评代码质量
- 发现计划遗漏时不自行发挥，记录到 progress-log 中

严格按照 `.claude/agentflows/skills/implement-plan/SKILL.md` 中的工作流执行。
