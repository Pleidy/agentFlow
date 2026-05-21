# modify-feature

## Description

Execute a lightweight modification flow — clarify a rough change description, implement the fix, and run quality gates. No spec, no architecture planning. For bug fixes, small tweaks, and iterations on existing features.

## When to Use

- User says `/agentflow:mod` (no argument) — infer what to change from context
- User says `/agentflow:mod "description"` — clarify description then implement
- User says `/agentflow:mod --full "description"` — same, plus progress-log and review-report
- Changes span 1-3 files, no new architecture needed

---

## Behavioral Principles

`/agentflow:mod` has no spec and no plan — these principles are the only guardrails.

### Think Before Coding
- If the change description is vague, ask one focused question at a time. Do not guess.
- State your understanding before implementing: "I understand the change as: {summary}. Correct?"

### Simplicity First
- Minimum code to fix the problem. No "while I'm here" improvements.
- If the fix requires more than the user described, stop and confirm before expanding scope.

### Surgical Changes
- Touch only the files and functions directly related to the change.
- Do not refactor, reformat, or "clean up" adjacent code.
- Remove only imports/variables YOUR change made unused.
- Test: every changed line must trace directly to the user's description.

### Goal-Driven
- If the change is a bug fix: write a test that reproduces the bug first.
- If the change is a feature tweak: define the expected behavior before coding.

## Flow

### Step 1: Understand the Change

Receive the user's description. If it's vague, ask focused questions — one at a time — to reach clarity:

- **What** to change: exact behavior being modified
- **Where** to change: locate to file/function level
- **How** to change: expected behavior after the fix

This is NOT the 7-dimension onion peeling of `/agentflow:spec`. Stop when the change is clear enough to implement. Three focused questions maximum before asking "是否足够清晰，可以开始改代码？"

### Step 2: Implement

Launch Builder via `Agent` tool:
```
subagent_type: "general-purpose"
description: "Modify: {brief change description}"
prompt: [读取 .claude/agentflows/agents/implementation-builder.md]
        + "\n\n## Task: Modify Feature\n\n"
        + "Change description: {clarified description}\n"
        + "Files to modify: {located file paths}\n"
        + "\nImplement the change. Return modified file paths and a brief summary."
```

### Step 3: Run Gates

Launch Evaluator:
```
subagent_type: "general-purpose"
description: "Evaluate modification"
prompt: [读取 .claude/agentflows/agents/quality-evaluator.md]
        + "\n\n## Task: Review Modification\n\n"
        + "Review the recent code changes. Run lint, typecheck, test.\n"
        + "Determine PASS or FAIL."
```

If FAIL → resume same Builder for repair (max 2 rounds).

### Step 4: Report

- Default mode: report modified files + gate results
- `--full` mode: also write `_run/{feature}/mod-review.md` + update progress-log

---

## Guardrails

- Do NOT initiate spec writing or architecture planning
- Do NOT ask the 7-dimension questions — stick to what/where/how
- If the change scope grows beyond 3 files, suggest `/agentflow:plan` instead
- One question per round, max 3 clarification rounds before implementing
