# agentFlow Platform Adapter - Claude Code

Protocol version: `1.0.0`

This file is the Claude Code platform adapter for agentFlow. It inherits the canonical rules in [protocol/core-spec.md](C:/Users/pleid/.codex/worktrees/4586/funds/protocol/core-spec.md). If this file conflicts with the core spec, the core spec wins.

## 1. Adapter Scope

This adapter defines only Claude-specific behavior:

- concrete path bindings
- Agent tool launch and resume rules
- concrete agent prompt locations
- runtime file locations
- Claude-specific permission and config notes

Everything else is defined in the core spec.

## 2. Path Binding

| Logical path | Claude concrete path |
|--------------|----------------------|
| `STATE_FILE` | `.claude/agentflows/state.json` |
| `SPEC_FILE` | `.claude/agentflows/specs/{feature}/feature-spec.md` |
| `OUTPUT_DIR` | `.claude/agentflows/specs/{feature}/` |
| `RUN_DIR` | `.claude/agentflows/_run/{feature}/` |
| `EVENTS_FILE` | `.claude/agentflows/_run/{feature}/events.jsonl` |
| `REVIEW_DIR` | `.claude/agentflows/specs/{feature}/_agent/review-reports/` |
| `DASHBOARD_URL` | `file://.claude/agentflows/tools/harness-dashboard.html` |

Human-readable helper files MAY exist beside the canonical JSON files, but JSON remains authoritative.

## 3. Claude Runtime Files

Persistent adapter files:

- `.claude/agentflows/settings.json`
- `.claude/agentflows/state.json`
- `.claude/agentflows/agents/*.md`
- `.claude/agentflows/skills/**/SKILL.md`

Per-run files:

- `.claude/agentflows/_run/{feature}/events.jsonl`
- `.claude/agentflows/_run/{feature}/run-log.json`
- `.claude/agentflows/specs/{feature}/_agent/plan-bundle.json`
- `.claude/agentflows/specs/{feature}/_agent/mod-bundle.json`
- `.claude/agentflows/specs/{feature}/progress-log.json`
- `.claude/agentflows/specs/{feature}/_agent/review-reports/taskXX-review.json`
- optional Markdown mirrors such as `architecture.md`, `implementation-plan.md`, `progress-log.md`, `run-log.md`, and `taskXX-review.md`

## 4. Agent Prompts

| Role | Prompt file |
|------|-------------|
| Planner | `.claude/agentflows/agents/feature-planner.md` |
| Builder | `.claude/agentflows/agents/implementation-builder.md` |
| Evaluator | `.claude/agentflows/agents/quality-evaluator.md` |

The orchestrator MUST place the role prompt before the task-specific handoff.

## 5. Agent Lifecycle

### Launch

Claude launches sub-agents via the `Agent` tool with `subagent_type: "general-purpose"`. Returned agent IDs MUST be recorded in `.claude/agentflows/state.json`.

### Resume

When a task enters repair, the orchestrator MUST use the existing agent ID and `SendMessage`-style continuation rather than creating a new instance.

### Halt

If Claude does not return an agent ID, the orchestrator MUST halt the active task and emit a `warning` event.

## 6. Claude Configuration Rules

- `.claude/agentflows/settings.json` defines the allowlist needed for planner, builder, and evaluator shell access
- local machine overrides belong in local Claude config, not in the template repository
- the template MUST NOT commit `.claude/settings.local.json` or equivalent per-user files

## 7. Artifact Contract

Canonical artifacts:

- planner output: `_agent/plan-bundle.json`
- mod output: `_agent/mod-bundle.json`
- progress tracking: `progress-log.json`
- runtime tracking: `run-log.json`
- evaluator output: `taskXX-review.json`

Optional Markdown mirrors MAY exist for human reading, but MUST NOT override the JSON artifacts.

## 8. Recovery Contract

Recovery decisions MUST be based on:

1. `.claude/agentflows/state.json`
2. the latest `events.jsonl`
3. the latest task review JSON
4. `progress-log.json` and `run-log.json` when present

Human-readable Markdown MAY help operators, but MUST NOT be the recovery source of truth.

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
