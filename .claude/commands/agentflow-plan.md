# /agentflow plan — 架构设计与实现计划

加载 `.claude/agentflows/skills/plan-feature/SKILL.md` 技能定义，激活 Feature Planner 角色。

## 输入

- 一份 feature spec 的路径

## 产出

- `{OUTPUT_DIR}/architecture.md` — 架构设计（组件/模块、数据流、技术决策）
- `{OUTPUT_DIR}/implementation-plan.md` — 实现计划（文件清单、修改顺序、依赖关系）
- `{OUTPUT_DIR}/_agent/design-contract.md` — 设计合约（验收标准、非目标、假设）

## 约束

- 不写实现代码
- 不推断 spec 中未声明的需求
- 必须写「不做什么」

严格按照 `.claude/agentflows/skills/plan-feature/SKILL.md` 中的工作流执行。
