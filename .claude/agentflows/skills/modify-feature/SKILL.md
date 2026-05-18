# modify-feature

## Description

Execute a lightweight modification flow - clarify a rough change description, implement the fix, and run quality gates. No spec, no architecture planning. Use this for bug fixes, small tweaks, and bounded iterations on existing features.

## When to Use

- User says `/agentflow:mod` with or without a description
- User says `/agentflow:mod --full "description"`
- Changes span 1-3 files and do not need new architecture

## Flow

### Step 1: Understand the Change

Receive the user's description. If it is vague, ask focused questions one at a time to reach clarity:

- **What** to change
- **Where** to change
- **How** the behavior should work afterward

This is not the 7-dimension spec-writing workflow. Stop when the change is clear enough to implement. Maximum 3 clarification rounds.

### Step 2: Implement

Launch the Builder and require it to produce:

- `{OUTPUT_DIR}/_agent/mod-bundle.json`

This file MUST conform to `protocol/schemas/mod-bundle.schema.json`.

### Step 3: Run Gates

Launch the Evaluator to review the recent code changes and write the canonical JSON review report.

If FAIL, resume the same Builder for repair for at most 2 rounds.

### Step 4: Full Mode Logs

If `--full` is active, also update:

- `{OUTPUT_DIR}/progress-log.json`
- `{RUN_DIR}/run-log.json`

Optional Markdown mirrors MAY also exist:

- `{OUTPUT_DIR}/progress-log.md`
- `{RUN_DIR}/mod-review.md`
- `{RUN_DIR}/run-log.md`

### Step 5: Report

- Default mode: report modified files and gate results
- `--full` mode: report modified files, gate results, and JSON artifact paths

## Guardrails

- Do NOT initiate spec writing or architecture planning
- Do NOT ask the 7-dimension questions - stick to what/where/how
- If the change scope grows beyond 3 files, redirect to `/agentflow:plan`
- One question per round, max 3 clarification rounds before implementing
- Treat JSON artifacts as authoritative
