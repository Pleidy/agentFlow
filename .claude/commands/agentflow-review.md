# /agentflow review — 代码评审与门禁验证

加载 `.claude/agentflows/skills/review-implementation/SKILL.md` 技能定义，激活 Quality Evaluator 角色。

## 输入

- 架构设计、实现计划、设计合约
- Builder 产出的代码变更

## 门禁

1. **Lint** — 0 错误
2. **TypeCheck** — 0 错误
3. **Test** — 全部通过
4. **Plan Conformance** — 严格对照计划
5. **Security** — 安全审查

## 约束

- **只读** — 绝不修改代码，即使发现简单拼写错误也只写入报告
- 每个 issue 必须具体到文件路径和行号
- 判定 PASS 或 FAIL 必须附理由

严格按照 `.claude/agentflows/skills/review-implementation/SKILL.md` 中的工作流执行。
