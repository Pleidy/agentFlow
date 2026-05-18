# agentFlow State

```yaml
# === Current Run ===
project: null
phase: idle
current_task: null
started_at: null
updated_at: null

# === Runtime Variables ===
spec_file: null
feature_name: null
output_dir: null
run_dir: null
dashboard_url: null

# === Agent Instances ===
instances:
  planner: null
  task01:
    builder: null
    evaluator: null
  task02:
    builder: null
    evaluator: null
  task03:
    builder: null
    evaluator: null

# === Task Status ===
tasks:
  task01:
    title: "Architecture & Design"
    status: "📋"
    builder_id: null
    evaluator_id: null
    iterations: 0
    judgment: null
    outputs: []
    report: null
  task02:
    title: "Implementation"
    status: "📋"
    builder_id: null
    evaluator_id: null
    iterations: 0
    judgment: null
    outputs: []
    report: null
  task03:
    title: "Verification & Delivery"
    status: "📋"
    builder_id: null
    evaluator_id: null
    iterations: 0
    judgment: null
    outputs: []
    report: null

# === Discipline ===
discipline:
  orchestrator_reads_deliverables: false
  orchestrator_reads_full_reports: false
  handoffs_use_paths_only: true
  evaluator_is_readonly: true
  repair_resumes_same_agent: true
```
