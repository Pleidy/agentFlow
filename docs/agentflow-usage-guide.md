# agentFlow 使用指南

## 1. 协议阅读顺序

按这个顺序理解 agentFlow：

1. `protocol/core-spec.md`
2. `.claude/agentflows/CLAUDE.md` 或 `.codex/agentflows/AGENTS.md`
3. `protocol/schemas/*.json`

核心协议定义行为，适配层定义路径，schema 定义机器可验证的产物结构。

## 2. 关键命令

| 命令 | 用途 | Canonical 输出 |
|------|------|----------------|
| `/agentflow` | 全流程执行 | 计划、实现、评审、交付 |
| `/agentflow <spec>` | 对指定 spec 执行全流程 | 同上 |
| `/agentflow:spec [idea-or-path]` | 编写或改进 spec | `feature-spec.md` |
| `/agentflow:plan <spec>` | 只规划 | `_agent/plan-bundle.json` |
| `/agentflow:build <plan-bundle>` | 从已批准计划实现 | 代码变更 + `progress-log.json` |
| `/agentflow:mod [description|--full]` | 轻量修改 | `_agent/mod-bundle.json` |
| `/agentflow:review` | 只评审当前变更 | `taskXX-review.json` |

推荐的 build 入口：

```bash
/agentflow:build specs/user-auth/_agent/plan-bundle.json
```

## 3. Canonical Artifacts

以下 JSON 文件是编排、恢复、修复循环的权威依据：

- `state.json`
- `events.jsonl`
- `_agent/plan-bundle.json`
- `_agent/mod-bundle.json`
- `progress-log.json`
- `run-log.json`
- `_agent/review-reports/taskXX-review.json`

以下 Markdown 只是可选镜像：

- `architecture.md`
- `implementation-plan.md`
- `_agent/design-contract.md`
- `progress-log.md`
- `run-log.md`
- `_agent/review-reports/taskXX-review.md`
- `_run/{feature}/mod-review.md`

## 4. 一次完整运行会发生什么

### Phase 0: Initialize

编排器会：

1. 解析 spec 或 plan 路径
2. 绑定 `STATE_FILE`、`OUTPUT_DIR`、`RUN_DIR`
3. 写入 `state.json`
4. 写入 `events.jsonl`
5. 写入 `run-log.json` 首条记录

### task01: Plan

Planner 产出：

- `specs/{feature}/_agent/plan-bundle.json`

可选镜像：

- `architecture.md`
- `implementation-plan.md`
- `_agent/design-contract.md`

`plan-bundle.json` 至少应包含：

- architecture
- implementation steps with stable IDs such as `STEP-001`
- design contract
- risks / assumptions / exclusions

### task02: Implement

Builder 读取：

- `_agent/plan-bundle.json`

Builder 更新：

- `progress-log.json`

Repair 阶段 Builder 读取：

- `_agent/review-reports/task02-review.json`

### task03: Verify and Deliver

Evaluator 写入：

- `_agent/review-reports/taskXX-review.json`

Builder 或编排器可补充：

- `test-report.md`
- `pr-document.md`

## 5. `/agentflow:mod` 何时使用

适合：

- 1 到 3 个文件的 bugfix
- 小范围逻辑调整
- 不需要重新做架构设计的增量迭代

`/agentflow:mod --full` 额外要求：

- `_agent/mod-bundle.json`
- `progress-log.json`
- `run-log.json`

如果范围扩大到 3 个文件以上，或者已经出现新的边界设计问题，应该切回 `/agentflow:plan`。

## 6. 如何阅读产物

优先顺序建议如下：

1. `_agent/plan-bundle.json`
2. `_agent/review-reports/task02-review.json`
3. `progress-log.json`
4. `run-log.json`
5. 对应代码 diff

如果你只想快速人工浏览，再去看这些镜像：

1. `architecture.md`
2. `implementation-plan.md`
3. `task02-review.json` 对应的 Markdown 镜像（如果存在）

## 7. 评审报告结构

权威评审报告是：

- `task01-review.json`
- `task02-review.json`
- `task03-review.json`

每份报告必须遵循 `protocol/schemas/review-report.schema.json`，核心字段包括：

- `task`
- `judgment`
- `gate_results`
- `issues`
- `strengths`
- `rationale`

Issue 必须使用稳定 ID，例如：

- `ISSUE-001`
- `ISSUE-002`

修复循环中必须复用同一个 issue ID，直到该问题被关闭。

## 8. 恢复与续跑

恢复时不要依赖 Markdown。正确的恢复顺序是：

1. 读取 `.claude/agentflows/state.json` 或 `.codex/agentflows/state.json`
2. 读取最近的 `events.jsonl`
3. 读取最近的 `run-log.json`
4. 读取最近的 `progress-log.json`
5. 读取最近的 `taskXX-review.json`

判断是否能继续时，重点看：

- 当前 phase
- 当前 task id
- evaluator judgment
- open issues
- 最近一次成功完成的 step ID

## 9. 常见失败场景

### 规划失败

常见原因：

- 计划步骤不够具体
- 文件范围不清
- 引入了 spec 没要求的复杂抽象

优先检查：

- `_agent/plan-bundle.json`
- `task01-review.json`

### 实现失败

常见原因：

- lint、typecheck、test 失败
- 实现偏离计划
- 修复回合没有关闭 open issues

优先检查：

- `progress-log.json`
- `task02-review.json`
- 代码 diff

### 编排卡住

优先检查：

- `run-log.json`
- `events.jsonl`
- `state.json`

## 10. 推荐工作方式

```bash
# 1. 写 spec
/agentflow:spec "添加用户认证"

# 2. 只规划，先看方案
/agentflow:plan specs/user-auth/feature-spec.md

# 3. 审查 canonical 计划产物
cat specs/user-auth/_agent/plan-bundle.json

# 4. 再执行实现
/agentflow:build specs/user-auth/_agent/plan-bundle.json

# 5. 需要时单独复查
/agentflow:review
```

## 11. 模板维护检查

每次改协议模板后建议运行：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/validate-agentflow-template.ps1
```

这个脚本会检查：

- 必需 schema 是否存在
- 适配层是否引用 `core-spec.md`
- planner / mod-builder / evaluator prompt 是否引用对应 schema
- README 和使用文档是否仍然保留明显的旧约定
