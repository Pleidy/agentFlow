# plan-feature

## Description

Analyze a feature specification and produce a schema-backed planning bundle. This skill activates the Feature Planner role from the agentFlow pipeline.

## When to Use

- User says `/agentflow:plan <spec-path>` or `/agentflow <spec-path>`
- User asks for architecture design or implementation planning
- A new feature spec has been written and needs a plan

## Workflow

### 1. Read the Spec

Read the feature spec file at the path provided. Understand what is being asked, what constraints are stated, and what acceptance criteria are defined.

### 2. Explore the Codebase

Read relevant existing files near the change area. Note existing patterns such as naming, structure, error handling, and testing. Identify integration points.

### 3. Write the Canonical Plan Bundle

Write `{OUTPUT_DIR}/_agent/plan-bundle.json` as the authoritative planning artifact.

This file MUST conform to `protocol/schemas/plan-bundle.schema.json`.

### 4. Optional Mirrors

If helpful for human review, also write:

- `{OUTPUT_DIR}/architecture.md`
- `{OUTPUT_DIR}/implementation-plan.md`
- `{OUTPUT_DIR}/_agent/design-contract.md`

These are mirrors only. The JSON bundle is the source of truth.

### 5. Bundle Requirements

Ensure the bundle includes:

- architecture with components, data flow, risks, and technical decisions
- ordered implementation steps with stable IDs like `STEP-001`
- per-step file path, change type, scope, dependencies, and complexity
- design contract with acceptance criteria, explicit exclusions, and assumptions

### 6. Report

Return to the orchestrator: the canonical bundle path, any mirror paths, a 3-sentence summary, and confidence level.

## Guardrails

- Do NOT write implementation code
- Do NOT infer requirements not in the spec
- Do NOT propose changes without explaining why
- Do NOT omit the explicit exclusions section
- Do NOT treat Markdown mirrors as authoritative
