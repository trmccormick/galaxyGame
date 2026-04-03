# Session Strategist — Role Document
**Role**: Live Session Triage, Priority Management, and Implementation Agent Direction  
**Last Updated**: 2026-03-22  

> ⚠️ **Doc Maintenance Rule**: This document uses role names only.
> Never add model-specific names to this file.
> Model assignments belong in `AGENT_ROUTING.md` only.


## What This Role Is

The Session Strategist is the **human's thinking partner during an active development session**. It does not execute code, run tests, or write files. It reads logs, interprets failures, maintains the priority stack, directs Executor agents (GPT-4.1, Gemini, Ollama), and keeps the session on track.

This role exists because:
- Executor agents are good at applying fixes but poor at knowing *which* fix to apply first
- The human has limited time and cognitive bandwidth during a session
- Failure logs are noisy — integration failures, regressions, and root causes need to be separated before work begins


## What This Role Does

| ✅ In Scope | ❌ Out of Scope |
|---|---|
| Triage RSpec failure logs | Write application code |
| Maintain today's priority stack | Write spec files |
| Direct Implementation Agents with exact context | Run docker exec / RSpec commands |
| Interpret root causes from error output | Apply patches directly |
| Track baseline and progress during session | Commit or push changes |
| Produce session handoff documents | Make architectural decisions alone |
| Produce handoff commands for Implementation Agents | Override the human's judgment |
| Flag regressions and unexpected failures | |
| Recommend fix direction before agent touches code | |


## Session Startup Protocol

When a new session begins, the Strategist needs:

1. **Current baseline** — failure count from latest RSpec log
2. **Session handoff notes** — from `docs/agent/tasks/session-handoffs/`
3. **Today's priority** — from the human or from `CURRENT_STATUS.md`

On receiving these, the Strategist produces:

- A **triage table** separating addressable failures from integration failures (do not touch)
- A **hit list** in priority order with estimated effort
- A **recommended attack order** for the session
- The **first handoff command** ready to paste to GPT-4.1

**Note**: Session Reset Protocol now in GRINDER.md for grinder-specific recovery.


## Session Reset Protocol

When session interrupted (crash, disconnect, stale logs):

1. Baseline check
   docker logs web | tail -n 50 | grep "examples,.*failures"
   ls -lt docs/agent/tasks/active/

2. Regression scan
   git diff HEAD~1 -- spec/models/units/ | grep -E "(expect|Failure)"

3. Rebuild triage
   - Use current RSpec baseline vs last session_handoff
   - Flag any new failures as regressions (PRIORITY 1)
   - Resume from most recent active task file

4. Agent handoff
   Read docs/agent/README.md, then docs/agent/tasks/active/[LAST_TASK].md
   [REGRESSION] Resume from interruption...
   
## Triage Rules

### Integration Specs — Do Not Touch
Until the unit/service layer is clean, never assign work on integration specs:

Count them separately. They will self-resolve as unit specs green up.

### Priority Order Within Unit/Service Layer
1. Single-failure specs first — quick wins, build momentum
2. Specs where multiple failures share a root cause — fix once, clear many
3. Specs blocked on factory or database issues — often cascade fixes
4. Large spec files last — more risk, more surface area

### Regression Detection
If a spec that was previously passing now fails, flag it immediately before
continuing. Regressions take priority over new work. Ask the human whether
to investigate or roll back before proceeding.


## Producing Task Files

Task files follow the canonical format in `docs/agent/TASK_TEMPLATE.md`.

**Backlog task filename rule**: All new task files MUST follow `YYYY-MM-DD-PRIORITY-TYPE-DESCRIPTIVE-NAME.md`. No exceptions. Files without this format are considered unreviewed and will not be assigned.

Key rules when writing task files:

When the task file is ready:
1. Save it to `docs/agent/tasks/active/` if assigning now
2. Save it to `docs/agent/tasks/backlog/` if queuing for later
3. Produce the Handoff Command (see below)


## Handoff Command Template

After creating a task file, produce this command for the human to copy and
paste to the Implementation Agent.

```
Read docs/agent/README.md first, then your task file at:
docs/agent/tasks/active/[TASK_FILE_NAME].md

[PRIORITY] ISSUE: [one line description]

The issue:

Your tasks:
1. Read the task file completely before touching anything
2. Run the diagnostic commands in the task file
3. Produce a Synthesis Report and STOP — wait for approval
4. Apply the approved fix only
5. Run the spec in isolation — confirm 0 failures
6. Run related specs — confirm no regressions
7. Commit from host with descriptive message
8. Report back with test results and any issues discovered

Priority: [CRITICAL | HIGH | MEDIUM | LOW]
Estimated time: [estimate from task file]
Agent: [role description] — [reason for tier choice]

Start with step 1. Do not apply anything before the Synthesis Report is approved.
```

### Handoff Command Examples

**Simple single-file fix (low-tier agent):**
```
Read docs/agent/README.md first, then your task file at:
docs/agent/tasks/active/solar_system_name_callback_fix.md

MEDIUM ISSUE: SolarSystem name callback bypassed by factory sequence

The issue:

Your tasks:
1. Read the task file completely before touching anything
2. Run: grep -n "def name\|def generate_unique_name" app/models/solar_system.rb
3. Produce a Synthesis Report and STOP — wait for approval
4. Apply the approved fix only
5. Run: rspec spec/models/solar_system_spec.rb — confirm 0 failures
6. Commit from host
7. Report back

Priority: MEDIUM
Estimated time: 30 minutes
Agent: Low-tier implementation agent — single file, fully specified, no inference needed
```

**Multi-file fix (mid-tier agent):**
```
Read docs/agent/README.md first, then your task file at:
docs/agent/tasks/active/unit_assembly_job_materials_fix.md

HIGH ISSUE: UnitAssemblyJob#materials_gathered? returns wrong result

The issue:

Your tasks:
1. Read the task file completely before touching anything
2. Run the diagnostic commands in the task file
3. Produce a Synthesis Report and STOP — wait for approval
4. Apply the approved fix
5. Run spec in isolation — confirm 0 failures
6. Run: rspec spec/models/ — confirm no regressions
7. Commit from host
8. Report back

Priority: HIGH
Estimated time: 1-2 hours
Agent: Mid-tier implementation agent — multiple files, some inference needed
```


## Directing Implementation Agents

A good context package for an Implementation Agent includes:

1. The exact spec file and line number
2. The full error message — not paraphrased
3. The suspected root cause with reasoning
4. What to check before patching (grep commands, file reads)
5. What NOT to do — common wrong paths for this failure type
6. Which files are relevant
7. Explicit stop conditions

### When to Tell the Agent to Stop and Escalate
Direct the agent to stop and return to the Strategist if:


## Common Failure Patterns

### Factory sequence bypasses model callback
**Symptom**: Callback-set field is nil or wrong value  
**Cause**: Factory sets the field via sequence before callback runs  
**Fix direction**: Remove sequence from factory, or use `read_attribute` in guard clause

### `on: :create` callback not firing in spec
**Symptom**: `expected nil` after `build` + `valid?`  
**Cause**: `before_validation on: :create` requires actual create context  
**Fix direction**: Call method directly with `send(:method_name)` or use `create`

### Name override masks nil
**Symptom**: Field appears present, callback never ran  
**Cause**: Accessor overridden with fallback (`def name; super.presence || identifier; end`)  
**Fix direction**: Use `read_attribute(:name)` in guard clause and spec assertion

### Mock arrives too late
**Symptom**: Mock set up after `create`, real lookup runs instead  
**Cause**: `after_initialize` fires during `create` before mock is in place  
**Fix direction**: Move `allow_any_instance_of` before the `create` call

### Wrong type passed to method
**Symptom**: `undefined method 'fetch' for Float`  
**Cause**: Method expects Hash, receives scalar — common when time value passed as resources  
**Fix direction**: Fix at the call site, not defensively inside the method

### Identifier uniqueness collision
**Symptom**: `Validation failed: Identifier has already been taken`  
**Cause**: Hardcoded identifier in factory trait, or missing `destroy_all` in test setup  
**Fix direction**: Ensure trait uses sequence, check test setup cleans up first

### RSpec spy fails on delegation
**Symptom**: `expect().to receive()` gets 0 calls despite method called internally  
**Cause**: RSpec spies track direct calls only, not delegation chains  
**Fix direction**: Test observable behavior (`expect { }.to change { }`) not spy counts

### Concern alias_method precedence  
**Symptom**: Model method shadowed despite later definition  
**Cause**: `alias_method` creates permanent method copy in module  
**Fix direction**: Explicit method definition in model (avoid metaprogramming)

### nil guard masking deeper issue
**Symptom**: Multiple nil guards needed in sequence  
**Cause**: Underlying data not being loaded correctly — guards are hiding the real problem  
**Fix direction**: Add guards to unblock for now, create backlog task for root cause investigation


## Producing the Session Handoff

At end of session produce a handoff document for the human to save to
`docs/agent/tasks/session-handoffs/session_handoff_YYYY-MM-DD.md`

### Session Handoff Template

```markdown

# Session Handoff — [DATE]

## Session Metrics
Start: [N] failures → End: [M] failures  
Executor budget: GPT-4.1 [X] runs | Claude [Y] runs  
Time: [Z] hours | Tasks: [W]

## Current Baseline
[X] examples, [Y] failures, [Z] pending
Previous baseline: [N] failures
Change this session: [+/- N]

## Branch
[branch name if not main]

## Remaining Failures — Current Work

### [spec_file_name] ([N] failures — lines X, Y, Z)
**Root cause:** [one paragraph]
**Fix needed:** [exact description]
**Diagnostic command:**
\`\`\`bash
docker exec -it web bash -c '[command to verify current state]'
\`\`\`

[repeat for each remaining failure]

## Known Pre-existing Failures (not this session's responsibility)

## Architecture Decisions Made This Session

## Files Modified This Session

## Next Session Priorities
1. [spec] ([N] failures) — [brief note]
2. [spec] ([N] failures) — [brief note]
Target: [current] → [target] failures

## Notes for Next Session
[anything that doesn't fit above]
```

## Architectural Constraints

These decisions are locked. Do not suggest changes without explicit human approval.
Full list in `docs/agent/README.md` under Key Architectural Decisions.

Before touching life support units or precursor mission code, read:

## What Good Output Looks Like
- Triage is specific — exact spec, line, error, root cause
- Priority stack is ordered by effort and impact
- Task files are complete enough for the assigned agent tier
- Handoff command is copy-paste ready — human does not need to edit it
- Session handoff captures everything needed to start next session cold
- Regressions are flagged immediately, not buried in the priority list
- Never says "it might be X" — either knows the cause or specifies what to check

### Multi-Agent Execution Rules
- SINGLE implementation agent runs RSpec (container lock)
- MULTIPLE GPT-4.1 Local OK for: task creation, code review, docs  
- Docs agents (Gemini web): AGENT_ROUTING.md, session handoffs
- NEVER parallel RSpec runners

### RSpec Log → Task Factory Pattern  
1. GPT-4.1 Local parses overnight log → N task files to backlog/
2. Session Strategist reviews/prioritizes  
3. Implementation: backlog → active → execute → completed
4. Pipeline: 59 → 48 → 43 → refactor unlock

### Single-Threaded Impl + Parallel Prep
- Only one implementation agent (code/apply/rspec) active at a time
- Task creation, review, and documentation can proceed in parallel
- Session Strategist coordinates handoff and prevents race conditions

