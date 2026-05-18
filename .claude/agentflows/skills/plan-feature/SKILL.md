# plan-feature

## Description

Analyze a feature specification and produce an architecture design, implementation plan, and design contract. This skill activates the Feature Planner role from the agentFlow pipeline.

## When to Use

- User says `/agentflow:plan <spec-path>` or `/agentflow <spec-path>`
- User asks for architecture design or implementation planning
- A new feature spec has been written and needs a plan

## Workflow

### 1. Read the Spec

Read the feature spec file at the path provided. Understand what is being asked, what constraints are stated, and what acceptance criteria are defined.

### 2. Explore the Codebase

Read relevant existing files near the change area. Note existing patterns (naming, structure, error handling, testing). Identify integration points.

### 3. Design Architecture

Write `{OUTPUT_DIR}/architecture.md` with component/module diagram, data flow, key technical decisions with justification, risks and tradeoffs, and integration points.

### 4. Plan Implementation

Write `{OUTPUT_DIR}/implementation-plan.md` with ordered steps in dependency order, per-step file path, change type, scope, dependencies, and complexity.

### 5. Write Design Contract

Write `{OUTPUT_DIR}/_agent/design-contract.md` with verifiable acceptance criteria, explicit exclusions, and stated assumptions.

### 6. Report

Return to the orchestrator: paths of the three output files, a 3-sentence summary, and confidence level.

## Guardrails

- Do NOT write implementation code
- Do NOT infer requirements not in the spec
- Do NOT propose changes without explaining why
- Do NOT skip the "explicit exclusions" section in the contract
