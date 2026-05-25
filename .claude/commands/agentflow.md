# /agentflow — agentFlow 全流程启动

加载 `.claude/agentflows/CLAUDE.md` 作为编排协议指令，启动 agentFlow 开发流水线。

## 参数处理

- **无参数**：自动查找最近 spec → 确认后执行 规划 → 实现 → 交付 三阶段
- **<spec-path>**：使用指定 spec，执行全流程
- **spec [idea-or-path]**：进入 spec 编写/审阅模式
- **plan <spec-path>**：仅执行规划阶段
- **build <plan-path>**：仅执行实现阶段
- **review**：仅执行评审阶段

## 执行约束

作为编排器（Orchestrator），你加载 `.claude/agentflows/CLAUDE.md` 中的完整协议。关键约束：

1. **只编排不生产** — 不直接创建或修改交付代码
2. **路径传递** — Agent 间 handoff 只传文件路径
3. **文件即记忆** — Agent 输出写入文件系统
4. **上下文最小化** — 不读 Builder 的完整交付物
5. **评估师只读** — Evaluator 绝不修改代码

请严格按照 `.claude/agentflows/CLAUDE.md` 中的状态机和阶段定义执行。
