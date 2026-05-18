# 2026-04-12-MEDIUM-ARCHITECTURE-POPULATION-MANAGEMENT-CONCERN

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Architecture audit and refactor for population management concern
**Supervision Level**: 🔴 Watched carefully

## Context
PopulationManagement concern exists but is not included by any model and doesn't provide life support defaults. BaseSettlement defines these attributes itself using hardcoded values, while canonical values are in GameConstants.

Three model types need this logic: BaseSettlement (surface), BaseCraft (human-rated craft), OrbitalStructure (crewed orbital structures).

## Problem Statement
PopulationManagement concern exists but incomplete - no accessors or defaults for food_per_person, water_per_person, energy_per_person. BaseSettlement uses hardcoded values instead of GameConstants. BaseCraft and OrbitalStructure lack this logic entirely.

**Expected**: Concern provides attr_accessor and sets defaults using GameConstants in after_initialize callback. All three models include concern and remove duplicate logic.

## Files Involved
### Primary Files — you will read
| File | Purpose |
|---|---|
| `app/models/concerns/population_management.rb` | Existing concern to enhance |
| `app/models/settlement/base_settlement.rb` | Current hardcoded logic |
| `app/models/craft/base_craft.rb` | Check for existing logic |
| `app/models/structures/orbital_structure.rb` | Check for existing logic |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `config/initializers/game_constants.rb` | Canonical life support values |

## Implementation Steps
1. **Audit current logic**: Confirm GameConstants values, BaseSettlement hardcoded logic, other models' status
2. **Enhance concern**: Add attr_accessor for per-person attributes, after_initialize callback with defaults from GameConstants
3. **Refactor models**: Include concern in all three models, remove duplicate logic from BaseSettlement
4. **Verify specs**: Ensure all affected model specs pass

## Acceptance Criteria
- [ ] PopulationManagement concern provides accessors and GameConstants defaults
- [ ] All three models include concern, remove duplicate/hardcoded logic
- [ ] All population management logic is DRY and canonical
- [ ] All specs pass

## Stop Conditions
- GameConstants does not define required values
- Any model has conflicting logic

## Commit Instructions
```bash
git add app/models/concerns/population_management.rb
git add app/models/settlement/base_settlement.rb
git add app/models/craft/base_craft.rb
git add app/models/structures/orbital_structure.rb
git commit -m "refactor: canonicalize and apply PopulationManagement concern for life support defaults using GameConstants"
```