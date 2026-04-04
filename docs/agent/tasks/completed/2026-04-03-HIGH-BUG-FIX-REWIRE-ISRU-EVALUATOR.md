# TASK: Rewire ISRUEvaluator — Remove Hardcoded Constants, Wire to Real Services
**Status**: ACTIVE
**Priority**: HIGH
**Type**: bug-fix
**Created**: 2026-04-03
**Last Updated**: 2026-04-03

---

## Agent Assignment
**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Multiple live data sources, architectural reasoning required.
Touches buy order queue, geosphere, atmosphere, and unit operational data simultaneously.
**Supervision Level**: 🔴 Watched carefully

---

## Context
`ISRUEvaluator` was written by an agent that understood the game mechanics
correctly but didn't find the existing services to delegate to. The ISRU
readiness logic, production rate calculations, and Luna capability checks
are real and worth keeping. The problem is the data sources — hardcoded
constants instead of live models.

**This is a REWIRE, not a rewrite from scratch.**
- Keep the structure and logic intent
- Remove the hardcoded data sources
- Wire each data dependency to the correct real service or model

**Complete `2026-04-03-CRITICAL-BUG-FIX-STATE-ANALYZER-REMOVE-RESOURCE-PROFILE.md` first.**
That task is already complete as of 2026-04-03.

**Mandatory reading before touching anything:**
- `galaxyGame/docs/architecture/ai_manager/AI_MANAGER_COMMAND.md`
- `galaxyGame/docs/architecture/ai_manager/AI_MANAGER_ROLE.md`
- `galaxyGame/docs/architecture/operations/isru_operations.md`
- `galaxyGame/docs/agent/README.md`

**Also read before starting:**
- `app/services/ai_manager/precursor_capability_service.rb` — already does
  data-driven ISRU capability checks via celestial_body, may overlap with
  what ISRUEvaluator needs
- `app/services/ai_manager/resource_flow_simulator.rb` — contains
  RESOURCE_CHAINS with TEU→PVE dependency chain logic, extract this
  before it gets archived

**The full Luna dependency chain this must support:**
```
Luna ISRU (correct)
  → regolith → water, O2, raw materials
    → manufacturing: I-beams, regolith panels
      → lava tube settlement (worldhouse)
        → L1 station components (same pipeline)
          → Structures::SpaceStation
            → Settlement::OrbitalSettlement at L1
              → cyclers → tugs → Mars
```

---

## Problem Statement

Three hardcoded data sources need to be replaced with real model reads.
The logic that uses them is largely correct and should be preserved.

### Replace 1 — ISRU_UNITS constant
```ruby
# WRONG — duplicates and diverges from operational data JSON
ISRU_UNITS = {
  'PLANETARY_VOLATILES_EXTRACTOR_MK1' => {
    input_rate_kg_per_hour: 5.0,
    power_requirement_kw: 25.0,
    outputs: { water: 0.30 }
  }
}

# CORRECT — read from UnitLookupService
Lookup::UnitLookupService.new.find_unit(unit.unit_type)
# Returns full JSON: input_resources, output_resources,
# processing_capabilities, operational_properties
```

### Replace 2 — GAS_COMPOSITION constant
```ruby
# WRONG — Mars-specific, static, ignores terraforming changes
GAS_COMPOSITION = { hydrogen: 0.50, carbon_monoxide: 0.25 }

# CORRECT — live atmospheric state
settlement.celestial_body.atmosphere.gases.pluck(:name, :percentage).to_h
# Changes over time as MOXIE depletes CO2, terraforming adds O2
```

### Replace 3 — Power as weighted score
```ruby
# WRONG — low power just lowers the score
power_score = [power_capacity / required_power.to_f, 1.0].min

# CORRECT — power is a hard gate
return { status: :blocked, reason: :insufficient_power } if power_capacity < required_power
```

### Replace 4 — Unit inventory filtered by hardcoded keys
```ruby
# WRONG — invisible to any unit type not in the constant
@settlement.base_units.where(unit_type: ISRU_UNITS.keys)

# CORRECT — all processing-capable units via UnitLookupService
@settlement.base_units.select(&:operational?).each_with_object({}) do |unit, h|
  data = Lookup::UnitLookupService.new.find_unit(unit.unit_type)
  next unless data&.dig('processing_capabilities', 'geosphere_processing', 'enabled')
  h[unit.unit_type] ||= { count: 0, operational_data: data }
  h[unit.unit_type][:count] += 1
end
```

### Replace 5 — Power output hardcoded per unit type
```ruby
# WRONG
when 'SOLAR_PANEL_ARRAY' then 10.0
when 'NUCLEAR_REACTOR_MK1' then 100.0

# CORRECT
Lookup::UnitLookupService.new.find_unit(unit.unit_type)
  &.dig('operational_properties', 'power_output_kw').to_f
```

### Replace 6 — Resource availability reads wrong models
```ruby
# WRONG — CO2 and ice are not inventory items
co2: inventory.items.find_by(name: 'carbon_dioxide')&.amount
ice: inventory.items.find_by(name: 'water_ice')&.amount

# CORRECT
{
  raw_regolith:       settlement.surface_storage
                               &.material_piles
                               &.find_by(material_type: 'raw_regolith')
                               &.amount.to_f || 0,
  regolith_volatiles: settlement.celestial_body
                               &.geosphere
                               &.crust_composition
                               &.dig('volatiles') || {},
  atmospheric_gases:  settlement.celestial_body
                               &.atmosphere
                               &.gases
                               &.pluck(:name, :percentage)
                               &.to_h || {}
}
```

---

## Files Involved

### Primary Files — you will edit
| File | Change |
|---|---|
| `app/services/ai_manager/isru_evaluator.rb` | Remove constants, wire to real services |
| `spec/services/ai_manager/isru_evaluator_spec.rb` | Update to test real interfaces |

### Read Before Starting — do not edit
| File | Why |
|---|---|
| `app/services/ai_manager/precursor_capability_service.rb` | Already data-driven via celestial_body — understand before duplicating |
| `app/services/ai_manager/resource_flow_simulator.rb` | TEU→PVE chain in RESOURCE_CHAINS — read this |
| `app/services/lookup/unit_lookup_service.rb` | How to load unit operational data |
| `app/models/market/order.rb` | Buy order model |
| `app/models/celestial_bodies/spheres/geosphere.rb` | crust_composition structure |
| `app/models/celestial_bodies/spheres/atmosphere.rb` | gases association — live state |
| `app/models/settlement/base_settlement.rb` | delegate :surface_storage line 43 |
| `app/models/storage/material_pile.rb` | Regolith storage model |
| `app/models/units/base_unit.rb` | operational? method |
| `app/services/ai_manager/task_execution_engine.rb` | Proven working pattern |

---

## Implementation Steps

> Read ALL reference files before writing anything.
> Do not apply any fix before Synthesis Report is approved.

### Step 1 — Read precursor_capability_service first
```bash
cat galaxy_game/app/services/ai_manager/precursor_capability_service.rb
```
This may already handle some of what ISRUEvaluator does. Document any overlap
in your Synthesis Report — do not duplicate logic that already exists.

### Step 2 — Read resource_flow_simulator RESOURCE_CHAINS
```bash
grep -n "RESOURCE_CHAINS\|TEU\|PVE\|thermal_extraction\|planetary_volatiles" \
  galaxy_game/app/services/ai_manager/resource_flow_simulator.rb
```
Note the TEU→PVE dependency chain. This logic belongs in the evaluator
and the escalation service — capture it before it gets archived.

### Step 3 — Blast radius audit
```bash
grep -rn "ISRUEvaluator\|isru_evaluator" galaxy_game/app/ galaxy_game/spec/ \
  --include="*.rb" | grep -v "ai_manager/" | grep -v "_spec.rb"

grep -n "ISRU_UNITS\|GAS_COMPOSITION\|resource_profile\|power_score\|water_ice" \
  galaxy_game/app/services/ai_manager/isru_evaluator.rb
```

### Step 4 — Verify data chain resolves in test context
```bash
grep -rn "celestial_body\|geosphere\|atmosphere\|gases" galaxy_game/spec/factories/ \
  --include="*.rb" | grep -v "terraforming" | head -30

grep -n "order_type\|status\|enum\|scope" galaxy_game/app/models/market/order.rb | head -20
```

### Step 5 — Produce Synthesis Report and STOP

### Step 6 — Rewire evaluator (after approval)

**Remove:**
- `ISRU_UNITS` constant
- `GAS_COMPOSITION` constant
- Hardcoded power output values per unit type
- Inventory item lookups for gases and ice

**Keep and rewire:**
- `assess_capabilities` — keep structure, replace data sources
- `should_use_isru?` — keep logic, wire to buy order queue
- `calculate_production_rates` — keep calculation, read rates from UnitLookupService
- `assess_maintenance_status` — keep logic, remove constant dependency
- `generate_recommendations` — keep logic, remove constant dependency
- `compare_isru_vs_import_cost` — keep if GCC cost data exists in market models

**Do not duplicate** anything already in `precursor_capability_service.rb`.
Call it instead if it already does the work.

### Step 7 — Update spec
Test the rewired interface:
- Settlement with celestial body that has geosphere + atmosphere with gases
- Unit inventory reads from UnitLookupService
- Resource availability reads from live geosphere + atmosphere
- Power insufficient → `{ status: :blocked, reason: :insufficient_power }`
- Different world compositions produce different results
- Unfilled buy orders for water trigger correct assessment

### Step 8 — Isolation run
```bash
docker exec -it web bash -c "unset DATABASE_URL && RAILS_ENV=test bundle exec \
  rspec spec/services/ai_manager/isru_evaluator_spec.rb \
  --format documentation 2>&1 | tail -40"
```

### Step 9 — AI Manager regression check
```bash
docker exec -it web bash -c "unset DATABASE_URL && RAILS_ENV=test bundle exec \
  rspec spec/services/ai_manager/ 2>&1 | tail -20"
```

---

## Synthesis Report Format
```
PRECURSOR_CAPABILITY_SERVICE OVERLAP
Does it already handle ISRU capability checks: [yes/no]
What it covers: [description]
What ISRUEvaluator still needs to do: [description]

RESOURCE_FLOW_SIMULATOR TEU→PVE CHAIN
Key chain logic found: [describe RESOURCE_CHAINS content]
How to incorporate: [description]

BLAST RADIUS
External callers of ISRUEvaluator: [list or "none"]
Safe to remove ISRU_UNITS: [yes/no]
Safe to remove GAS_COMPOSITION: [yes/no]

DATA CHAIN VERIFIED
geosphere.crust_composition resolves: [yes/no]
atmosphere.gases resolves: [yes/no]
Factory provides settlement with celestial body + both: [yes/no — if no, describe gap]
UnitLookupService.find_unit confirmed: [yes/no]

REWIRE PLAN
Methods keeping structure, replacing data: [list]
Methods removing entirely: [list]
Methods delegating to precursor_capability_service: [list or "none"]
Power logic change: [weighted score → hard gate confirmed yes/no]

READY TO APPLY? — waiting for approval
```

---

## What NOT to Do
- Do not rewrite from scratch — rewire the existing logic
- Do not duplicate logic already in `precursor_capability_service.rb`
- Do not add any new hardcoded constants
- Do not read `atmosphere.composition` — always `atmosphere.gases`
- Do not look for CO2 or water_ice in `inventory.items`
- Do not touch `state_analyzer.rb` — already fixed
- Do not touch `isru_optimizer.rb` — separate task
- Do not run the full suite

---

## Acceptance Criteria
- [ ] `ISRU_UNITS` constant removed
- [ ] `GAS_COMPOSITION` constant removed
- [ ] `inventory_isru_units` uses `UnitLookupService` — no hardcoded unit list
- [ ] `assess_resource_availability` reads `atmosphere.gases` (live)
- [ ] `assess_resource_availability` reads `geosphere.crust_composition`
- [ ] `assess_resource_availability` reads `surface_storage.material_piles` for regolith
- [ ] Power is a hard gate — insufficient power returns `{ status: :blocked }`
- [ ] Power output per unit reads from `UnitLookupService` operational data
- [ ] No logic duplicated from `precursor_capability_service.rb`
- [ ] TEU→PVE chain logic from `resource_flow_simulator` incorporated or referenced
- [ ] Isolation run: 0 failures
- [ ] No regressions in `spec/services/ai_manager/`

---

## Stop Conditions — escalate immediately if:
- External callers depend on `ISRU_UNITS` constant structure
- `atmosphere.gases` returns nil in test context — factory issue, stop and report
- `geosphere.crust_composition` returns nil — factory issue, stop and report
- `precursor_capability_service` already fully covers ISRU assessment — flag before proceeding
- Power gate change breaks any currently passing spec

---

## Commit Instructions
Run on HOST after confirmed 0 failures:
```bash
git add galaxy_game/app/services/ai_manager/isru_evaluator.rb \
        galaxy_game/spec/services/ai_manager/isru_evaluator_spec.rb
git commit -m "fix: ISRUEvaluator — rewire to UnitLookupService + live geosphere/atmosphere, remove ISRU_UNITS/GAS_COMPOSITION, power as hard gate"
git push
```

---

## Dependencies
**Blocked by**: `2026-04-03-CRITICAL-BUG-FIX-STATE-ANALYZER-REMOVE-RESOURCE-PROFILE.md` ✅ COMPLETE
**Blocks**: `2026-04-03-HIGH-BUG-FIX-REWIRE-ISRU-OPTIMIZER.md`
**Related tasks**:
- Escalation service rewrite (TEU+PVE chain for Luna water)
- `resource_flow_simulator.rb` archival (read TEU→PVE chain first)

---

## Completion Report
*Filled in by implementing agent after completion*

**Completed by**:
**Completion date**:
**Final test result**: X examples, Y failures

### What was changed
### Issues discovered
### Follow-up tasks needed
### Lessons learned
