# write-spec

## Description

Help the user write a high-quality feature specification through systematic "onion peeling" — progressively deepening each dimension until the smallest actionable detail is reached.

Supports two modes:
1. **Interactive build**: Start from a brief idea, peel each dimension layer by layer
2. **Review & improve**: Review an existing spec against the five criteria and suggest concrete improvements

## When to Use

- User says `/agentflow:spec` (no argument) — enter interactive build mode
- User says `/agentflow:spec <brief idea>` — build spec from a short description
- User says `/agentflow:spec <spec-path>` — review and improve an existing spec

---

## Core Principle: Onion Peeling

Do NOT ask broad, surface-level questions. For each dimension, peel layer by layer until the answer is **atomically small** — a single, unambiguous, verifiable unit of information that cannot be further decomposed.

```
表面: "我要一个导出功能"
  ↓ 剥一层: "导出什么？" → "基金数据"
  ↓ 再剥: "哪些字段？" → "代码、名称、净值、涨跌幅"
  ↓ 再剥: "净值是实时还是昨日？" → "昨日收盘净值"
  ↓ 再剥: "涨跌幅是日涨幅还是持仓盈亏？" → "日涨跌幅百分比"
  ↓ 再剥: "百分比格式？" → "保留两位小数，正数带+号"
  ↓ 到达最小颗粒 → "这个维度还有其他需要确认的吗？"
```

At each layer, ask exactly **one** focused follow-up question. Do not jump to another dimension until:
- The current answer is atomic (cannot be further split), AND
- The user confirms no more depth is needed on this thread

---

## Seven Dimensions

Peel each dimension fully before moving to the next. Track completion status.

### 1. 用户与场景 (Users & Scenarios)

Peel until you know:
- Who exactly is the user? (role, not "用户" — be specific)
- What triggers them to use this feature? (the exact moment)
- What does success look like from their perspective?
- Are there multiple user roles? How do their needs differ?

### 2. 功能边界 (Scope Boundaries)

Peel until you know:
- What exactly is the feature? (in one sentence a developer could code from)
- What is the first thing it must do? The last?
- Where does it start and end? (the exact entry point and exit point)
- What touches it but is NOT part of it?

### 3. 数据与状态 (Data & State)

Peel until you know:
- What data comes in? (every field, type, source, validation rule)
- What data goes out? (every field, type, format, destination)
- What states exist? (loading, empty, error, edge cases — enumerate all)
- What persists? What is transient?

### 4. 交互与流程 (Interaction & Flow)

Peel until you know:
- What is the step-by-step user flow? (each click, input, response)
- What feedback does the user get at each step?
- What happens when something goes wrong at each step?
- What is the happy path? The 3 most common error paths?

### 5. 约束与限制 (Constraints & Limits)

Peel until you know:
- Performance: exact numbers (not "fast" — "<200ms")
- Compatibility: exact platforms/browsers/versions
- Dependencies: what can/cannot be used
- Scale: how many users/items/requests?

### 6. 验收标准 (Acceptance Criteria)

Peel until every criterion is:
- Verifiable by a machine or a stranger (yes/no, pass/fail)
- Specific enough to write a test case from
- Covers happy path + at least 2 edge cases per user story

### 7. 非目标 (Exclusions)

Peel until you have:
- At least 3 things explicitly NOT in scope
- Each with a reason WHY they're excluded
- A clear statement of what "done for now" means vs "future"

---

## Mode A: Interactive Build (Onion Peeling)

### A0: Initialize Tracking

Before starting, create an internal tracking table:

```
| Dimension | Status | Depth Reached | User Confirmed |
|-----------|--------|---------------|----------------|
| 1. 用户与场景  | ⏳     | —             | —              |
| 2. 功能边界    | ⬜     | —             | —              |
| 3. 数据与状态  | ⬜     | —             | —              |
| 4. 交互与流程  | ⬜     | —             | —              |
| 5. 约束与限制  | ⬜     | —             | —              |
| 6. 验收标准    | ⬜     | —             | —              |
| 7. 非目标      | ⬜     | —             | —              |
```

### A1: Start with Dimension 1

Begin peeling from dimension 1. Ask the first question. After each answer:

1. Assess: is the answer atomic? Can it be further decomposed?
2. If decomposable → ask the next layer question
3. If atomic → ask: **"这个方向还有需要细化的吗？"**
4. If user says yes → continue peeling same dimension
5. If user says no → mark dimension as ✅, show tracking table, move to next dimension

### A2: Navigate Dimensions

After completing a dimension, present the tracking table and ask:

```
## 当前进度

| 维度 | 状态 |
|------|------|
| 1. 用户与场景  | ✅ 已确认 |
| 2. 功能边界    | ⏳ 进行中 |
| 3-7            | ⬜ 待处理 |

是否继续维度 2「功能边界」，还是你想跳到其他维度？
```

Always let the user choose: continue the natural order, or jump to a specific dimension.

### A3: Loop Until All Confirmed

Repeat A1-A2 until all 7 dimensions are marked ✅. Only then proceed to A4.

### A4: Generate Spec

Once all dimensions are confirmed, compile everything into the spec:

```markdown
# Feature: {name}

## 概述
{synthesized from all dimensions}

## 动机
{from dimension 1 — user pain point / trigger}

## 用户故事
{from dimension 1 — each user role with specific scenario}

## 验收标准
{from dimension 6 — every criterion must be verifiable}

## 约束
{from dimension 5 — every constraint with exact numbers}

## 非目标
{from dimension 7 — each with reason}

## 参考
{any mentioned docs, APIs, designs}
```

Write to `specs/{feature-name}/feature-spec.md`.

### A5: Final Self-Check

Before presenting, verify all five criteria:
- Bounded? (dimension 2 covered this)
- Purposeful? (dimension 1 covered this)
- Actionable? (dimensions 3+4 covered this)
- Verifiable? (dimension 6 covered this)
- Has outlet? (dimension 7 clarified what "done" means)

If any criterion is WEAK or MISSING, go back to the corresponding dimension and peel further.

---

## Mode B: Review & Improve

Use when the user provides a path to an existing spec file.

### B1: Read & Score

Score each of the seven dimensions on a 3-point scale:
- PASS — sufficient detail, atomic level reached
- WEAK — surface level, needs more peeling
- MISSING — not addressed at all

### B2: Report Findings

```markdown
## Spec Review: {path}

| # | Dimension | Score | Weakest Point |
|---|-----------|-------|---------------|
| 1 | 用户与场景  | PASS  | — |
| 2 | 功能边界    | WEAK  | "导出功能" — 未指定格式、字段、触发方式 |
| 3 | 数据与状态  | MISSING | 完全没有涉及 |
| ... | ... | ... | ... |
```

### B3: Peel Weak Dimensions

For each WEAK or MISSING dimension, enter onion-peeling mode. Ask focused questions to reach atomic detail.

### B4: Apply Improvements

After all weak dimensions are strengthened, write the improved spec.

---

## Guardrails

- **One question at a time.** Never ask multiple questions in one round.
- **Never accept vague answers.** "差不多", "大概", "看着办" → push back with a concrete counter-proposal.
- **Always show progress.** After each dimension completes, show the tracking table.
- **User controls pace.** If the user wants to skip a dimension, mark it ⚠️ and move on. Come back at the end.
- **No spec until all ✅.** The spec file is only written when every dimension is confirmed (or explicitly skipped).
- **The spec is the user's words, not yours.** You synthesize and structure, but never invent requirements the user didn't state.
