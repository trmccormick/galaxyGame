# TASK: Restore ISRUEvaluator — Remove Hardcoded Constants, Use Live Data Sources
**Status**: ACTIVE
**Priority**: HIGH
**Type**: bug-fix
**Created**: 2026-04-02
**Last Updated**: 2026-04-02

---

## Agent Assignment
**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Architectural reasoning required — touches geosphere,
atmosphere, and unit operational data simultaneously. Multiple data sources,
judgment needed on correct interface design.
**Supervision Level**: 🔴 Watched carefully

---

## Context
`ISRUEvaluator` was built by a previous agent that didn't understand the
existing infrastructure. It hardcodes unit behavior in Ruby constants instead
of reading unit operational data, and hardcodes gas compositions instead of
reading from the live atmosphere and geosphere models.

**This blocks the terraforming simulation from affecting industrial decisions.**
When atmospheric CO2 is depleted by MOXIE units over years of operation,
the evaluator should automatically recommend switching to regolith-based
extraction. It can't do this while reading hardcoded constants.

**Read before starting:**
- `docs/architecture/operations/isru_operations.md` — authoritative agent rules
- `docs/architecture/precursor_mission_bootstrap_architecture.md` — mission context
- `data/json-data/operational_data/units/` — unit operational data structure
- `data/json-data/mission_profiles/planetary_precursor_1.json` — generic mission

---

## Problem Statement

**Current (wrong):**
```ruby
ISRU_UNITS = {
  'PLANETARY_VOLATILES_EXTRACTOR_MK1' => {
    input_rate_kg_per_hour: 5.0,    # Duplicates operational data JSON
    outputs: { water: 0.30 },       # Hardcoded world-specific yield
    power_requirement_kw: 25.0      # Duplicates operational data JSON
  }
}
GAS_COMPOSITION = { hydrogen: 0.50 } # Mars-specific, belongs in geosphere
```

**Correct:**
```ruby
# No constants. Read from live data sources:
# 1. UnitLookupService → unit operational data
# 2. geosphere.crust_composition['volatiles'] → regolith yields
# 3. atmosphere.gases → current atmospheric composition (live state)
```

**Why `atmosphere.gases` not `atmosphere.composition`:**
`gases` is the live simulation state — it changes as MOXIE depletes CO2,
as terraforming adds O2, as outgassing occurs. `composition` is the baseline
snapshot used for reset and StarSim initialization only. Always read `gases`.

---

## Data Sources — All Already Built

### 1. Unit Operational Data
```ruby
Lookup::UnitLookupService.new.find_unit(unit.unit_type)
# Returns full JSON hash: input_resources, output_resources,
# processing_capabilities (with efficiency), operational_properties
```

### 2. Geosphere — Regolith Volatile Yields
```ruby
settlement.celestial_body.geosphere.crust_composition
# => { 'oxides' => {...}, 'volatiles' => { 'H2O' => 2.0, 'CO2' => 1.5, 'SO2' => 0.5 } }
# TEU releases these volatiles when baking regolith
```

### 3. Atmosphere — Current Live Composition
```ruby
settlement.celestial_body.atmosphere.gases.pluck(:name, :percentage).to_h
# => { 'CO2' => 95.32, 'N2' => 2.7, 'Ar' => 1.6 } (Mars baseline)
# This CHANGES over time — terraforming, MOXIE consumption, outgassing
# Always read gases, never read composition field
```

### 4. MaterialPile — Bulk Regolith in SurfaceStorage
```ruby
settlement.surface_storage&.material_piles&.find_by(material_type: 'raw_regolith')&.amount.to_f
# Regolith is never an inventory item — always a MaterialPile
```

---

## Correct Design

### What ISRUEvaluator Should Do
1. Inventory units present at settlement via `UnitLookupService`
2. For each unit, read operational data — inputs, outputs, efficiency, power
3. Check what inputs are available:
   - Regolith from `MaterialPile`
   - Atmospheric gases from `atmosphere.gases` (live)
   - Geosphere volatiles from `geosphere.crust_composition` (TEU yield)
4. Calculate throughput at each stage from operational data rates
5. Check power as a **hard gate** — insufficient power blocks ISRU entirely
6. Identify bottleneck stage
7. Return evaluation: capacity, bottleneck, recommendations

### Power Is a Hard Gate
```ruby
# WRONG — power as weighted score
power_score = [power_capacity / required_power.to_f, 1.0].min
scores << power_score

# CORRECT — power as hard gate
return { status: :blocked, reason: :insufficient_power } if power_capacity < required_power
```

### Unit Inventory Without Hardcoded Keys
```ruby
def inventory_isru_units
  # Get all processing units at this settlement
  processing_units = @settlement.base_units
                                .select(&:operational?)
                                .group_by(&:unit_type)
                                .transform_values(&:count)

  # Load operational data for each unit type present
  processing_units.each_with_object({}) do |(unit_type, count), h|
    operational_data = Lookup::UnitLookupService.new.find_unit(unit_type)
    next unless operational_data&.dig('processing_capabilities',
                                      'geosphere_processing', 'enabled')
    h[unit_type] = { count: count, operational_data: operational_data }
  end
end
```

### Resource Availability From Live Sources
```ruby
def assess_resource_availability
  geosphere  = @settlement.celestial_body&.geosphere
  atmosphere = @settlement.celestial_body&.atmosphere

  {
    raw_regolith: @settlement.surface_storage
                             &.material_piles
                             &.find_by(material_type: 'raw_regolith')
                             &.amount.to_f || 0,
    regolith_volatiles: geosphere&.crust_composition&.dig('volatiles') || {},
    atmospheric_gases:  atmosphere&.gases
                                  &.pluck(:name, :percentage)
                                  &.to_h || {}
  }
end
```

---

## Files Involved

### Primary Files — you will rewrite
| File | Change |
|------|--------|
| `app/services/ai_manager/isru_evaluator.rb` | Remove constants, implement live data reads |
| `spec/services/ai_manager/isru_evaluator_spec.rb` | Rewrite to test correct interface |

### Reference Files — read, do not edit
| File | Why |
|------|-----|
| `app/services/lookup/unit_lookup_service.rb` | How to load unit operational data |
| `app/models/celestial_bodies/spheres/geosphere.rb` | `crust_composition` structure |
| `app/models/celestial_bodies/spheres/atmosphere.rb` | `gases` association — live state |
| `app/models/celestial_bodies/celestial_body.rb` | Association chain |
| `app/models/settlement/base_settlement.rb` | `delegate :celestial_body` |
| `app/models/storage/material_pile.rb` | Regolith storage model |
| `app/models/units/base_unit.rb` | `operational?` method |

---

## Implementation Steps

### Step 1 — Audit blast radius
```bash
grep -rn "ISRUEvaluator\|ISRU_UNITS\|GAS_COMPOSITION" app/ spec/ \
  --include="*.rb" | grep -v "_spec.rb" | sort
```
Document every caller of the evaluator. Confirm no callers depend on
the constant structure being removed.

### Step 2 — Verify data chain resolves
```bash
docker exec -it web bash -c "unset DATABASE_URL && RAILS_ENV=test bundle exec rails runner '
  s = Settlement::BaseSettlement.first
  puts s.celestial_body&.geosphere&.crust_composition.inspect
  puts s.celestial_body&.atmosphere&.gases&.pluck(:name, :percentage).inspect
'"
```
Confirm both chains resolve. If either returns nil, check factory setup
before proceeding — the spec will need factories that provide these.

### Step 3 — Check factory chain for specs
```bash
grep -rn "celestial_body\|geosphere\|atmosphere\|gases" spec/factories/ \
  --include="*.rb" | head -20
```
Confirm spec factories provide a settlement with celestial body that has
both geosphere and atmosphere with gases. If not, a factory trait will
need to be added — flag this in synthesis report.

### Step 4 — Produce Synthesis Report and STOP

```
BLAST RADIUS
Callers outside spec files: [list]
Safe to remove ISRU_UNITS constant: [yes/no]

DATA CHAIN
geosphere.crust_composition resolves: [yes/no]
atmosphere.gases resolves: [yes/no]
Factory provides both: [yes/no — if no, describe what's needed]

CONSTANTS TO REMOVE
[list each constant and confirm it has no external callers]

PROPOSED INTERFACE
assess_capabilities: [one paragraph]
assess_resource_availability: [one paragraph]
inventory_isru_units: [one paragraph]
power check: [hard gate vs weighted score]

SPEC REWRITE APPROACH
[what the new spec will test, what factories it needs]

READY TO APPLY? — waiting for approval
```

### Step 5 — Rewrite evaluator (after approval)
Remove: `ISRU_UNITS`, `GAS_COMPOSITION` constants
Remove: All methods that reference these constants directly
Implement: `inventory_isru_units` using `UnitLookupService`
Implement: `assess_resource_availability` using live geosphere + atmosphere
Implement: Power as hard gate
Keep: Public method signatures where possible to minimize caller changes

### Step 6 — Rewrite spec
Test the correct interface:
- Settlement with celestial body that has geosphere + atmosphere with gases
- Unit inventory reads from `UnitLookupService` not constants
- Resource availability reads from live geosphere + atmosphere
- Power insufficient → blocked, not just low score
- Different world compositions produce different yields

### Step 7 — Verify isolation
```bash
docker exec -it web bash -c "unset DATABASE_URL && RAILS_ENV=test bundle exec \
  rspec spec/services/ai_manager/isru_evaluator_spec.rb \
  --format documentation 2>&1 | tail -40"
```

### Step 8 — Regression check
```bash
docker exec -it web bash -c "unset DATABASE_URL && RAILS_ENV=test bundle exec \
  rspec spec/services/ai_manager/ spec/models/ 2>&1 | tail -20"
```

---

## Acceptance Criteria
- [ ] `ISRU_UNITS` constant removed
- [ ] `GAS_COMPOSITION` constant removed
- [ ] `inventory_isru_units` uses `UnitLookupService`
- [ ] `assess_resource_availability` reads from `atmosphere.gases` (live)
- [ ] `assess_resource_availability` reads from `geosphere.crust_composition`
- [ ] Power is a hard gate — insufficient power returns blocked status
- [ ] Spec tests generic interface with real data sources
- [ ] Isolation run: 0 failures
- [ ] No regressions in ai_manager specs
- [ ] Different world compositions produce different evaluation results

---

## Stop Conditions — escalate immediately if:
- Blast radius shows callers that depend on `ISRU_UNITS` constant structure
- `atmosphere.gases` returns nil for test settlements — factory issue
- `geosphere.crust_composition` returns nil — factory issue
- Any integration spec references the old constant-based interface
- Power gate change breaks any existing passing spec

---

## Commit Instructions
Run on HOST after confirmed 0 failures:
```bash
git add app/services/ai_manager/isru_evaluator.rb \
        spec/services/ai_manager/isru_evaluator_spec.rb
git commit -m "fix: restore ISRUEvaluator — remove hardcoded constants, read from live geosphere/atmosphere/UnitLookupService"
git push
```

---

## Dependencies
**Blocked by**: `isru_operations.md` committed (in progress)
**Blocks**: `ISRUOptimizer` review (likely same pattern)
**Related tasks**:
- `2026-04-01-HIGH-BUG-FIX-RESTORE-MATERIAL-PROCESSING-SERVICE-INTENDED-DESIGN.md`
- Escalation service fix (existing backlog task)

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
