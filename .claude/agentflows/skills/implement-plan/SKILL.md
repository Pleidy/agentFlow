# implement-plan

## Description

Implement code changes according to the approved planning bundle. This skill activates the Implementation Builder role from the agentFlow pipeline.

## When to Use

- User says `/agentflow:build <plan-path>` or the orchestrator dispatches task02
- A plan has been approved and is ready for implementation
- A repair cycle requires fixing issues from a FAIL evaluation

## Workflow

### 1. Read the Plan

Read `{OUTPUT_DIR}/_agent/plan-bundle.json` first. If Markdown mirrors exist, use them only as convenience views.

### 2. Implement Step by Step

For each implementation step in order:

- read the relevant existing files
- implement the change
- self-check the result
- update `progress-log.json`

Optional `progress-log.md` may be updated as a human mirror.

### 3. After All Steps

Verify that no step was skipped and no unintended files were changed. Return the list of modified file paths and a 3-sentence summary.

### 4. Repair Mode

If resumed after a FAIL evaluation:

- read `{OUTPUT_DIR}/_agent/review-reports/{TASK_ID}-review.json`
- focus on open issues by stable `issue_id`
- fix each issue in order
- update the progress log with a repair round entry

## Guardrails

- Follow the plan exactly - no extra changes, no skipped steps
- If you discover something missing from the plan, note it in the progress log and move on
- Do NOT evaluate your own code
- Do NOT refactor unrelated code
- Match existing project conventions
- Treat JSON artifacts as authoritative
