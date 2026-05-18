---
status: ready-for-implementation
priority: MEDIUM
type: implementation
system_domain: AI_MANAGER
parent_task: AI Manager Resource Spawning System (2026-05-01)
created: 2026-05-18
depends_on: 2026-05-18-DESIGN-Resource-Deposit-Model-And-Persistence.md
assigned_to: GPT-4.1
---

# IMPL: Create ResourceDeposit Model and Migrations

**Status**: READY FOR IMPLEMENTATION (after design approval)  
**Priority**: MEDIUM  
**Type**: implementation  
**Parent**: AI Manager Resource Spawning System  
**Depends On**: Design approval for Resource Deposit Model  
**Assigned To**: GPT-4.1

---

## Objective

Create the database model and persistence layer for spawned resource deposits, including:
- Migration for `resource_deposits` table
- `ResourceDeposit` model with relationships
- Factory for testing
- Validation specs

---

## Constraint

- Do NOT modify ResourcePositioningService (use it as-is)
- Do NOT create spawning logic yet (that's a separate implementation task)
- Focus ONLY on the model and persistence layer
- Model should be agnostic to trigger system (that comes later)

---

## Implementation Files

### File 1: Database Migration
**Location**: `galaxy_game/db/migrate/[timestamp]_create_resource_deposits.rb`

**Requirements** (pending design approval):
- Table: `resource_deposits`
- Foreign keys: `celestial_body_id`, `settlement_id`, `geological_feature_id` (polymorphic?)
- Attributes: resource_type, quantity, location (lat/long or hex), depth, equipment_tier_required, discovered_at, surveyed_at, status
- Timestamps: created_at, updated_at, discovered_at, surveyed_at
- Indexes: (celestial_body_id, resource_type), (status), (discovered_at)

### File 2: Model
**Location**: `galaxy_game/app/models/resource_deposit.rb`

**Requirements** (pending design approval):
- Belongs to: CelestialBody (required), optionally Settlement or GeologicalFeature
- Scopes: by_resource_type, discovered, surveyed, active, by_equipment_tier
- Methods: discover!, survey!, deplete!, accessible_by_equipment_tier?
- Validations: presence of resource_type, quantity, celestial_body_id
- Callbacks: set_defaults (status: 'unknown', discovered_at: nil)

### File 3: Factory
**Location**: `galaxy_game/spec/factories/resource_deposit_factory.rb`

**Requirements**:
- Traits: water_ice, regolith, rare_metals, clathrates, geothermal
- Traits: discovered, surveyed, depleted
- Traits: tier_0, tier_1, tier_2
- Associations: lunar_deposit, martian_deposit, generated_world_deposit

### File 4: Specs
**Location**: `galaxy_game/spec/models/resource_deposit_spec.rb`

**Requirements**:
- Presence validations
- Relationship specs (belongs_to celestial_body)
- Scope specs (discovered, surveyed, active)
- Method specs (discover!, survey!, accessible_by_equipment_tier?)
- Status transition specs

---

## Acceptance Criteria

- [ ] Migration creates resource_deposits table with all required attributes
- [ ] ResourceDeposit model loads without errors
- [ ] Model associations work (belongs_to CelestialBody)
- [ ] Factory creates all trait combinations
- [ ] All model specs pass
- [ ] Model is database-agnostic (no spawning logic)
- [ ] No regressions in existing specs

---

## Example Usage (for reference)

```ruby
# Create a deposit
deposit = ResourceDeposit.create!(
  celestial_body: luna,
  resource_type: 'water_ice',
  quantity: 1_000_000,
  latitude: -89.2,
  longitude: 0,
  depth: 50,
  equipment_tier_required: 1,
  status: 'unknown'
)

# Discover it
deposit.discover!

# Check accessibility
deposit.accessible_by_equipment_tier?(1) # => true
deposit.accessible_by_equipment_tier?(0) # => false

# Query
ResourceDeposit.discovered.where(resource_type: 'water_ice')
ResourceDeposit.by_equipment_tier(1)
```

---

## Stop Conditions

- If design approval is not received by planned date, STOP and request approval
- If relationship structure differs significantly from proposed design, STOP and report
- If migration fails in test environment, STOP and provide error trace

---

## Notes

- Model is framework for spawning system, not the spawning itself
- Trigger system and plausibility engine come as separate implementations
- ResourcePositioningService will be adapted to use this model in later task

