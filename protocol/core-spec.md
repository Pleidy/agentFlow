# agentFlow Core Specification

Version: `1.0.0`

This document is the canonical, platform-neutral protocol for agentFlow. Claude Code and Codex adapters MUST inherit this spec and MUST NOT weaken any `MUST` or `MUST NOT` rule defined here.

## 1. Normative Language

- `MUST`: required for protocol compliance.
- `MUST NOT`: prohibited for protocol compliance.
- `SHOULD`: strong default unless a documented project-specific reason exists.
- `MAY`: optional behavior.

## 2. Execution Model

agentFlow turns a requirement into code through a bounded multi-agent pipeline:

1. `task01` — plan
2. `task02` — implement
3. `task03` — verify and deliver

The orchestrator manages the pipeline. Specialist agents produce and inspect outputs. All coordination MUST be observable through files and events.

### Roles

| Role | Responsibility | Hard boundary |
|------|----------------|---------------|
| Orchestrator | Resolve commands, route work, maintain state, decide next step | MUST NOT write deliverable code |
| Feature Planner | Convert spec into architecture and implementation plan | MUST NOT write production code |
| Implementation Builder | Implement planned changes and perform repairs | MUST NOT self-approve |
| Quality Evaluator | Run gates, review outputs, emit judgment and issues | MUST NOT modify deliverables |

## 3. Logical Paths

Platform adapters MUST bind these logical paths to concrete filesystem paths.

| Variable | Meaning |
|----------|---------|
| `SPEC_FILE` | User-selected feature spec |
| `FEATURE_NAME` | Slug derived from the spec directory |
| `STATE_FILE` | Current machine-readable state snapshot |
| `OUTPUT_DIR` | Deliverable root for the current feature |
| `RUN_DIR` | Runtime log directory for the current feature |
| `EVENTS_FILE` | Structured JSONL event stream |
| `REVIEW_DIR` | Review artifact directory under `_agent/review-reports/` |

Adapters MUST expose concrete paths for both persistent template files and per-run files.

## 4. Commands and Modes

The protocol defines these user-facing modes:

| Trigger | Mode | Contract |
|---------|------|----------|
| `/agentflow` | full pipeline | select spec, run task01 → task02 → task03 |
| `/agentflow <spec-path>` | full pipeline | run task01 → task02 → task03 for the given spec |
| `/agentflow:spec [idea-or-path]` | spec authoring | create or refine a feature spec |
| `/agentflow:plan <spec-path>` | plan only | run task01 only |
| `/agentflow:build <plan-path>` | build only | run task02 only from an approved plan |
| `/agentflow:review` | review only | run evaluator gates on current changes |
| `/agentflow:mod [description\|--full]` | lightweight modification | clarify, implement, evaluate without full planning |

Platform adapters MAY add helper commands, but MUST NOT change the meaning of these commands.

## 5. Phase Contract

### Phase 0: Initialize

The orchestrator MUST:

1. Resolve the target spec or plan path.
2. Bind logical paths.
3. Create missing run directories.
4. Write `STATE_FILE` using the canonical state schema.
5. Append a `project_started` event to `EVENTS_FILE`.
6. Load recent lessons if the platform supports lessons.

### task01: Plan

The planner MUST produce a canonical JSON bundle:

- `_agent/plan-bundle.json`

Optional Markdown mirrors MAY also be produced:

- `architecture.md`
- `implementation-plan.md`
- `_agent/design-contract.md`

Minimum contract:

- `plan-bundle.json` MUST conform to `protocol/schemas/plan-bundle.schema.json`
- the architecture section MUST define components, data flow, integration points, technical decisions, and explicit risks
- the implementation plan section MUST define ordered steps, target files, change scope, and dependencies
- the design contract section MUST define acceptance criteria, explicit exclusions, and assumptions

`task01` MUST block `task02` when the evaluator judgment is `FAIL` or `UNRESOLVED`.

### task02: Implement

The builder MUST:

- follow the approved plan in order
- update a canonical JSON progress log
- scope changes to planned files unless a repair explicitly requires otherwise

The evaluator MUST run configured gates and compare code against plan and contract.

### task03: Verify and Deliver

The builder MUST produce:

- `test-report.md`
- `pr-document.md`

The evaluator MUST verify that delivery artifacts match the approved contract and current code changes.

### `/agentflow:mod`

This path MAY skip task01 when the change is bounded to 1-3 files and does not require architecture work. If the scope expands beyond that bound, the orchestrator SHOULD redirect to `/agentflow:plan`.

The mod builder MUST produce a canonical JSON bundle:

- `_agent/mod-bundle.json`

When `/agentflow:mod --full` is used, the runtime MUST also maintain canonical JSON logs:

- `progress-log.json`
- `run-log.json`

Optional Markdown mirrors MAY also be produced:

- `_run/{feature}/mod-review.md`
- `progress-log.md`
- `run-log.md`

## 6. Hard Protocol Rules

1. The orchestrator `MUST NOT` write deliverable code.
2. Handoffs `MUST` pass paths and identifiers, not pasted deliverable contents.
3. Evaluators `MUST NOT` modify deliverables.
4. Planner, Builder, and Evaluator outputs `MUST` be file-backed.
5. Repair loops `MUST` resume the same Builder and Evaluator instance for the current task when the platform supports resumption.
6. New tasks `MUST` use new Builder and Evaluator instances.
7. Missing agent identifiers `MUST` halt the active task.
8. Review findings `MUST` use stable issue IDs.
9. Gate results `MUST` use canonical statuses.
10. Runtime state `MUST` be machine-readable JSON and conform to `protocol/schemas/state.schema.json`.
11. Events `MUST` conform to `protocol/schemas/event.schema.json`.
12. Review reports `MUST` conform to `protocol/schemas/review-report.schema.json`.
13. Planner bundles `MUST` conform to `protocol/schemas/plan-bundle.schema.json`.
14. Mod bundles `MUST` conform to `protocol/schemas/mod-bundle.schema.json`.
15. Run logs `MUST` conform to `protocol/schemas/run-log.schema.json`.
16. Progress logs `MUST` conform to `protocol/schemas/progress-log.schema.json`.

## 7. Gate Semantics

Canonical gate statuses:

- `PASS`
- `FAIL`
- `SKIP_NOT_CONFIGURED`
- `SKIP_TOOL_MISSING`
- `SKIP_NOT_APPLICABLE`

Evaluators MUST distinguish the three `SKIP_*` cases. Plain `SKIP` is not protocol compliant.

## 8. Review Report Contract

Every evaluator report MUST include:

- protocol version
- task id and title
- evaluation round
- judgment
- continuation decision
- gate results
- stable issues
- strengths
- rationale

Stable issue IDs MUST follow `ISSUE-001`, `ISSUE-002`, and so on within a task. Once issued, an issue ID MUST stay attached to the same underlying problem across repair rounds until it is closed.

Issue lifecycle:

- `open`: issue still blocks acceptance
- `closed`: issue was fixed
- `carried_forward`: old issue remains unresolved
- `new`: newly discovered in this round

## 9. Failure Classes

Evaluators and orchestrators SHOULD classify failures using:

- `PLAN_INVALID`
- `BUILD_FAILED`
- `GATE_FAILED`
- `EVALUATION_FAILED`
- `RECOVERY_FAILED`
- `UNRESOLVED_AFTER_MAX_REPAIRS`

Continuation policy:

- `task01 FAIL` → MUST halt downstream execution
- `task02 FAIL` after max repairs → MAY continue only as `UNRESOLVED`, and task03 MUST NOT claim full success
- `task03 FAIL` → MUST report incomplete delivery

## 10. Runtime Files

### Required machine-readable files

- `STATE_FILE`
- `EVENTS_FILE`
- `_agent/plan-bundle.json`
- `_agent/mod-bundle.json` for `/agentflow:mod`
- `progress-log.json`
- `run-log.json`
- `taskXX-review.json`

### Optional human-readable mirrors

- `architecture.md`
- `implementation-plan.md`
- `_agent/design-contract.md`
- `progress-log.md`
- `run-log.md`
- `_run/{feature}/mod-review.md`
- `taskXX-review.md`

Human-readable mirrors MAY exist, but JSON artifacts are authoritative.

## 11. Template Boundary

Template files are committed scaffolding:

- protocol docs and schemas
- agent prompts
- config files
- empty runtime directories with `.gitkeep`
- durable lessons seeds

Runtime files are generated during execution and SHOULD be ignored in business projects:

- per-run event logs
- per-run review JSON
- per-run state snapshots outside the template baseline
- local IDE or CLI overrides

Local machine settings `MUST NOT` be committed in the template repository.
