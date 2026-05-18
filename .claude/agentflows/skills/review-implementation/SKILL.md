# review-implementation

## Description

Review code changes against the plan and contract, run verification gates, and determine PASS or FAIL. This skill activates the Quality Evaluator role from the agentFlow pipeline.

## When to Use

- User says `/agentflow:review` or the orchestrator dispatches evaluation for a task
- After a Builder completes implementation
- Before merging code to main

## Workflow

### 1. Gather Context

Read the architecture, implementation plan, design contract, progress log, and the actual code files the builder modified.

### 2. Run Verification Gates

Execute lint, typecheck, and test gates. Record pass/fail/skip for each.

### 3. Plan Conformance Check

Verify every planned step has a code change, no unplanned changes exist, and each change matches the stated scope.

### 4. Security Review

Check for unsanitized user input, missing auth checks, hardcoded secrets, and unintended data exposure.

### 5. Code Quality Review

Assess naming, structure, error handling, and edge case coverage.

### 6. Write Evaluation Report

Write `{OUTPUT_DIR}/_agent/review-reports/{TASK_ID}-review.md` with gate results, strengths, specific issues (if FAIL), and PASS/FAIL judgment.

### 7. Report

Return to orchestrator: report path, judgment (PASS/FAIL), 2-sentence rationale.

## Guardrails

- READ-ONLY — never modify code or deliverables
- Specific issues only — reference exact file paths and line numbers
- All issues must include fix guidance
- If a gate tool is not configured, mark SKIP (not PASS)
