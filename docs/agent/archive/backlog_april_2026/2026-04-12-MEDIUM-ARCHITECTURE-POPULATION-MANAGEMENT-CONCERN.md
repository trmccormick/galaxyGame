
# TASK: Canonicalize and Apply PopulationManagement Concern for Life Support Defaults
**Status**: BACKLOG
**Priority**: MEDIUM
**Type**: architecture
**Created**: 2026-04-12
**Last Updated**: 2026-04-17

---


## Agent Assignment
**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Requires architectural reasoning to unify and enforce canonical life support logic across models using an existing but incomplete concern.
**Supervision Level**: 🟡 Standard

---


## Context

There is already a `PopulationManagement` concern (`app/models/concerns/population_management.rb`) in the codebase. However, it is currently **not included by any model** and does **not** provide or default the key life support attributes (`food_per_person`, `water_per_person`, `energy_per_person`).

Currently, `BaseSettlement` defines and defaults these attributes itself, using hardcoded values in `set_life_support_defaults`. The canonical values are actually defined in `GameConstants` as `FOOD_PER_PERSON`, `WATER_PER_PERSON`, and `ENERGY_PER_PERSON`.

Three model types need this logic:
- `Settlement::BaseSettlement` — surface settlements
- `Craft::BaseCraft` — human-rated craft
- `Structures::OrbitalStructure` — crewed orbital structures

The goal is to enhance the existing concern to:
- Provide `attr_accessor` for the per-person attributes
- Set their defaults using `GameConstants` in an `after_initialize` callback
- Be included by all three models, which should remove any duplicate or hardcoded logic

This will ensure all population management logic is DRY, canonical, and consistent across the codebase.

**Relevant Architecture Docs** — read before starting:
- `docs/architecture/ai_manager/AI_MANAGER_INTENT.md` — service usage mandates and forbidden patterns
- `config/initializers/game_constants.rb` — canonical life support values

---


## Problem Statement

**Current behavior**:
- `PopulationManagement` concern exists but is not included by any model.
- The concern does not define or default `food_per_person`, `water_per_person`, or `energy_per_person`.
- `BaseSettlement` sets life support defaults using hardcoded values in `set_life_support_defaults`.
- `BaseCraft` and `OrbitalStructure` do not have this logic or use inconsistent values.
- There is duplication and risk of drift from the canonical values in `GameConstants`.

**Expected behavior**:
- The concern provides `attr_accessor` and sets defaults for all per-person life support attributes using `GameConstants` in an `after_initialize` callback.
- All three model types include the concern and remove any duplicate or hardcoded logic.
- All population management logic is DRY and references the canonical values.

---


## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| app/models/concerns/population_management.rb | Enhance concern: add accessors, defaults, after_initialize | All |
| app/models/settlement/base_settlement.rb | Remove hardcoded logic, include concern | set_life_support_defaults |
| app/models/craft/base_craft.rb | Include concern | N/A |
| app/models/structures/orbital_structure.rb | Include concern | N/A |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| config/initializers/game_constants.rb | Canonical values for food, water, energy per person |

### Migration (if needed)
- [x] No migration needed

---

## Implementation Steps

### Step 1 — Audit current logic
- Confirm `GameConstants` defines `FOOD_PER_PERSON`, `WATER_PER_PERSON`, `ENERGY_PER_PERSON`.
- Confirm `BaseSettlement` uses hardcoded values in `set_life_support_defaults`.
- Confirm `BaseCraft` and `OrbitalStructure` lack this logic.
- Confirm `PopulationManagement` concern exists but is not included or complete.

### Step 2 — Enhance concern
- Add `attr_accessor` for `food_per_person`, `water_per_person`, `energy_per_person`.
- Add `after_initialize :set_life_support_defaults`.
- Implement `set_life_support_defaults` to set values from `GameConstants` if not already set.
- Ensure `resource_requirements` and related methods use these attributes.

### Step 3 — Refactor models
- Include the concern in all three models.
- Remove any hardcoded or duplicate logic from `BaseSettlement`.

### Step 4 — Verify
- Ensure all specs pass for affected models.

---

## Synthesis Report Format

```
AUDIT
- GameConstants values: [list values]
- BaseSettlement: [hardcoded or not]
- BaseCraft: [logic present or not]
- OrbitalStructure: [logic present or not]
- PopulationManagement concern: [included/complete or not]

PROPOSED CHANGE
- Concern code: [show]
- Models updated: [list]

RISK
- Any code that expects different defaults or direct assignment

READY TO APPLY? — waiting for approval
```

---

## Acceptance Criteria
- [ ] PopulationManagement concern provides accessors and defaults from GameConstants
- [ ] All three models include concern, remove duplicate/hardcoded logic
- [ ] All population management logic is DRY and canonical
- [ ] All specs pass

---

## Stop Conditions
- GameConstants does not define the required values — flag and halt
- Any model has conflicting logic — flag before proceeding

---

## Commit Instructions
```bash
git add app/models/concerns/population_management.rb
git add app/models/settlement/base_settlement.rb
git add app/models/craft/base_craft.rb
git add app/models/structures/orbital_structure.rb
git commit -m "refactor: canonicalize and apply PopulationManagement concern for life support defaults using GameConstants"
git push
```

---

## Dependencies
**Blocked by**: nothing  
**Blocks**: nothing directly  
**Related**:  
- 2026-04-12-HIGH-ARCHITECTURE-ORBITAL-SETTLEMENT-DECOUPLE-FROM-BASE.md — completed

---

## Expected Concern Shape

```ruby
module PopulationManagement
  extend ActiveSupport::Concern

  included do
    attr_accessor :food_per_person, :water_per_person, :energy_per_person
    after_initialize :set_life_support_defaults
  end

  def calculate_life_support_requirements
    {
      food: current_population.to_i * (food_per_person || 0),
      water: current_population.to_i * (water_per_person || 0),
      energy: current_population.to_i * (energy_per_person || 0)
    }
  end

  private

  def set_life_support_defaults
    self.food_per_person ||= GameConstants::FOOD_PER_PERSON
    self.water_per_person ||= GameConstants::WATER_PER_PERSON
    self.energy_per_person ||= GameConstants::ENERGY_PER_PERSON
  end
end
```

Note: confirm GameConstants has these values or use hardcoded defaults
(2.0, 1.0, 3.0) as currently in BaseSettlement.

---

## Acceptance Criteria
- [ ] Concern extracted to `app/models/concerns/population_management.rb`
- [ ] `BaseSettlement` includes concern, removes duplicate methods
- [ ] `BaseCraft` includes concern where human-rated
- [ ] `OrbitalStructure` includes concern
- [ ] `calculate_life_support_requirements` defined once in concern
  (currently defined 3 times in `BaseSettlement` — pre-existing bug)
- [ ] All existing specs pass

## Stop Conditions
- `BaseCraft` or `OrbitalStructure` already has conflicting
  `set_life_support_defaults` — flag before proceeding
- `current_population` column does not exist on all three tables
  — flag, may need different approach per model

---

## Dependencies
**Blocked by**: nothing
**Blocks**: nothing directly
**Related**:
- `2026-04-12-HIGH-ARCHITECTURE-ORBITAL-SETTLEMENT-DECOUPLE-FROM-BASE.md` — completed
