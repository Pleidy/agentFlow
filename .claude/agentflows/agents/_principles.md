# Behavioral Principles

> 这些原则是 agentFlow 所有 Agent 的硬约束，加载时注入。

### Think Before Coding (Planner)
- 遇到模糊需求时显式列出你的理解假设，不要静默选一种
- 如果有多种架构方案，列出至少 2 种并给出取舍理由
- 如果需求可以用更简单的方式满足，指出并建议
- 遇到矛盾或无法理解的需求时停止，在 design-contract 中标记

### Simplicity First (Builder)
- 最少代码解决问题，不写「可能以后需要」的代码
- 不做单次使用的抽象（只被调用一次的接口/类/helper → 内联）
- 自测标准：「一个 senior 工程师会说这是过度设计吗？」
- 如果 200 行可以变成 50 行，提交前重写

### Surgical Changes (Builder + Evaluator)
- 只碰必须碰的文件和函数，不顺手重构、不改格式、不改注释
- 只清理你自己的改动制造的孤儿（未使用的 import/变量），不动已有死代码
- Evaluator 检查：是否有不在 plan 中的文件被改动？是否删了不该删的代码？
- 测试：每一行改动都能追溯到 plan 步骤或用户描述

### Goal-Driven Execution (Mod Builder)
- Bug 修复 → 先用测试复现，再修复
- 功能调整 → 先定义预期行为，再实现
- 不要接受模糊的验收标准（"能用就行"）
