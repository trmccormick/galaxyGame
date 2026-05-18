# Task File Template
# Copy this file, rename it to describe the task, fill in all sections.
# Delete these instruction comments before saving.
# Place in docs/new_agent/tasks/backlog/ or active/ as appropriate.
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
# DEPTH GUIDE — how much detail to include per agent tier:
#   0x  (GPT-4.1)              — fill every field, no ambiguity, explicit paths and commands
#   0.33x (Haiku/Gemini Flash) — most fields required, can handle some inference
#   1x  (Claude Sonnet)        — core fields required, can reason about gaps
#   Local (Ollama via Continue) — must have exact file content provided, cannot execute commands
#
# Rule: when in doubt, add more detail. An over-specified task wastes nothing.
# An under-specified task burns premium requests on clarification.

---
status: backlog
priority: HIGH
type: bug-fix
system_domain: AI_MANAGER | MANUFACTURING | TERRA_SIM | CONTROLLERS | UNITS | OTHER
mvp_alignment: AI_MANAGER_LUNA_SETTLEMENT | ISRU_PRODUCTION | SPEC_HEALTH | OTHER
local_worker_safe: true | false
---

# TASK: [Short descriptive title]
**Status**: BACKLOG | ACTIVE | BLOCKED | COMPLETED
**Priority**: CRITICAL | HIGH | MEDIUM | LOW
**Type**: bug-fix | feature | refactor | architecture | data | documentation
**Created**: YYYY-MM-DD
**Last Updated**: YYYY-MM-DD

---

## Local Worker Triage Report
*Filled in by local model (Ollama via Continue) during backlog review*
*Local models read task files only — they cannot run commands or access the DB*

- **Template Conformance**: PASS | FAIL — [note missing sections]
- **Docker Wrapper Check**: PASS | FAIL | N/A — [verify RSpec strings use correct docker exec format]
- **MVP Alignment**: VALID | STALE | OBSOLETE — [does this task still apply to current codebase]
- **MVP Impact Note**: [one line on how this connects to AI Manager Luna settlement or spec health]
- **Action Line**: READY FOR CLOUD HANDOFF | NEEDS MANUAL REVIEW | OBSOLETE — ARCHIVE

---

## Agent Assignment

**Assigned To**: [GPT-4.1 0x | Haiku 0.33x | Claude Sonnet 1x | Local Ollama]
**Why This Agent**: [one line]
**Supervision Level**: [watched carefully | standard | autonomous OK]

**Supervision Legend**:
- Watched carefully = 0x/0.33x cloud agents and all local models
- Standard = 0.33x agents on well-specified tasks
- Autonomous OK = 1x agents only

> Local Ollama agents: you cannot execute terminal commands, Docker, RSpec, or git.
> You can read files provided to you and create/edit files via Continue.
> Never fabricate command output. If you need a command run, ask the human.

---

## Context
[2-4 sentences explaining what this part of the system does and why this task exists.]

**Relevant Architecture Docs** — read before starting:
- `docs/new_agent/rules/DECISIONS.md` — locked architectural decisions
- `docs/new_agent/rules/GUARDRAILS.md` — execution rules
- `docs/[path]/[file].md` — [one line on what it covers]

> If a doc doesn't exist for this area, do not create one during this task.
> Flag the gap in your completion report instead.

---

## Problem Statement
[Exact description of what is wrong or missing.]

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
| `data/json-data/[path]/[file].json` | [e.g. operational data structure] |

### Migration (if needed)
- [ ] No migration needed
- [ ] Migration needed: `[describe the schema change]`

---

## Implementation Steps

> 0x/0.33x agents: follow these steps exactly in order.
> 1x agents: use as a guide, apply judgment.
> Local Ollama agents: read steps carefully, ask human to run any commands, never fabricate output.

**Debug prints OK for complex callbacks** — add temporary `puts` statements, remove after verification.

### Step 1 — [action]
[Exact description of what to do]

```ruby
# before
def example_method
  old_code
end

# after
def example_method
  new_code
end
```

### Step 2 — [action]
[Exact description]

### Step 3 — Verify

> CRITICAL EXECUTION MANDATE: All RSpec commands must use the isolated Docker wrapper below.
> Never run bare local test commands. Never fabricate test results.

```bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec [SPEC_PATH_IN_CONTAINER] 2>&1 | tail -20'
```

Expected result: X examples, 0 failures

### Step 4 — Synthesis Report format (before applying any fix)

```
SYNTHESIS REPORT
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

## Acceptance Criteria
- [ ] [specific measurable outcome]
- [ ] Isolation run: 0 failures
- [ ] No regressions in related specs
- [ ] Full suite run completed and logged

---

## Stop Conditions — escalate to user immediately if:
- Fix causes new failures in specs you did not touch
- Same failure persists after two attempts
- Root cause is in a shared concern, base class, or factory used across many specs
- A database migration is needed that wasn't anticipated
- Any architectural decision is required
- Fix requires changing more files than the task specifies

---

## Commit Instructions
Run git commands on **host**, not inside container:
```bash
git add [specific files only — never git add .]
git commit -m "[type]: [spec/file name] — [brief description of root cause and fix]"
git push
```

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

### Issues discovered
[Any problems found during implementation that weren't in the original task]

### Follow-up tasks needed
[Any new backlog items identified — do not create the files, just list them here]

### Lessons learned
[What worked, what didn't, what future tasks in this area should know]

---

## Handoff Summary
*Filled in at end of session — one scannable line for next agent*

HANDOFF SUMMARY: [files updated] | [structural changes] | [next action needed]
