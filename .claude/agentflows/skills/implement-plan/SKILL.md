# implement-plan

## Description

Implement code changes according to an architecture design and implementation plan. This skill activates the Implementation Builder role from the agentFlow pipeline.

## When to Use

- User says `/agentflow:build <plan-path>` or the orchestrator dispatches task02
- A plan has been approved and is ready for implementation
- A repair cycle requires fixing issues from a FAIL evaluation

## Workflow

### 1. Read the Plan

Read `architecture.md` and `implementation-plan.md` from the output directory. Understand each step.

### 2. Implement Step by Step

For each step in the plan, in order: read existing files, implement the change, self-check, update `progress-log.md`.

### 3. After All Steps

Verify no step was skipped, no unintended files were changed. Return list of modified file paths + 3-sentence summary.

### 4. Repair Mode

If resumed after a FAIL evaluation: read the evaluation report, focus on the "Issues" checklist, fix each issue in order, update progress log with "Repair round N".

## Guardrails

- Follow the plan exactly — no extra changes, no skipped steps
- If you discover something missing from the plan, note it in the progress log and move on
- Do NOT evaluate your own code
- Do NOT refactor unrelated code
- Match existing project conventions
