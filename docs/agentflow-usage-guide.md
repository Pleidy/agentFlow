# agentFlow 使用指南

> 从需求到可交付代码的完整编排流程操作手册

---

## 目录

1. [概述](#1-概述)
2. [安装与配置](#2-安装与配置)
3. [编写需求规格](#3-编写需求规格)
4. [触发编排流程](#4-触发编排流程)
5. [阶段详解](#5-阶段详解)
6. [阅读与理解产出](#6-阅读与理解产出)
7. [处理失败与修复](#7-处理失败与修复)
8. [仪表盘使用](#8-仪表盘使用)
9. [Git 工作流集成](#9-git-工作流集成)
10. [完整示例](#10-完整示例)
11. [故障排除](#11-故障排除)
12. [自定义与扩展](#12-自定义与扩展)
13. [Claude Code vs Codex 对照表](#13-claude-code-vs-codex-对照表)

---

## 1. 概述

### 什么是 agentFlow

agentFlow 是一个**多 Agent 开发编排协议**。它定义了一套流水线，让多个 AI Agent（规划师、建造师、评估师）按照严格的规则协作，将一份需求规格文档转化为可交付的代码变更。

### 核心理念

```
你写 Spec  →  编排器启动  →  规划师设计架构  →  建造师写代码  →  评估师把关  →  你审查合并
   (人)         (自动)          (AI Agent)        (AI Agent)      (AI Agent)      (人)
```

**你在流程中的角色**：
- **触发前**：编写清晰的需求规格
- **运行中**：不干预（编排器自主完成）
- **完成后**：审查最终产出，决定是否合并

### 什么时候用 agentFlow

**适合**：
- 中大型功能开发（涉及 3+ 文件、2+ 模块）
- 需要架构设计的功能
- 希望有独立 AI 评审的代码变更
- 自动化程度高的个人或小团队项目

**不太适合**：
- 单文件小改动（如改一个配置、加一个日志）
- 需要实时人类判断的探索性任务
- 紧急 hotfix

---

## 2. 安装与配置

### 2.1 选择你的编码工具版本

agentFlow 提供两套实现：

| | Claude Code 版 | Codex 版 |
|---|---|---|
| 目录 | `.claude/agentflows/` | `.codex/agentflows/` |
| 编码工具 | Claude Code CLI | Codex CLI (ChatGPT) |
| 主指令文件 | `CLAUDE.md` | `AGENTS.md` |
| 触发前缀 | `/agentflow` `/agentflow:plan` 等 | `/agentflow` `/agentflow:plan` 等 |

### 2.2 Claude Code 版安装

**步骤 1**：确保 `.claude/agentflows/` 目录存在

```bash
ls .claude/agentflows/CLAUDE.md
```

**步骤 2**：调整 `.claude/settings.json`

```json
{
  "permissions": {
    "allow": [
      "Bash(npm test:*)",
      "Bash(npm run lint:*)",
      "Bash(npx tsc:*)",
      "Bash(pytest:*)",
      "Bash(cargo test:*)",
      "Bash(git diff:*)",
      "Bash(git status:*)",
      "Read(*)",
      "Write(*)",
      "Edit(*)"
    ]
  }
}
```

根据你的项目修改 lint/test 命令。

**步骤 3**：将 `_run/` 加入 `.gitignore`

```bash
echo "_run/" >> .gitignore
```

**步骤 4**：验证安装

在 Claude Code 中发送：`/agentflow help`

编排器应响应一条消息，确认协议已加载并显示可用命令。

### 2.3 Codex 版安装

**步骤 1**：确保 `.codex/agentflows/` 目录存在

```bash
ls .codex/agentflows/AGENTS.md
```

**步骤 2**：调整 `.codex/agentflows/config.yaml`

```yaml
commands:
  lint: "npm run lint"      # 改为你的项目命令
  typecheck: "npx tsc --noEmit"  # 改为你的项目命令
  test: "npm test"          # 改为你的项目命令
```

**步骤 3**：将 `_run/` 加入 `.gitignore`

```bash
echo "_run/" >> .gitignore
```

**步骤 4**：验证安装

在 Codex 中发送：`/agentflow help`

---

## 3. 编写需求规格

### 3.1 Spec 文件结构

Spec 文件是你与编排系统的**唯一输入**。Agent 的所有决策依据必须来自这个文件。

在 `specs/{feature-name}/` 下创建 `feature-spec.md`：

```markdown
# Feature: {功能名称}

## 概述
{2-3 句话描述这个功能要做什么}

## 动机
{为什么要做这个功能？解决什么问题？}

## 用户故事
- 作为 {角色}，我想要 {功能}，以便 {价值}
- 作为 {角色}，我想要 {功能}，以便 {价值}

## 验收标准
- [ ] {可验证的条件 1}
- [ ] {可验证的条件 2}
- [ ] {可验证的条件 3}

## 约束
- {技术约束，如「必须兼容 IE11」}
- {性能约束，如「列表渲染 < 100ms」}
- {依赖约束，如「不能引入新的第三方库」}

## 非目标（Explicit Exclusions）
- 不会实现 X（原因：超出本次范围）
- 不会修改 Y（原因：属于其他模块）

## 参考
- {相关的设计文档、竞品截图、接口文档链接}
```

### 3.2 Spec 编写原则

**写好 Spec 的五个标准**：

| 标准 | 含义 | 坏的例子 | 好的例子 |
|------|------|---------|---------|
| **有边界** | 范围明确，不说「做一个用户系统」 | 「完善用户相关功能」 | 「添加邮箱登录和密码重置」 |
| **有目的** | 说明为什么做，不是为了做而做 | 「加一个导出功能」 | 「用户需要将报表导出给财务，支持 PDF 格式」 |
| **可执行** | 具体到可以开始编码 | 「优化性能」 | 「将列表渲染从 500ms 降到 100ms 以下」 |
| **可验证** | 有明确的 PASS/FAIL 标准 | 「体验要好」 | 「登录失败 3 次后显示验证码，锁定 15 分钟」 |
| **有出口** | 有应用场景或交付形式 | 「学习 React 原理」 | 「产出可运行的 TodoMVC 示例 + 架构说明」 |

### 3.3 Spec 示例（一个真实级别）

```markdown
# Feature: 添加用户认证模块

## 概述
为应用添加邮箱+密码的认证系统，包含注册、登录、密码重置功能。

## 动机
当前应用无用户认证，无法区分用户数据。需要为后续的多租户功能打基础。

## 用户故事
- 作为新用户，我想要用邮箱注册账号，以便使用个人化功能
- 作为已注册用户，我想要用邮箱和密码登录，以便访问我的数据
- 作为忘记密码的用户，我想要重置密码，以便恢复访问

## 验收标准
- [ ] 用户可以用邮箱+密码注册（邮箱格式校验，密码最少 8 位）
- [ ] 用户可以用注册的邮箱+密码登录，获取 JWT token
- [ ] 用户可以通过邮箱收到重置链接，设置新密码
- [ ] 所有 API 端点有输入校验，返回标准错误格式
- [ ] 密码使用 bcrypt 哈希存储，不存明文
- [ ] 登录失败 5 次后账号锁定 30 分钟

## 约束
- 使用现有的 Express + TypeScript 技术栈
- JWT token 有效期 24 小时
- 邮箱发送使用项目已有的 mailer 模块
- 不引入第三方认证服务（Auth0, Firebase Auth 等）

## 非目标
- 不会实现 OAuth/社交登录（下一期）
- 不会修改前端 UI（另有前端任务）
- 不会做邮箱验证（注册后即可登录，邮箱验证后续加）

## 参考
- API 响应格式：`/docs/api-conventions.md`
- 现有 User 模型：`src/models/user.ts`
- mailer 模块：`src/services/mailer.ts`
```

---

### 3.4 使用 `/agentflow:spec` 辅助编写 Spec

`/agentflow:spec` 采用**剥洋葱式**的需求挖掘——每个维度逐层深入，直到信息达到最小颗粒。

**核心原则**：一次只问一个问题，每个回答继续深挖，直到不可再分。

```
表面: "我要一个导出功能"
  ↓ "导出什么？" → "基金数据"
  ↓ "哪些字段？" → "代码、名称、净值、涨跌幅"
  ↓ "净值是实时还是昨日？" → "昨日收盘净值"
  ↓ "涨跌幅是日涨幅还是持仓盈亏？" → "日涨跌幅百分比"
  ↓ "百分比格式？" → "保留两位小数，正数带+号"
  ↓ 到达最小颗粒 → 确认，切换到下一个维度
```

**七个维度**（逐一攻破）：

| # | 维度 | 剥到什么程度 |
|---|------|-------------|
| 1 | 用户与场景 | 精确到角色、触发时刻、成功定义 |
| 2 | 功能边界 | 一句话可编码的 Scope、入口/出口 |
| 3 | 数据与状态 | 每个字段的类型/来源/校验、所有状态枚举 |
| 4 | 交互与流程 | 逐步操作、每步反馈、happy path + 3 条错误路径 |
| 5 | 约束与限制 | 精确数字（不是"快"而是"<200ms"） |
| 6 | 验收标准 | 机器可验证、可写测试用例 |
| 7 | 非目标 | 至少 3 项明确排除，每项有原因 |

**进度追踪**：每完成一个维度，显示进度表：

```
| 维度 | 状态 |
|------|------|
| 1. 用户与场景  | ✅ 已确认 |
| 2. 功能边界    | ⏳ 进行中 |
| 3-7            | ⬜ 待处理 |
```

全部 7 个维度 ✅ 后才生成 spec 文件。

**模式 B：审阅改进**

```bash
/agentflow:spec specs/user-auth/feature-spec.md
```

对已有 spec 按七个维度逐一评分（PASS/WEAK/MISSING），对薄弱维度进入洋葱式追问，补齐后写回。

---

## 4. 触发编排流程

### 4.1 触发器一览

| 触发器（Claude Code） | 触发器（Codex） | 功能 | 产出 |
|----------------------|----------------|------|------|
| `/agentflow` | `/agentflow` | **全流程**：自动查找最近 spec 并确认 | 同下，spec 自动检测 |
| `/agentflow <spec>` | `/agentflow <spec>` | **全流程**：指定 spec 路径 | 完整的代码变更 + PR 文档 |
| `/agentflow:spec [想法\|路径]` | `/agentflow:spec [想法\|路径]` | **写需求**：交互式构建或审阅改进 spec | feature-spec.md |
| `/agentflow:plan <spec>` | `/agentflow:plan <spec>` | **仅规划**：只做架构和计划 | architecture.md + implementation-plan.md |
| `/agentflow:build <plan>` | `/agentflow:build <plan>` | **仅实现**：从已有计划编码 | 代码变更 |
| `/agentflow:review` | `/agentflow:review` | **仅评审**：对当前变更运行门禁 | 评审报告 |

### 4.2 典型使用流程

```bash
# 步骤 1：编写 spec（或用 /agentflow:spec 交互式构建）
mkdir -p specs/user-auth
vim specs/user-auth/feature-spec.md

# 步骤 2：触发全流程
# 方式 A：直接执行（如果刚刚写过 spec，agentFlow 会自动找到它）
/agentflow
# → 编排器检测到 specs/user-auth/feature-spec.md 是最近 spec
# → "使用 spec: specs/user-auth/feature-spec.md？[Y/n]"
# → 确认后启动流水线

# 方式 B：显式指定路径
/agentflow:specs/user-auth/feature-spec.md

# 此时编排器自动执行：
# → Phase 0: 初始化（创建目录、解析变量）
# → Phase 1: 规划师分析 spec，产出架构和计划
# → Phase 1 评审：架构是否合理？计划是否可执行？
# → Phase 2: 建造师按计划实现，文件逐个完成
# → Phase 2 评审：lint？typecheck？test？代码是否按计划？
# → Phase 3: 建造师产出测试报告和 PR 文档
# → Phase 3 评审：交付物是否完整？
# → 完成！报告结果

# 步骤 3：审查和合并
git diff
git checkout -b feature/user-auth
git add .
git commit -m "feat: add user authentication"
```

### 4.3 分步执行（更多控制）

如果你希望在每个阶段审查后再继续：

```bash
# 只做规划
/agentflow:plan specs/user-auth/feature-spec.md
# → 产出 specs/user-auth/architecture.md
# → 产出 specs/user-auth/implementation-plan.md
# → 你审查架构和计划，修改后继续

# 从已审查的计划开始实现
/agentflow:build specs/user-auth/implementation-plan.md
# → 按计划实现代码

# 运行完整评审
/agentflow:review
# → 运行 lint + typecheck + test + AI 评审
```

---

## 5. 阶段详解

### 5.1 阶段 0：初始化（30秒内完成）

编排器自动执行：
1. 读取 spec 文件路径，生成项目名（从目录名 + 时间戳）
2. 创建目录结构
3. 写入 `state.md`（phase=init）
4. 写入 `_run/{name}/run-log.md` 首条
5. 写入 `_run/{name}/events.jsonl` 首条 `project_started` 事件
6. 尝试启动仪表盘（失败不阻塞）

**此时 state.md 的内容**：

```yaml
phase: init
spec_file: specs/user-auth/feature-spec.md
feature_name: user-auth
output_dir: specs/user-auth/
run_dir: _run/user-auth/
```

### 5.2 阶段 1：规划（5-15分钟）

**发生了什么**：

1. 编排器启动 **Feature Planner**（规划师 Agent）
2. 传给规划师的 handoff 指令只包含：
   - spec 文件路径
   - 输出目录路径
   - 协议约束（不写代码、只用 spec 中显式信息）
3. 规划师读取 spec → 探索代码库 → 写三个文件
4. 编排器收到规划师返回的文件路径
5. 编排器启动 **Quality Evaluator** 评审规划
6. 评估师检查 4 个维度 → 写评审报告 → 返回 PASS/FAIL
7. 如果 FAIL → 同一位规划师修复（最多 2 轮）

**产出文件**：

```
specs/user-auth/
├── architecture.md           # ← 架构设计
├── implementation-plan.md    # ← 实现计划
└── _agent/
    ├── design-contract.md    # ← 设计合约
    └── review-reports/
        └── task01-review.md  # ← 规划评审
```

**architecture.md 示例片段**：

```markdown
# 用户认证 — 架构设计

## 组件

- **AuthController** (`src/controllers/auth.ts`) — HTTP 路由处理
- **AuthService** (`src/services/auth.ts`) — 业务逻辑
- **UserRepository** (`src/repositories/user.ts`) — 数据访问
- **TokenService** (`src/services/token.ts`) — JWT 生成与验证

## 数据流

Client → AuthController → AuthService → UserRepository → DB
                ↓
           TokenService → JWT → Client

## 技术决策

- JWT 而非 Session：项目已有 JWT 工具函数
- bcrypt 而非 argon2：项目已有 bcrypt 依赖
```

**implementation-plan.md 示例片段**：

```markdown
# 实现计划

### Step 1: 创建 User 数据模型
- File: `src/models/user.ts` (modify)
- Scope: 添加 passwordHash, lockUntil, loginAttempts 字段
- Dependencies: none
- Complexity: straightforward

### Step 2: 实现 JWT Token 服务
- File: `src/services/token.ts` (create)
- Scope: generateToken, verifyToken, decodeToken
- Dependencies: none
- Complexity: straightforward

### Step 3: 实现 Auth 业务逻辑
- File: `src/services/auth.ts` (create)
- Scope: register, login, requestPasswordReset, resetPassword
- Dependencies: Step 1, Step 2
- Complexity: moderate
```

### 5.3 阶段 2：实现（10-30分钟）

**发生了什么**：

1. 编排器启动 **Implementation Builder**（建造师 Agent）
2. 传给建造师的 handoff 只包含 architecture.md 和 implementation-plan.md 的路径
3. 建造师**按照计划的步骤顺序**，逐个文件实现：
   ```
   读取 Step 1 → 创建/修改文件 → 自检 → 更新 progress-log.md
   读取 Step 2 → 创建/修改文件 → 自检 → 更新 progress-log.md
   ...
   ```
4. 所有文件实现完后，返回修改文件列表
5. 编排器启动 **Quality Evaluator** 运行门禁：
   ```
   npm run lint     → 通过？
   npx tsc --noEmit → 通过？
   npm test         → 通过？
   AI 评审          → 代码是否按计划实现？
   ```
6. 如果任一门禁失败 → 恢复同一建造师修复（最多 2 轮）

**progress-log.md 示例**：

```markdown
## Progress Log

### Step 1: User 数据模型 — DONE
- File: src/models/user.ts (modified)
- Completed: 2026-05-13 15:30
- Notes: 添加了 passwordHash, lockUntil, loginAttempts 字段，使用 @BeforeInsert hook 自动哈希密码

### Step 2: JWT Token 服务 — DONE
- File: src/services/token.ts (created)
- Completed: 2026-05-13 15:42
- Notes: 复用了 config/jwt.ts 中的密钥配置

### Step 3: Auth 业务逻辑 — DONE
- File: src/services/auth.ts (created)
- Completed: 2026-05-13 16:05
- Notes: register 做了邮箱去重检查。login 实现了失败计数和锁定逻辑。

### Step 4: Auth Controller — DONE
- File: src/controllers/auth.ts (created)
- Completed: 2026-05-13 16:20
- Notes: 四个端点：POST /auth/register, POST /auth/login, POST /auth/forgot-password, POST /auth/reset-password
```

### 5.4 阶段 3：交付（5-10分钟）

**发生了什么**：

1. 编排器启动 Builder（新实例）— 这次的任务是写文档
2. Builder 产出 `test-report.md` 和 `pr-document.md`
3. 编排器启动 Evaluator 做最终评审
4. 如果 PASS → 汇总结果 → 报告用户

**pr-document.md 示例**：

```markdown
# PR: 添加用户认证模块

## What
实现了邮箱+密码的用户认证系统，包括注册、登录、密码重置。

## Why
当前应用无法区分用户，多租户功能需要认证作为前置条件。

## How
- 扩展 User 模型，添加认证相关字段
- 新建 AuthService 处理业务逻辑
- 新建 AuthController 暴露 REST 端点
- 所有密码 bcrypt 哈希存储
- 登录失败 5 次锁定 30 分钟

## Test Plan
- [x] 注册成功/邮箱重复/格式校验
- [x] 登录成功/密码错误/账号锁定
- [x] 密码重置流程
- [x] Token 过期处理
- [x] 输入校验错误格式

## Rollback
- 新增的数据库字段有默认值，回滚只需删除迁移文件
- Auth 相关端点可独立下线，不影响现有功能
```

---

## 6. 阅读与理解产出

### 6.1 文件分类

每次运行完成后，`specs/{feature}/` 下有三类文件：

| 类别 | 目录 | 用途 | 你该关注的 |
|------|------|------|-----------|
| **面向你的交付物** | 根目录 | 架构、计划、文档 | ✅ 全部 |
| **Agent 内部文件** | `_agent/` | 合约、评审报告 | ✅ 评审报告 |
| **运行时日志** | `_run/{feature}/` | 事件流、状态 | ❌ 一般不需要看 |

### 6.2 首先看什么

按优先级顺序：

1. **`architecture.md`** — 理解系统怎么设计的
2. **`implementation-plan.md`** — 理解改了哪些文件和为什么是这个顺序
3. **`_agent/review-reports/task02-review.md`** — 建造师代码质量的独立评审
4. **`pr-document.md`** — 如果你要提交 PR，这可以直接用
5. **代码 diff**（`git diff`）— 最终产物

### 6.3 评审报告结构

```markdown
# Implementation — Evaluation Report

## Gates
| Gate | Status |
|------|--------|
| Lint | ✅ 0 errors |
| TypeCheck | ✅ 0 errors |
| Test | ✅ 14 passed |
| Plan Conformance | ✅ All steps implemented |
| Security | ✅ No issues found |

## Findings
### Strengths
- Error handling covers all expected failure modes
- Token expiration logic follows best practices

### Issues
(none — all gates passed)

## Judgment
PASS

## Rationale
All verification gates passed. Code follows the implementation plan exactly. Security review found no issues. Ready for delivery phase.
```

如果看到 **FAIL**，会有具体的问题清单，格式如：
```markdown
- [ ] `src/services/auth.ts:L47` — 未检查邮箱是否已注册就创建新用户。Fix: 在 createUser 之前调用 findUserByEmail 检查
```

---

## 7. 处理失败与修复

### 7.1 修复循环机制

每个任务的评估如果 FAIL，编排器自动进入修复循环：

```
Build → Evaluate → FAIL
  ↓
Resume 同一 Builder + 同一 Evaluator
  ↓
Builder 读取评审报告，修复 Issue 1, Issue 2, ...
  ↓
Evaluate 再次评审
  ↓
PASS → 进入下一个任务
FAIL → 再次修复（最多 2 轮）
  ↓
2 轮后仍 FAIL → 标记 ⚠️，继续下一任务（不阻塞整个流水线）
```

### 7.2 各阶段的常见失败原因

| 阶段 | 常见 FAIL 原因 | 修复方向 |
|------|---------------|---------|
| task01 规划 | 计划太模糊（「重构相关代码」） | 要求规划师指定具体文件和改动 |
| task01 规划 | 架构引入了 spec 未要求的复杂度 | 要求规划师遵循 spec 约束 |
| task02 实现 | Lint 不通过 | Builder 运行 lint 修复 |
| task02 实现 | 测试失败 | Builder 根据失败信息修复 |
| task02 实现 | 遗漏了计划的某个步骤 | 评审报告列出遗漏步骤，Builder 补充 |
| task02 实现 | 代码有安全漏洞 | 评审报告指出漏洞和修复方法 |
| task03 交付 | PR 文档缺少关键信息 | Builder 补充缺失部分 |

### 7.3 人工介入时机

虽然 agentFlow 设计为无人干预，但以下情况你应该介入：

- **2 轮修复后仍然 FAIL** — 编排器会继续但标记 ⚠️，你需要判断是否接受
- **架构方向错误** — 规划师可能误解了 spec，需要你重写 spec 或手动修改 architecture.md
- **编排器卡住** — 如果超时或重复循环，检查 `_run/{feature}/run-log.md` 了解卡在哪一步

---

## 8. 仪表盘使用

### 8.1 启动仪表盘

```bash
./tools/open-dashboard.sh
```

脚本自动查找最近的 `events.jsonl` 并在浏览器中打开仪表盘。

### 8.2 仪表盘功能

仪表盘是一个纯前端页面（无需后端），显示：

- **顶部摘要** — 项目名、评估次数、PASS 数、修复次数
- **阶段进度条** — 当前在哪个阶段（蓝色高亮），哪些已完成（绿色）
- **任务卡片** — 每个 task 的判定结果、迭代次数、产出文件数
- **事件时间线** — 每次 Agent 启动/完成/评估的时序记录

### 8.3 手动加载事件文件

如果自动查找失败：

1. 打开仪表盘页面
2. 将 `_run/{feature}/events.jsonl` 拖入页面区域
3. （可选）同时拖入 `state.json` 查看任务详情

### 8.4 事件类型速查

| 事件类型 | 含义 | 关键字段 |
|---------|------|---------|
| `project_started` | 运行开始 | project, source, output |
| `agent_started` | Agent 启动 | role, task, instruction |
| `agent_finished` | Agent 完成 | role, outputs |
| `task_status_changed` | 任务状态变更 | task, from, to |
| `evaluation_finished` | 评估完成 | task, judgment, round |
| `agent_resumed` | Agent 恢复修复 | task, reason, round |
| `project_finished` | 运行结束 | status, duration |

---

## 9. Git 工作流集成

### 9.1 推荐流程

```bash
# 1. 从干净的工作区开始
git stash
git checkout main
git pull

# 2. 在 Claude Code / Codex 中触发 agentFlow
/agentflow:specs/user-auth/feature-spec.md

# 3. 完成后审查变更
git diff                    # 看所有代码变更
git diff --stat             # 看改了哪些文件

# 4. 创建功能分支
git checkout -b feature/user-auth

# 5. 提交
git add .
git commit -m "$(cat specs/user-auth/pr-document.md | head -20)"

# 6. 推送并创建 PR
git push -u origin feature/user-auth
```

### 9.2 Git 安全建议

- **触发前确保工作区干净** — `git stash` 或提交现有变更
- **每次 agentFlow 运行放在独立分支** — 方便回滚
- **不要在一个分支上多次运行 agentFlow** — 每次运行创建新分支
- **`_run/` 目录加入 `.gitignore`** — 运行时日志不进入版本控制

---

## 10. 完整示例

### 10.1 场景：为基金助手 Chrome 插件添加数据导出功能

**步骤 1：编写 Spec**

```bash
mkdir -p specs/export-feature
```

`specs/export-feature/feature-spec.md`：

```markdown
# Feature: 基金数据导出

## 概述
允许用户将自选基金列表导出为 CSV 文件。

## 动机
用户希望将数据导入 Excel 做进一步分析，当前只能查看不能导出。

## 用户故事
- 作为基金投资者，我想导出我的自选基金数据为 CSV，以便在 Excel 中分析
- 作为用户，我希望能选择导出哪些字段（代码、名称、净值、涨跌幅等）

## 验收标准
- [ ] 在 popup 页面添加「导出 CSV」按钮
- [ ] 点击按钮下载 CSV 文件，包含当前显示的所有基金数据
- [ ] CSV 包含表头行（中文列名）
- [ ] CSV 文件名格式：funds_export_YYYY-MM-DD.csv
- [ ] 用户可以勾选/取消勾选要导出的列
- [ ] 导出功能在 Chrome 和 Edge 上均可正常工作
- [ ] 10 条基金数据导出时间 < 500ms

## 约束
- 不引入第三方 CSV 库（手动构建 CSV 字符串）
- 使用 Chrome Extension storage API 获取基金数据
- UI 遵循现有的 popup 设计风格
- Manifest V2（不升级到 V3）

## 非目标
- 不会实现 Excel 格式导出（.xlsx）
- 不会实现定时自动导出
- 不会添加导出历史记录

## 参考
- Popup 现有布局：src/popup/App.vue
- 数据获取：src/background.js
```

**步骤 2：触发 agentFlow**

```
/agentflow:specs/export-feature/feature-spec.md
```

**步骤 3：编排器执行**

```
[agentFlow] Phase 0: Init — 解析变量，创建目录
[agentFlow] Phase 1: Planning — 启动 Feature Planner...
[agentFlow] task01 评估: ✅ PASS (1 round)
[agentFlow] Phase 2: Implementation — 启动 Builder...
[agentFlow] task02 评估: ❌ FAIL — Lint error in export.js → Repair round 1
[agentFlow] task02 评估: ✅ PASS (2 rounds)
[agentFlow] Phase 3: Delivery — 启动 Builder...
[agentFlow] task03 评估: ✅ PASS (1 round)
[agentFlow] ✅ Complete! Duration: 18m 32s
[agentFlow] Output: specs/export-feature/
[agentFlow] Modified: src/popup/App.vue, src/popup/export.js, src/manifest.json
```

**步骤 4：审查**

```bash
git diff --stat
# src/manifest.json    |  1 +
# src/popup/App.vue    | 45 ++++++++++++++++
# src/popup/export.js  | 89 ++++++++++++++++++++++++++
# specs/export-feature/|  5 files

cat specs/export-feature/pr-document.md
# (查看 PR 文档，确认变更范围)
```

**步骤 5：合并**

```bash
git checkout -b feature/export
git add src/ specs/export-feature/
git commit -m "feat: add fund data CSV export"
git push -u origin feature/export
# 创建 PR
```

---

## 11. 故障排除

### 11.1 编排器不响应触发器

**症状**：发送 `/agentflow:specs/...` 后编排器直接回答了问题而不是启动流水线。

**原因**：CLAUDE.md / AGENTS.md 未加载，或触发器未被识别。

**解决**：
- 确认 `CLAUDE.md`（Claude Code）在 `.claude/agentflows/` 中，或 `AGENTS.md`（Codex）在 `.codex/agentflows/` 中
- 重新启动编码工具，确保加载了项目级指令
- 试试显式触发：`/agentflow:specs/...`

### 11.2 Agent 启动失败

**症状**：编排器报告「Unable to start agent」或类似错误。

**原因**：Agent 工具权限不足，或 Agent 定义文件路径不正确。

**解决**：
- 检查 `.claude/settings.json` 中的 permissions 是否包含所需工具
- 检查 Agent 定义文件是否在正确位置（`.claude/agentflows/agents/` 或 `.codex/agentflows/agents/`）
- 尝试手动启动 Agent 测试

### 11.3 门禁全部 SKIP

**症状**：评审报告所有门禁都是 `⚠️ SKIP (not configured)`。

**原因**：项目未配置 lint/typecheck/test 命令。

**解决**：
- 编辑 `.claude/agentflows/settings.json` 或 `.codex/agentflows/config.yaml`，将命令改为你的项目实际命令
- 如果项目确实没有某个门禁（如 TypeScript 项目的 typecheck），可以接受 SKIP

### 11.4 修复循环无限进行

**症状**：同一个 task 在 BUILD → FAIL → REPAIR 之间循环超过 2 轮。

**原因**：评审指出的问题 Builder 无法修复，或评审和 Builder 对问题的理解不一致。

**解决**：
- 编排器应在 2 轮后强制结束，如果没结束，手动停止
- 读取评审报告，手动修复代码
- 考虑 spec 是否存在根本性问题

### 11.5 从断点恢复

**症状**：流水线因超时、网络错误或工具调用失败中断。

**解决**：
1. 读取 `state.md` 查看当前阶段
2. 读取 `_run/{feature}/run-log.md` 查看最近完成的步骤
3. 从下一个未完成的步骤继续：
   ```
   # 如果卡在 task02 build，手动触发：
   /agentflow:build specs/user-auth/implementation-plan.md
   ```

---

## 12. 自定义与扩展

### 12.1 调整 Agent 模型

**Claude Code** — 编辑 `.claude/settings.json`：

```json
{
  "agents": {
    "feature-planner": { "model": "opus" },
    "implementation-builder": { "model": "sonnet" },
    "quality-evaluator": { "model": "opus" }
  }
}
```

模型选择建议：
- Planner 和 Evaluator 用 Opus（需要深度推理）
- Builder 用 Sonnet（需要快速执行）

**Codex** — 编辑 `.codex/agentflows/config.yaml`：

```yaml
agents:
  feature-planner:
    model: "gpt-5.4"
  implementation-builder:
    model: "gpt-5.4"
```

### 12.2 修改门禁

添加或删除门禁：编辑对应的 Agent 定义文件中的「Gate Details」部分。

例如，添加 bundle size 门禁：

在 `quality-evaluator.md` 的 Gates 表中添加：

```markdown
| Bundle Size | ✅ / ❌ |
```

并实现检查逻辑。

### 12.3 修改流水线

如果你需要 4 个 task 而不是 3 个：

1. 在 `CLAUDE.md`/`AGENTS.md` 的「开发流水线」章节添加 task04
2. 在 `state.md` 的 tasks 中添加 task04 配置
3. 在 output layout 中添加对应输出文件

### 12.4 添加新的 Agent 角色

1. 在 `.claude/agentflows/agents/` 或 `.codex/agentflows/agents/` 中创建新角色定义文件
2. 在 settings.json / config.yaml 中注册
3. 在编排协议的 Handoff 模板中添加新角色的 handoff 模板

---

## 13. Claude Code vs Codex 对照表

| 操作 | Claude Code | Codex |
|------|------------|-------|
| 全流程（无参） | `/agentflow` | `/agentflow` |
| 全流程（指定） | `/agentflow:specs/x/feature-spec.md` | `/agentflow:specs/x/feature-spec.md` |
| 写需求 | `/agentflow:spec [想法\|路径]` | `/agentflow:spec [想法\|路径]` |
| 仅规划 | `/agentflow:plan specs/x/feature-spec.md` | `/agentflow:plan specs/x/feature-spec.md` |
| 从计划实现 | `/agentflow:build specs/x/implementation-plan.md` | `/agentflow:build specs/x/implementation-plan.md` |
| 仅评审 | `/agentflow:review` | `/agentflow:review` |
| 查看状态 | `cat state.md` | `cat state.md` |
| 启动仪表盘 | `./tools/open-dashboard.sh` | `./tools/open-dashboard.sh` |
| Agent 恢复机制 | Agent 工具 SendMessage | task conversation continuation |
| 配置文件 | `.claude/agentflows/settings.json` | `.codex/agentflows/config.yaml` + `hooks.json` |

---

## 附录：速查卡

### 状态 Emoji 含义

| Emoji | 含义 |
|-------|------|
| 📋 | Queued — 等待执行 |
| ✏️ | Building — 建造中 |
| 🔍 | Evaluating — 评估中 |
| 🔧 | Repairing — 修复中 |
| ✅ | Complete — 已完成 |
| ⚠️ | Complete (with warnings) — 有瑕疵但完成 |
| ❌ | Failed — 失败 |

### 目录速查

```
specs/{feature}/           ← 交付物（给你的）
specs/{feature}/_agent/    ← Agent 内部（评审报告在这）
_run/{feature}/            ← 运行时日志（调试用）
state.md                   ← 当前状态（中断恢复用）
```

### 发现问题时首先查看

1. `_agent/review-reports/task02-review.md` — 代码评审结果
2. `_run/{feature}/run-log.md` — 运行日志
3. `state.md` — 当前状态
