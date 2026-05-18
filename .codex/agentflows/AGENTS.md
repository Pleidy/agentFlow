# agentFlow Platform Adapter — Codex

Protocol version: `1.0.0`

This file is the Codex platform adapter for agentFlow. It inherits the canonical rules in [protocol/core-spec.md](C:/Users/pleid/.codex/worktrees/4586/funds/protocol/core-spec.md). If this file conflicts with the core spec, the core spec wins.

## 1. Adapter Scope

This adapter defines only Codex-specific behavior:

- concrete path bindings
- agent prompt locations
- agent launch and resume mechanics
- config and hooks file locations
- runtime file locations

All task semantics, hard rules, gate semantics, failure classes, and review contracts come from the core spec.

## 2. Path Binding

| Logical path | Codex concrete path |
|--------------|---------------------|
| `STATE_FILE` | `.codex/agentflows/state.json` |
| `SPEC_FILE` | `.codex/agentflows/specs/{feature}/feature-spec.md` |
| `OUTPUT_DIR` | `.codex/agentflows/specs/{feature}/` |
| `RUN_DIR` | `.codex/agentflows/_run/{feature}/` |
| `EVENTS_FILE` | `.codex/agentflows/_run/{feature}/events.jsonl` |
| `REVIEW_DIR` | `.codex/agentflows/specs/{feature}/_agent/review-reports/` |
| `DASHBOARD_URL` | `file://.codex/agentflows/tools/harness-dashboard.html` |

Human-readable helper files MAY exist beside the canonical JSON files, but JSON remains authoritative.

## 3. Codex Runtime Files

Persistent adapter files:

- `.codex/agentflows/config.yaml`
- `.codex/agentflows/hooks.json`
- `.codex/agentflows/state.json`
- `.codex/agentflows/agents/*.md`

Per-run files:

- `.codex/agentflows/_run/{feature}/events.jsonl`
- `.codex/agentflows/_run/{feature}/run-log.md`
- `.codex/agentflows/specs/{feature}/_agent/review-reports/taskXX-review.json`
- optional `.md` mirrors for review readability

## 4. Agent Prompts

| Role | Prompt file |
|------|-------------|
| Planner | `.codex/agentflows/agents/feature-planner.md` |
| Builder | `.codex/agentflows/agents/implementation-builder.md` |
| Evaluator | `.codex/agentflows/agents/quality-evaluator.md` |
| Mod Builder | `.codex/agentflows/agents/mod-builder.md` |
| Spec Writer | `.codex/agentflows/agents/spec-writer.md` |

The orchestrator MUST prepend the role prompt and append the task-specific handoff.

## 5. Agent Lifecycle

### Launch

Codex launches planner, builder, and evaluator as child agents/subtasks. The orchestrator MUST record agent IDs in `.codex/agentflows/state.json`.

### Resume

When a task enters repair:

- the builder MUST be resumed, not replaced
- the evaluator MUST be resumed, not replaced, when the platform supports evaluator continuity
- the active review report path and open issue IDs MUST be passed back in

### Halt

If Codex does not return an agent/subtask ID, the orchestrator MUST halt the task and emit a `warning` event.

## 6. Codex Configuration Rules

- `.codex/agentflows/config.yaml` is the canonical place for configured lint/typecheck/test commands.
- Empty command strings mean `SKIP_NOT_CONFIGURED`.
- `.codex/agentflows/hooks.json` MAY define automation hooks, but empty hooks are the safe default.
- Platform adapters MUST NOT ship hard-coded technology-specific gate commands as active defaults.

## 7. Review Contract

Codex evaluators MUST write canonical JSON reports using the review report schema:

- `task01-review.json`
- `task02-review.json`
- `task03-review.json`

Optional Markdown mirrors MAY be written for human reading:

- `task01-review.md`
- `task02-review.md`
- `task03-review.md`

If both exist, the JSON file is authoritative.

## 8. Recovery Contract

Recovery decisions MUST be based on:

1. `.codex/agentflows/state.json`
2. the latest `events.jsonl`
3. the latest task review JSON

Recovery SHOULD NOT depend on parsing human-readable Markdown.

## 9. Quick Reference

```text
/agentflow
/agentflow <spec-path>
/agentflow:spec [idea-or-path]
/agentflow:mod [description|--full]
/agentflow:plan <spec-path>
/agentflow:build <plan-path>
/agentflow:review
```
