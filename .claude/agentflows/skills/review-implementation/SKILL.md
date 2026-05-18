# review-implementation

## Description

Review code changes against the approved plan and contract, run verification gates, and determine PASS or FAIL. This skill activates the Quality Evaluator role from the agentFlow pipeline.

## When to Use

- User says `/agentflow:review` or the orchestrator dispatches evaluation for a task
- After a Builder completes implementation
- Before merging code to main

## Workflow

### 1. Gather Context

Read the canonical artifacts first:

- `{OUTPUT_DIR}/_agent/plan-bundle.json`
- `{OUTPUT_DIR}/progress-log.json` when implementation was run
- `{OUTPUT_DIR}/_agent/mod-bundle.json` for `/agentflow:mod`
- the actual code files the builder modified

Use Markdown mirrors only when they help human readability.

### 2. Run Verification Gates

Execute lint, typecheck, and test gates. Record pass/fail/skip for each using canonical gate statuses.

### 3. Plan Conformance Check

Verify every planned step has a code change, no unplanned changes exist, and each change matches the stated scope.

### 4. Security Review

Check for unsanitized user input, missing auth checks, hardcoded secrets, and unintended data exposure.

### 5. Code Quality Review

Assess naming, structure, error handling, and edge case coverage.

### 6. Write Evaluation Report

Write `{OUTPUT_DIR}/_agent/review-reports/{TASK_ID}-review.json` as the authoritative report.

This file MUST conform to `protocol/schemas/review-report.schema.json`.

Optional Markdown mirror:

- `{OUTPUT_DIR}/_agent/review-reports/{TASK_ID}-review.md`

### 7. Report

Return to orchestrator: report path, judgment, and a 2-sentence rationale.

## Guardrails

- READ-ONLY - never modify code or deliverables
- Specific issues only - reference exact file paths and line numbers when applicable
- All issues must include fix guidance
- If a gate tool is not configured, use the appropriate `SKIP_*` status, not `PASS`
- Treat JSON outputs as authoritative
