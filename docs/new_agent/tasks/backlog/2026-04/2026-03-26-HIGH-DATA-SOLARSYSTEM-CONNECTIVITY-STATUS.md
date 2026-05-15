# 2026-03-26-HIGH-DATA-SOLARSYSTEM-CONNECTIVITY-STATUS

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — High priority data foundation for solar system connectivity status
**Supervision Level**: 🔴 Watched carefully

## Context
Mission Planner needs to know if solar systems are connected to wider network (Earth/Sol imports available) or orphaned (cut off from external supply). This affects Tier 3 sourcing availability for all settlements in the system.

## Problem Statement
SolarSystem model lacks connectivity_status field. Mission Planner cannot determine if system is connected, distressed, or orphaned. Blocks all Tier 3 sourcing logic.

**Expected**: SolarSystem has connectivity_status string column with enum values :connected, :distressed, :orphaned, defaulting to :connected.

## Files Involved
### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `app/models/solar_system.rb` | Solar system model | Add connectivity_status enum and scopes |
| `spec/factories/solar_systems.rb` | Factory | Update factory to handle connectivity_status default |

### Primary Files — you will create
| File | Purpose | Action |
|---|---|---|
| `db/migrate/[timestamp]_add_connectivity_status_to_solar_systems.rb` | Migration | Add connectivity_status string column with default 'connected' |

## Implementation Steps
1. **Generate migration**: Create migration adding connectivity_status string column with default 'connected' and null: false
2. **Review migration**: Confirm migration includes proper default and null constraints
3. **Run migration**: Execute in development and test environments
4. **Add enum to model**: Add connectivity_status enum with connected/distressed/orphaned values and scopes
5. **Update factory**: Ensure factory handles connectivity_status appropriately

## Acceptance Criteria
- [ ] SolarSystem model has connectivity_status enum with three values
- [ ] Migration adds column with proper default and constraints
- [ ] orphaned_systems and connected_systems scopes available
- [ ] Factory updated if needed for connectivity_status

## Stop Conditions
- Breaking existing SolarSystem functionality
- Changes beyond connectivity status data foundation

## Commit Instructions
```bash
git add db/migrate/[timestamp]_add_connectivity_status_to_solar_systems.rb
git add app/models/solar_system.rb
git add spec/factories/solar_systems.rb
git commit -m "feat: add connectivity status data foundation to solar system model"
```