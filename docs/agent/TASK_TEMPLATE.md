# Task File Template
# Copy this file, rename it to describe the task, fill in all sections.
# Delete these instruction comments before saving.
# Place in docs/agent/tasks/backlog/, critical/, or active/ as appropriate.
#
# FILENAME CONVENTION — mandatory for all task files:
#   YYYY-MM-DD-PRIORITY-TYPE-DESCRIPTIVE-NAME.md
#
#   YYYY-MM-DD  = date the task was created (not assigned, not completed)
#   PRIORITY    = CRITICAL | HIGH | MEDIUM | LOW
#   TYPE        = bug-fix | feature | refactor | architecture | data | documentation
#   NAME        = kebab-case, descriptive, no spaces
#
#   Examples:
#     2026-03-29-HIGH-REFACTOR-WORMHOLE-EXPANSION-SERVICE.md
#     2026-03-27-MEDIUM-FEATURE-FINANCIAL-TRANSACTION-MODEL.md
#     2026-03-30-LOW-DOCUMENTATION-BACKLOG-AUDIT-AND-RENAME.md
#
#   Why this matters:
#     - Date = recency signal. Stale tasks predate architecture decisions.
#     - Priority = triage at a glance without opening the file.
#     - No date prefix = task must be reviewed before assignment, may be obsolete.
#
# ⚠️ Files without this convention will not be assigned until renamed and reviewed.
#
# DEPTH GUIDE — how much detail to include per agent tier:
#   0x  (GPT-4.1)         — fill every field, no ambiguity, explicit paths and commands
#   0.25x (Grok)          — fill every field, commands can be slightly abbreviated
#   0.33x (Gemini Flash)  — most fields required, can handle some inference
#   1x  (Claude Sonnet)   — core fields required, can reason about gaps
#   3x  (Claude Opus)     — reserve for hardest problems, lean task file is fine
#
# Rule: when in doubt, add more detail. A over-specified task wastes nothing.
# An under-specified task burns premium requests on clarification.

---

# TASK: [Short descriptive title]
**Status**: BACKLOG | ACTIVE | BLOCKED | COMPLETED  
**Priority**: CRITICAL | HIGH | MEDIUM | LOW  
**Type**: bug-fix | feature | refactor | architecture | data | documentation  
**Created**: YYYY-MM-DD  
**Last Updated**: YYYY-MM-DD  

---

## Agent Assignment

**Assigned To**: [GPT-4.1 0x | Grok 0.25x | Gemini Flash 0.33x | Claude Sonnet 1x | Local Ollama]  
**Why This Agent**: [one line — e.g. "straightforward spec fix, fully self-contained" or "requires architectural reasoning"]  
**Supervision Level**: [watched carefully | standard | autonomous OK]  

**Supervision Legend**:
- 🔴 Watched carefully = 0x/0.25x agents
- 🟡 Standard = 0.33x agents  
- 🟢 Autonomous OK = 1x agents

> ⚠️ 0x and 0.25x agents: read every section carefully before starting.
> Do not infer file paths or method names — they are provided explicitly below.

---

## Context
[2-4 sentences explaining what this part of the system does and why this task exists.
For 0x agents: be explicit. For 1x agents: high-level is fine.]

**Relevant Architecture Docs** — read before starting:
- `docs/[path]/[file].md` — [one line on what it covers]
- `docs/[path]/[file].md` — [one line on what it covers]

> If a doc doesn't exist for this area, do not create one during this task.
> Flag the gap in your completion report instead.

---

## Problem Statement
[Exact description of what is wrong or missing. For bug fixes: include the error
message verbatim. For features: describe the missing behavior precisely.]

**Error output** (if applicable):
```
[paste exact error here]
```

**Current behavior**: [what happens now]  
**Expected behavior**: [what should happen]  

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `app/models/[file].rb` | [what it does] | `#method_name` line ~N |
| `app/services/[file].rb` | [what it does] | `#method_name` line ~N |
| `spec/[path]/[file]_spec.rb` | [what it tests] | line ~N |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `spec/factories/[file].rb` | [e.g. factory structure for this model] |
| `app/data/json-data/[path]/[file].json` | [e.g. operational data structure] |

### Migration (if needed)
- [ ] No migration needed
- [ ] Migration needed: `[describe the schema change]`
  ```bash
  docker exec -it web bash -c 'bundle exec rails generate migration [MigrationName]'
  ```

---

## Implementation Steps

> 1x agents: use as a guide, apply judgment.

> 0x/0.25x agents: follow these steps exactly in order.
> 1x agents: use as a guide, apply judgment.

**Debug prints OK for complex callbacks** — add temporary `puts` statements to trace data flow, remove after verification. Flag in completion report.

### Step 1 — [action]
[Exact description of what to do]

```ruby
# [before — current code]
def example_method
  old_code
end

# [after — proposed change]
def example_method
  new_code
end
```

### Step 2 — [action]
[Exact description]

### Step 3 — Verify
DO NOT INFER THE COMMAND. Run this exact string from the host terminal:

Bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec [SPEC_PATH_IN_CONTAINER]'
Expected result: X examples, 0 failures

```
THE FAILURE
Spec: [file:line]
Error: [exact message]
Expected: [value]
Got: [value]

ROOT CAUSE
[one paragraph]

PROPOSED FIX
[exact code change]

RISK
[any shared code affected]

READY TO APPLY? — waiting for approval
```

Do not apply the fix until the user explicitly approves.

---

---

## Acceptance Criteria
- [ ] [specific measurable outcome]
- [ ] [specific measurable outcome]
- [ ] Isolation run: 0 failures
- [ ] No regressions in related specs
- [ ] Full suite run completed and logged

---

## Stop Conditions — escalate to user immediately if:
- Fix causes new failures in specs you did not touch
- Same failure persists after two attempts — report exact error, do not attempt a third fix
- Root cause is in a shared concern, base class, or factory used across many specs
- A database migration is needed that wasn't anticipated
- Any architectural decision is required

---

## Commit Instructions
Run git commands on **host**, not inside container:
```bash
git add [specific files only — never git add .]
git commit -m "[type]: [spec/file name] — [brief description of root cause and fix]"
git push
```

Example good commit message:
`fix: solar_system_spec — use read_attribute in generate_unique_name guard clause`

Example bad commit message:
`fix tests`

---

## Documentation
- [ ] No doc changes needed
- [ ] Update `docs/[path]/[file].md` — [what to update]
- [ ] Flag doc gap: [description] — do not create the doc, add to backlog instead

---

## Dependencies
**Blocked by**: [task file name or "none"]  
**Blocks**: [task file name or "none"]  
**Related tasks**: [task file name or "none"]  

---

## Completion Report
*Filled in by the implementing agent after completion*

**Completed by**: [agent name]  
**Completion date**: YYYY-MM-DD  
**Final test result**: X examples, Y failures  

### What was changed
- `[file]` — [description of change]
- `[file]` — [description of change]

### Issues discovered
[Any problems found during implementation that weren't in the original task]

### Follow-up tasks needed
[Any new backlog items identified — do not create the files, just list them here]

### Lessons learned
[What worked, what didn't, what future tasks in this area should know]
