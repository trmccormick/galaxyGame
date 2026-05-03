---

# TASK: Fix UnitAssemblyJob#materials_gathered? false negative (blocks start_assembly)
**Status**: ACTIVE  
**Priority**: CRITICAL  
**Type**: bug-fix  
**Created**: 2026-03-23  
**Last Updated**: 2026-03-23  

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x  
**Why This Agent**: Single-model bug, clear failure pattern, diagnostic provided  
**Supervision Level**: 🔴 Watched carefully  

> 🔴 0x and 0.25x agents: read every section carefully before starting.
> Do not infer file paths or method names — they are provided explicitly below.

---

## Context
Unit assembly jobs are responsible for tracking and managing the collection of required materials before assembly can begin. The `materials_gathered?` method determines if all required materials are present. A false negative here blocks the assembly process, causing cascading failures. This task exists to restore correct behavior and unblock downstream specs.

**Relevant Architecture Docs** — read before starting:
- `docs/agent/README.md` — project structure, agent rules, critical command safety
- `docs/GUARDRAILS.md` — agent operating rules, command safety
- `docs/PRACTICAL_TESTING_GUIDE.md` — RSpec/test workflow reference

---

## Problem Statement
`UnitAssemblyJob#materials_gathered?` is returning false when all materials are present, causing 4 spec failures and blocking `start_assembly`. This is a critical path bug.

**Error output** (from spec/models/unit_assembly_job_spec.rb:57,98,107):
```
materials_gathered? should return true when all required materials are present, but returns false
```

**Current behavior**: `materials_gathered?` returns false even when inventory is sufficient.  
**Expected behavior**: `materials_gathered?` returns true when all required materials are present in inventory.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `app/models/unit_assembly_job.rb` | Unit assembly job logic | `#materials_gathered?` |
| `spec/models/unit_assembly_job_spec.rb` | Tests for unit assembly job | lines 57, 98, 107 |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `spec/factories/unit_assembly_jobs.rb` | Factory structure for this model |
| `app/data/json-data/blueprints/units/` | Operational data structure |

### Migration (if needed)
- [x] No migration needed

---

## Implementation Steps

1. Read this task file completely before touching any code
2. Run: grep -n 'materials_gathered\|fulfill\|inventory' app/models/unit_assembly_job.rb spec/models/unit_assembly_job_spec.rb
3. Produce a Synthesis Report and STOP — wait for approval
4. Apply the approved fix only
5. Run: rspec spec/models/unit_assembly_job_spec.rb — confirm 0 failures
6. Run: rspec spec/models/ — confirm no regressions
7. Commit from host with descriptive message
8. Report back with test results

---

## Acceptance Criteria
- [ ] `materials_gathered?` returns true when all required materials are present
- [ ] Isolation run: 0 failures in unit_assembly_job_spec.rb
- [ ] No regressions in spec/models/
- [ ] Commit message describes the fix
- [ ] Report includes test results

---

## Stop Conditions — escalate to user immediately if:
- Fix causes new failures in specs you did not touch
- Same failure persists after two attempts — report exact error, do not attempt a third fix
- Root cause is in a shared concern, base class, or factory used across many specs
