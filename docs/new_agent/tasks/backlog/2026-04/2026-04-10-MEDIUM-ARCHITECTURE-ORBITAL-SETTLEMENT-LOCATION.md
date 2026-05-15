# 2026-04-10-MEDIUM-ARCHITECTURE-ORBITAL-SETTLEMENT-LOCATION

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Architecture audit for orbital settlement location system
**Supervision Level**: 🔴 Watched carefully

## Context
OrbitalSettlement inherits has_one :location from BaseSettlement via CelestialLocation (polymorphic), but no code creates CelestialLocation records when OrbitalSettlement is created. Service layer calls settlement.location in ~40 locations across AI Manager, logistics, contracts, etc.

## Problem Statement
OrbitalSettlement#location returns nil because no CelestialLocation is created on initialization. Service layer calls that do settlement.location&.celestial_body silently return nil for all orbital settlements.

**Expected behavior**: OrbitalSettlement has CelestialLocation created on after_create that associates it with the celestial body it orbits.

## Files Involved
### Primary Files — you will read
| File | Purpose |
|---|---|
| `app/models/settlement/orbital_settlement.rb` | Orbital settlement model |
| `app/models/settlement/base_settlement.rb` | Base settlement callbacks |
| `app/services/ai_manager/depot_adapter.rb` | Reference implementation for location creation |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `db/schema.rb` | CelestialLocation table schema |
| All service files calling settlement.location | ~40 locations to audit |

## Implementation Steps
1. **Confirm CelestialLocation schema**: Document all columns and orbital support
2. **Review existing creation patterns**: How other models create CelestialLocation
3. **Audit service layer calls**: Classify all ~40 calls by type (body association, full location object, finder pattern)
4. **Check OrbitalSettlement callbacks**: What fires on creation
5. **Assess impact**: Which calls work once location created, which need surface vs orbital distinction

## Acceptance Criteria
- [ ] CelestialLocation schema documented
- [ ] All ~40 service layer location calls classified
- [ ] Surface vs orbital distinction impact assessed
- [ ] Recommendation produced for implementation
- [ ] No code changes made

## Stop Conditions
- CelestialLocation schema does not support orbital context
- More than 10 service layer calls need surface vs orbital distinction added

## Commit Instructions
```bash
git add docs/architecture/orbital_settlement_location_audit.md
git commit -m "docs: orbital settlement location audit — CelestialLocation creation and service layer impact"
```