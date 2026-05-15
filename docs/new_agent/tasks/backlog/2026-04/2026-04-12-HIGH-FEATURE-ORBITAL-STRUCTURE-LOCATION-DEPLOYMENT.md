# 2026-04-12-HIGH-FEATURE-ORBITAL-STRUCTURE-LOCATION-DEPLOYMENT

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Feature implementation for orbital structure location deployment
**Supervision Level**: 🔴 Watched carefully

## Context
OrbitalSettlement#location delegates to structures.first&.celestial_location. For this to work, each OrbitalStructure must have CelestialLocation created when deployed. Currently no code does this - location returns nil for all orbital settlements.

## Problem Statement
OrbitalStructure has no CelestialLocation after creation. settlement.location returns nil. ~40 service layer calls that do settlement.location&.celestial_body silently return nil for orbital settlements.

**Expected**: OrbitalStructure gets CelestialLocation created when deployed to orbit around celestial body.

## Files Involved
### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `app/models/structures/orbital_structure.rb` | Orbital structure model | Add deployment method |
| `app/services/ai_manager/depot_adapter.rb` | Reference only | Do not change |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/models/structures/base_structure.rb` | Existing callbacks |
| `db/schema.rb` | CelestialLocation columns |
| `app/models/location/celestial_location.rb` | Required fields |

## Implementation Steps
1. **Read current OrbitalStructure**: Check existing callbacks and location handling
2. **Confirm CelestialLocation schema**: Verify required fields exist
3. **Add deploy_to_orbit! method**: Create CelestialLocation with orbital context
4. **Run specs**: Verify structure specs pass
5. **Run models suite**: Check for regressions

## Acceptance Criteria
- [ ] deploy_to_orbit! method added to OrbitalStructure
- [ ] Method creates CelestialLocation with context: orbital
- [ ] Method is idempotent (returns if location exists)
- [ ] depot_adapter.rb still works (unchanged)
- [ ] Structure specs pass
- [ ] No regressions in models suite

## Stop Conditions
- celestial_locations unique index conflicts on coordinates
- OrbitalStructure already has location creation callback

## Commit Instructions
```bash
git add app/models/structures/orbital_structure.rb
git commit -m "feat: OrbitalStructure location deployment — CelestialLocation created on deploy_to_orbit!"
```