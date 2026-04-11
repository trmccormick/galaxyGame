# TASK: Audit Housing Concern and BaseCraft Include List
**Status**: BACKLOG
**Priority**: MEDIUM
**Type**: architecture
**Created**: 2026-04-10
**Last Updated**: 2026-04-10

---

## Agent Assignment

**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Requires architectural reasoning across multiple models
and concerns before any action is taken. No code changes in this task —
audit and recommendation only.
**Supervision Level**: 🟡 Standard

---

## Context

The `Housing` concern (`app/models/concerns/housing.rb`) is a stub created
on 2026-02-15. It sets a hardcoded `population_capacity` of 100 via
`attr_accessor` and `after_initialize`. It has no unit-aware capacity
calculation and provides no real behavior.

Despite this, it is included in:
- `Craft::BaseCraft`
- `Structures::OrbitalStructure` (removed this session — replaced with direct base_units sum)
- `Structures::ConvertedBase` (removed this session — replaced with direct base_units sum)
- Possibly other models — this is unknown and must be audited

The real population capacity logic lives in `Settlement::BaseSettlement#capacity`
which sums from `base_units` operational_data. This pattern was confirmed correct
and used to fix `OrbitalStructure` and `ConvertedBase` this session.

`BaseCraft` also has a large include list that may contain other stubs copied
forward from agents filling gaps. This has not been audited.

This task is **audit and recommendation only**. No code changes are made here.
Findings go into a completion report and a follow-up task file.

---

## Problem Statement

**Current behavior**:
- `Housing` concern is a stub — sets `@population_capacity = 100` as a
  hardcoded default, provides no unit-based calculation
- Any model including `Housing` silently gets wrong population capacity
  unless it overrides the method
- `BaseCraft` include list was written by an agent and has not been
  audited for stubs or redundant concerns

**Expected behavior**:
- `Housing` concern either properly implements unit-based capacity
  calculation or is removed entirely from all models
- `BaseCraft` include list contains only real, implemented concerns
- Decision is based on a full audit of all includers and their actual needs

---

## Files to Read — Do Not Edit

| File | Why |
|---|---|
| `app/models/concerns/housing.rb` | The stub — understand exactly what it does and doesn't do |
| `app/models/craft/base_craft.rb` | Primary includer — audit full include list |
| `app/models/settlement/base_settlement.rb` | Has real capacity logic — understand the pattern |
| `app/models/structures/orbital_structure.rb` | Fixed this session — example of correct pattern |
| `app/models/structures/converted_base.rb` | Fixed this session — example of correct pattern |

---

## Audit Steps

> This task produces a report. No code changes.

### Step 1 — Find all includers of Housing concern
```bash
grep -rn "include Housing" app/ --include="*.rb"
```
List every model and concern that includes `Housing`.

### Step 2 — Find all includers of PopulationManagement concern
```bash
grep -rn "include PopulationManagement" app/ --include="*.rb"
```
`PopulationManagement` handles population flow (add/remove/validate) but
delegates to `population_capacity` as a column/attribute. Understand the
relationship between these two concerns.

### Step 3 — Audit what Housing actually provides
```bash
cat app/models/concerns/housing.rb
```
Document every method and callback. Confirm it is a stub.

### Step 4 — Audit BaseCraft include list
For each concern included in `BaseCraft`, run:
```bash
grep -rn "def " app/models/concerns/[concern_name].rb
```
Document which concerns are fully implemented vs stubs vs partially implemented.
Flag any concern that:
- Has no real methods beyond accessors
- Duplicates behavior already in BaseSettlement or BaseCraft directly
- Was likely added by an agent to fill a gap

### Step 5 — Check for population_capacity column
```bash
grep -n "population_capacity" db/schema.rb
```
Determine whether `population_capacity` is a database column on any table
or purely a calculated value. This affects whether Housing's `attr_accessor`
is harmless or actively shadowing a real column.

### Step 6 — Identify all call sites of Housing methods
```bash
grep -rn "population_capacity\|initialize_housing\|allocate_space" app/ spec/ --include="*.rb"
```
Find every place that calls methods provided by the Housing concern.
This determines blast radius of any change.

---

## Completion Report Format

Produce a report in this exact format and stop — no code changes:

```
HOUSING CONCERN AUDIT
=====================
Stub confirmed: [yes/no]
All includers:
  - [model] — [does it override capacity? yes/no] — [impact of removal]
  - ...

population_capacity column exists on: [list tables or "none — purely calculated"]

Housing method call sites:
  - [file:line] — [which method] — [safe to remove? yes/no/needs replacement]

BASECRAFT INCLUDE LIST AUDIT
============================
Fully implemented concerns: [list]
Stub or partial concerns: [list with evidence]
Redundant concerns (behavior duplicated elsewhere): [list]

RECOMMENDATION
==============
Housing concern: [REMOVE | IMPLEMENT | KEEP AS-IS]
Reasoning: [one paragraph]

If REMOVE:
  Models requiring base_units sum replacement: [list]
  Models where removal is safe with no replacement: [list]

If IMPLEMENT:
  Proposed implementation: [describe]
  Models that would benefit: [list]

BaseCraft include list:
  Safe to remove: [list concerns]
  Needs investigation before removal: [list concerns]
  Keep: [list concerns]

FOLLOW-UP TASK NEEDED
=====================
[Description of the implementation/removal task to create after this audit]
Estimated scope: [single file | multi-file | broad refactor]
Recommended agent: [tier]
```

---

## Acceptance Criteria
- [ ] All Housing concern includers identified
- [ ] All Housing method call sites identified
- [ ] population_capacity column presence confirmed
- [ ] BaseCraft include list fully audited
- [ ] Completion report produced in the format above
- [ ] No code changes made

---

## Stop Conditions
- Any concern in the BaseCraft include list touches life support or
  precursor mission code — flag it, do not audit further without
  reading `docs/architecture/life_support_waste_recycling_architecture.md`
  and `docs/architecture/precursor_mission_bootstrap_architecture.md` first
- `population_capacity` is a database column on a table with existing
  records — flag immediately, removal of attr_accessor could break things

---

## Dependencies
**Blocked by**: nothing
**Blocks**: nothing directly — informs a future implementation task
**Related tasks**:
- `2026-04-08-HIGH-FEATURE-ORBITAL-STRUCTURE-ORBITAL-SETTLEMENT-SPECS.md` — context for why this was discovered
- Follow-up implementation task to be created after this audit completes

---

## Notes
- `OrbitalStructure` and `ConvertedBase` already had `include Housing`
  removed this session (2026-04-10). Their `habitat_capacity` now uses
  the correct `base_units` sum pattern. Do not re-add Housing to these models.
- The correct capacity pattern confirmed this session:
  ```ruby
  base_units.sum do |unit|
    capacity_data = unit.operational_data&.dig('capacity')
    if capacity_data.is_a?(Hash)
      capacity_data['passenger_capacity'] || capacity_data['capacity'] || 0
    else
      capacity_data&.to_i || 0
    end
  end
  ```
- Housing concern timestamp: 2026-02-15 — predates current unit-based
  capacity architecture. Likely created by an agent as a placeholder.
