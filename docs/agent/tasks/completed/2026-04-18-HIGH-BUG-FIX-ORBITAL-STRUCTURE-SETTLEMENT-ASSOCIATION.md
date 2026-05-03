# TASK: OrbitalStructure — Fix settlement association to OrbitalSettlement
**Status**: ACTIVE
**Priority**: HIGH
**Type**: bug-fix
**Created**: 2026-04-18
**Last Updated**: 2026-04-18

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x
**Why This Agent**: Two model files and one factory file, fully specified, no inference needed
**Supervision Level**: 🔴 Watched carefully

> ⚠️ 0x agent: read every section carefully before starting.
> Do not infer file paths or method names — they are provided explicitly below.

## Housekeeping — Do First
Move the architecture task to completed before starting implementation:
```bash
mv docs/agent/tasks/backlog/2026-04-18-HIGH-ARCHITECTURE-STRUCTURE-CORE-CONCERN.md docs/agent/tasks/completed/
```
Add a note at the top of the completed file:
```
Completed: Design decision made — per-subclass settlement association.
No StructureCore extraction needed at this time.
OrbitalStructure overrides belongs_to :settlement to use OrbitalSettlement.
Implemented in: 2026-04-18-HIGH-BUG-FIX-ORBITAL-STRUCTURE-SETTLEMENT-ASSOCIATION.md
```

---

## Context

`BaseStructure` declares `belongs_to :settlement, class_name: 'Settlement::BaseSettlement'`.
All 9 surface structure subclasses correctly inherit this — they belong to
surface settlements. `OrbitalStructure` is the only exception — it belongs
to `Settlement::OrbitalSettlement`. Rails type-checks the class name and
rejects `OrbitalSettlement` when assigned to an `OrbitalStructure`.

No `StructureCore` extraction is needed. The fix is:
- `OrbitalStructure` declares its own `belongs_to :settlement` overriding
  the inherited one with the correct `class_name`
- `orbital_structure` factory updated to use `:orbital_settlement`

No migration needed — `OrbitalSettlement` uses
`self.table_name = 'base_settlements'`, same table as the foreign key.

---

## Problem Statement

**Error output:**
```
ActiveRecord::AssociationTypeMismatch:
  Settlement::BaseSettlement expected, got Settlement::OrbitalSettlement
# factory_bot attribute_assigner — create(:orbital_structure, settlement: settlement)
```

**Current behavior**: `OrbitalStructure` rejects `OrbitalSettlement` as
its settlement — inherits wrong `class_name` from `BaseStructure`.

**Expected behavior**: `OrbitalStructure` accepts `OrbitalSettlement`.
Surface structure subclasses continue to accept `BaseSettlement` unchanged.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Change |
|---|---|---|
| `galaxy_game/app/models/structures/orbital_structure.rb` | OrbitalStructure model | Add `belongs_to :settlement` override |
| `galaxy_game/spec/factories/structures/orbital_structure.rb` | OrbitalStructure factory | Change settlement factory to `:orbital_settlement` |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `galaxy_game/app/models/structures/base_structure.rb` | Confirm line 19 — current association |
| `galaxy_game/app/models/settlement/orbital_settlement.rb` | Confirm `self.table_name = 'base_settlements'` |
| `galaxy_game/spec/factories/structures/base_structure.rb` | Confirm base factory uses `:base_settlement` — do not change |

### Migration
- [x] No migration needed

---

## Implementation Steps

### Step 1 — Verify current state
```bash
grep -n "belongs_to.*settlement" galaxy_game/app/models/structures/base_structure.rb
grep -n "belongs_to.*settlement" galaxy_game/app/models/structures/orbital_structure.rb
grep -n "settlement" galaxy_game/spec/factories/structures/orbital_structure.rb
```

Expected:
- `BaseStructure` line 19: `belongs_to :settlement, class_name: 'Settlement::BaseSettlement', optional: true`
- `OrbitalStructure`: no `belongs_to :settlement` line
- Factory: `association :settlement, factory: :base_settlement` or similar

### Step 2 — Add settlement association to OrbitalStructure

In `galaxy_game/app/models/structures/orbital_structure.rb`, add inside
the class body after the existing includes:

```ruby
# Override BaseStructure settlement association — orbital structures
# belong to OrbitalSettlement, not BaseSettlement
belongs_to :settlement, class_name: 'Settlement::OrbitalSettlement', optional: true
```

### Step 3 — Update orbital_structure factory

In `galaxy_game/spec/factories/structures/orbital_structure.rb`, find
the settlement association and change to use `:orbital_settlement`:

```ruby
# FROM (whatever the current settlement line is)
association :settlement, factory: :base_settlement
# or
settlement { create(:base_settlement) }

# TO
association :settlement, factory: :orbital_settlement
```

If no settlement association exists in the factory, add:
```ruby
association :settlement, factory: :orbital_settlement
```

---

## Synthesis Report Format
Before applying any fix, produce a report in this format and **stop**:

```
THE FAILURE
Spec: orbital_shipyard_service_spec.rb + inventory_manager_spec.rb
Error: AssociationTypeMismatch — BaseSettlement expected, got OrbitalSettlement
Expected: OrbitalStructure accepts OrbitalSettlement
Got: Type mismatch on factory creation

ROOT CAUSE
OrbitalStructure inherits belongs_to :settlement with class_name
'Settlement::BaseSettlement' from BaseStructure. No override exists.
Factory passes OrbitalSettlement which Rails rejects.

PROPOSED FIX
1. Add belongs_to :settlement override in OrbitalStructure
2. Update orbital_structure factory to use :orbital_settlement

RISK
Surface structure subclasses unaffected — they don't override the
association and continue to use BaseSettlement correctly.
No migration needed — OrbitalSettlement uses base_settlements table.

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence

1. **Isolation run — orbital_shipyard:**
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/construction/orbital_shipyard_service_spec.rb 2>&1 | grep -E "example|failure" | tail -5'
```
Expected: `25 examples, 0 failures`

2. **Isolation run — inventory_manager:**
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/logistics/inventory_manager_spec.rb 2>&1 | grep -E "example|failure" | tail -5'
```

3. **Models suite — confirm no regressions:**
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/ 2>&1 | grep -E "example|failure" | tail -3'
```
Expected: `1885 examples, 1 failure, 29 pending`

4. **Related structures specs:**
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/structures/ 2>&1 | grep -E "example|failure" | tail -5'
```

---

## Acceptance Criteria
- [ ] `orbital_shipyard_service_spec.rb` — 0 failures
- [ ] `inventory_manager_spec.rb` — 0 failures (or reduced)
- [ ] Models suite — 1885 examples, 1 failure (pre-existing only)
- [ ] No regressions in surface structure specs
- [ ] No migration generated

---

## Stop Conditions — escalate to user immediately if:
- Surface structure specs start failing after the change
- Migration appears to be needed
- `OrbitalSettlement` factory doesn't exist
- More than 2 files need changing

---

## Commit Instructions
```bash
git add galaxy_game/app/models/structures/orbital_structure.rb
git add galaxy_game/spec/factories/structures/orbital_structure.rb
git commit -m "fix: orbital_structure — override settlement association to OrbitalSettlement; update factory"
git push
```

---

## Dependencies
**Blocked by**: nothing
**Blocks**: `2026-04-16-HIGH-FEATURE-MARKETPLACE-ON-STRUCTURE.md`
**Related tasks**: `2026-04-18-CRITICAL-ARCHITECTURE-TASK-EXECUTION-ENGINE-BLUEPRINT-DRIVEN.md`

---

## Completion Report
*Filled in by the implementing agent after completion*

**Completed by**:
**Completion date**:
**Final test result**:

### What was changed
### Issues discovered
### Follow-up tasks needed
### Lessons learned
