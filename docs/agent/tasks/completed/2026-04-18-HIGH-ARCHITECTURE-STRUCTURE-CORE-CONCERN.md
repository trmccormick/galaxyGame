# TASK: StructureCore Concern — Mirror SettlementCore Pattern
**Status**: BACKLOG
**Priority**: HIGH
**Type**: architecture
**Created**: 2026-04-18
**Last Updated**: 2026-04-18

---

## Agent Assignment

**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Requires architectural reasoning across settlement and structure hierarchies, cross-system impact analysis, and concern extraction pattern matching
**Supervision Level**: 🟡 Standard

---

## Context

`SettlementCore` was extracted as a shared concern to decouple
`OrbitalSettlement` from `BaseSettlement`. The same problem now exists
on the structure side. `BaseStructure` holds a hardcoded
`belongs_to :settlement, class_name: 'Settlement::BaseSettlement'`
association. This breaks when `OrbitalStructure` tries to associate
with `OrbitalSettlement` — Rails type-checks the class name and rejects it.

The pattern should mirror the settlement side exactly:

**Settlement side (done):**
- `SettlementCore` — shared concern: owner, colony, account, structures,
  missions, inventory, validations
- `BaseSettlement` — surface settlements, includes SettlementCore
- `OrbitalSettlement` — orbital settlements, same table, includes
  SettlementCore, overrides location/capacity

**Structure side (needed):**
- `StructureCore` — shared concern: common associations, validations,
  shared methods
- `BaseStructure` — surface structures, includes StructureCore,
  `belongs_to :settlement, class_name: 'Settlement::BaseSettlement'`
- `OrbitalStructure` — orbital structures, includes StructureCore,
  `belongs_to :settlement, class_name: 'Settlement::OrbitalSettlement'`

---

## Problem Statement

**Current behavior**: `BaseStructure` line 19 declares:
```ruby
belongs_to :settlement, class_name: 'Settlement::BaseSettlement', optional: true
```
This causes `ActiveRecord::AssociationTypeMismatch` when an
`OrbitalStructure` is associated with an `OrbitalSettlement`.

**Schema context**: `structures` table has `settlement_id` foreign key
pointing at `base_settlements`. No `settlement_type` column exists —
not polymorphic. `OrbitalSettlement` uses `self.table_name =
'base_settlements'` so the foreign key constraint is already satisfied.
The problem is purely the Rails class-name type check.

**Expected behavior**: `OrbitalStructure` accepts `OrbitalSettlement`
as its settlement. `BaseStructure` subclasses accept `BaseSettlement`.

---

## Files Involved

### Reference Files — read before designing
| File | Why You Need It |
|---|---|
| `galaxy_game/app/models/concerns/settlement/settlement_core.rb` | The pattern to mirror |
| `galaxy_game/app/models/structures/base_structure.rb` | Current structure base class |
| `galaxy_game/app/models/structures/orbital_structure.rb` | Orbital structure — needs OrbitalSettlement |
| `galaxy_game/app/models/settlement/orbital_settlement.rb` | Shows self.table_name pattern |
| `galaxy_game/app/models/settlement/base_settlement.rb` | Surface settlement reference |
| `galaxy_game/db/schema.rb` | Confirm structures table columns |

### Files That Will Need Changes (implementation phase)
| File | Change |
|---|---|
| New: `galaxy_game/app/models/concerns/structure_core.rb` | Extract shared structure concern |
| `galaxy_game/app/models/structures/base_structure.rb` | Include StructureCore, keep BaseSettlement association |
| `galaxy_game/app/models/structures/orbital_structure.rb` | Include StructureCore, add OrbitalSettlement association |
| `galaxy_game/spec/factories/structures/` | Update factories to use correct settlement types |

---

## Design Questions to Answer

### 1. What moves to StructureCore?
Audit `BaseStructure` for everything that is shared across all structure
types vs what is surface-specific. Candidate shared items:
- `has_one :inventory`
- `has_many :base_units`
- `belongs_to :owner` (if present)
- Common validations
- Shared methods

### 2. Settlement association approach
Three options:
- **Per-subclass declaration** — each subclass declares its own
  `belongs_to :settlement` with correct `class_name`. StructureCore
  does not declare it.
- **Polymorphic** — add `settlement_type` column to structures table,
  make association polymorphic. Requires migration.
- **Base class only** — keep `belongs_to :settlement` on BaseStructure
  pointing at `BaseSettlement`, add separate association on
  `OrbitalStructure` pointing at `OrbitalSettlement`.

Recommended: per-subclass declaration — no migration, mirrors the
`self.table_name` pattern used by `OrbitalSettlement`.

### 3. Factory impact
Surface structure factories use `:base_settlement`. Orbital structure
factories need `:orbital_settlement`. Audit all structure factories
before implementation.

### 4. Spec impact
Any spec that creates a structure with a settlement needs to use the
correct settlement type for the structure subclass being tested.

---

## Output — Design Document

Produce a document covering:

```
STRUCTURE CORE EXTRACTION PLAN
================================

WHAT MOVES TO StructureCore
============================
[list associations, validations, methods that are truly shared]

WHAT STAYS IN BaseStructure
============================
[list surface-specific items]

WHAT GOES IN OrbitalStructure
==============================
[list orbital-specific items including settlement association]

SETTLEMENT ASSOCIATION APPROACH
=================================
Decision: [per-subclass | polymorphic | base-class-only]
Reasoning: [why]
Migration needed: [yes/no]

FACTORY CHANGES NEEDED
=======================
[list factories and what changes]

SPEC CHANGES NEEDED
===================
[list specs and what changes]

IMPLEMENTATION ORDER
====================
1. [step]
2. [step]
...

FOLLOW-UP TASKS
===============
[list implementation tasks with scope and agent tier]
```

---

## Acceptance Criteria
- [ ] Design document produced
- [ ] All design questions answered
- [ ] Implementation task files identified
- [ ] No code changes made in this task — design only

---

## Dependencies
**Blocked by**: Nothing
**Blocks**: Any task creating `OrbitalStructure` with `OrbitalSettlement`
**Related tasks**:
- `2026-04-16-HIGH-FEATURE-MARKETPLACE-ON-STRUCTURE.md`
- `2026-04-16-HIGH-FEATURE-DOCKING-TRANSACTION-SERVICE.md`
- `2026-04-17-HIGH-FEATURE-DOCKING-TRANSACTION-SERVICE.md`

---

## Notes
- Do not implement until design is reviewed and approved
- The `OrbitalSettlement.self.table_name = 'base_settlements'` pattern
  means no migration is needed for the settlement side — verify the
  same applies to the structure side before recommending any migration
- Reference `SettlementCore` extraction commit `6841035d` for the
  pattern that was followed on the settlement side

---

## Completion Report
*Filled in by the implementing agent after completion*

**Completed by**:
**Completion date**:

### Design decisions made
### Implementation tasks created
### Open questions remaining
