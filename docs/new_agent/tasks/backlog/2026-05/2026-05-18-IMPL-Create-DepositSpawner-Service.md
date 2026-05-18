---
status: blocked-waiting-design
priority: HIGH
type: implementation
system_domain: AI_MANAGER
parent_task: AI Manager Resource Spawning System (2026-05-01)
created: 2026-05-18
depends_on: 2026-05-18-DESIGN-Deposit-Plausibility-Engine.md, 2026-05-18-DESIGN-Deposit-Trigger-System-And-Equipment-Gating.md
assigned_to: GPT-4.1
---

# IMPL: Create DepositSpawner Service

**Status**: BLOCKED - WAITING FOR DESIGN APPROVAL  
**Priority**: HIGH  
**Type**: implementation  
**Parent**: AI Manager Resource Spawning System  
**Depends On**: Plausibility Engine design + Trigger System design  
**Blocked By**: Design phase

---

## Objective

Implement the core deposit spawning service that will:
- Evaluate what deposits are plausible for a celestial body
- Use equipment tier to gate visible deposits
- Create ResourceDeposit records in the database
- Support on-demand spawning for survey/settlement/mission triggers

---

## Implementation Files

### File 1: DepositSpawner Service
**Location**: `galaxy_game/app/services/ai_manager/deposit_spawner.rb`

**Methods** (pending design approval):

```ruby
# Main entry point
def spawn_deposits_for_body(celestial_body, trigger_type:, equipment_tier:)
  # trigger_type: :survey, :settlement, :mission, :first_visit
  # equipment_tier: 0, 1, 2, 3
  # Returns: Array of created ResourceDeposit records
end

# Support for batch operations
def spawn_deposits_for_all_bodies
  # Called on rake task or scheduled job
  # Pre-generates deposits for known bodies
end

# Survey-specific
def reveal_deposits_on_survey(region, celestial_body, equipment_tier:)
  # Called when survey completes
  # Reveals/creates deposits for surveyed region
end

# Settlement-specific  
def spawn_deposits_near_settlement(settlement, radius_km: 50)
  # Called when settlement is founded
  # Ensures ISRU resources available
end
```

**Key Logic** (from design):
- Uses PlausibilityEngine to get viable deposit rules
- Queries CelestialBody properties (stored_volatiles, materials, crust_composition)
- Creates deposits with quantity constrained by stored_volatiles max
- Sets equipment_tier_required based on deposit type
- Sets initial status based on equipment_tier (unknown vs detected)
- Persists to ResourceDeposit model

### File 2: PlausibilityEngine (if not data-driven)
**Location**: `galaxy_game/app/services/ai_manager/plausibility_engine.rb`

**Methods** (pending design approval):
```ruby
def viable_deposits_for_body(celestial_body)
  # Returns Hash with rules for each deposit type
  # Example: { water_ice: { max_count: 12, equipment_tier: 1 }, ... }
end

def deposits_for_equipment_tier(celestial_body, tier:)
  # Filter viable deposits to those accessible with given tier
end

def estimate_deposit_count(resource_type, celestial_body, stored_volatile_amount:)
  # Map stored_volatile amount to number of spawnable deposits
end
```

### File 3: Specs
**Location**: `galaxy_game/spec/services/ai_manager/deposit_spawner_spec.rb`

**Test Scenarios** (pending design approval):
- Spawn deposits for known body (Luna) with real scientific data
- Spawn deposits for generated world with synthetic properties
- Respect equipment tier gating (tier 0 sees only surface resources)
- Respect stored_volatiles constraint (can't spawn more than exists)
- Handle bodies with no materials data (fallback behavior)
- Survey reveals new deposits
- Settlement spawns nearby resources
- Multiple calls don't duplicate deposits

---

## Acceptance Criteria

- [ ] DepositSpawner creates deposits for Luna respecting stored_volatiles bounds
- [ ] Equipment tier gating works (tier 0 < tier 1 < tier 2)
- [ ] Plausibility rules enforce geological constraints
- [ ] Spawned deposits have correct status (unknown vs detected)
- [ ] Specs pass with > 80% coverage for spawning logic
- [ ] No regressions in ResourcePositioningService
- [ ] Works with ResourceDeposit model (see separate task)
- [ ] Performance: spawn_all_bodies completes in < 5 seconds

---

## Related Tasks (Implementation Sequence)

1. ✅ ResourceDeposit Model (separate task - can be done in parallel)
2. ⏳ DepositSpawner Service (this task - BLOCKED until design approval)
3. 🔜 Trigger Integration (when DepositSpawner works)
4. 🔜 TriggerDispatcher (survey/settlement/mission hooks)
5. 🔜 Integration specs (end-to-end spawning workflow)

---

## Stop Conditions

- If PlausibilityEngine design is not approved → STOP
- If DepositSpawner can't respect stored_volatiles bounds → STOP and report
- If specs fail for multiple deposit types → STOP and report coverage gaps
- If performance degrades (> 1s per body) → STOP and optimize

---

## Notes

- DepositSpawner is spawning LOGIC only, not trigger logic
- Triggers (survey, settlement, mission) are implemented separately
- ResourcePositioningService (map-based) is NOT modified
- This service operates at the ResourceDeposit database layer

---

## Status Progression

1. **Current**: BLOCKED - waiting for design approval
2. **After Design**: READY FOR IMPLEMENTATION
3. **After Implementation**: DEPENDS ON TriggerDispatcher
4. **Final**: INTEGRATION + END-TO-END TESTING

