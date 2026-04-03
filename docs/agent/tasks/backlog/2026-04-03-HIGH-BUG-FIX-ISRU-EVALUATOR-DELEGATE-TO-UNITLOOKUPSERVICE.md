# TASK: Restore ISRUEvaluator — Remove Hardcoded Constants, Delegate to UnitLookupService + Live Models
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
`ISRUEvaluator` was built by a previous agent that duplicated operational data JSON
into Ruby constants and invented world-specific resource yields in code. This means
the evaluator makes decisions based on stale hardcoded values that will silently
diverge from the actual unit JSON as the game evolves.

The AI Manager's role is to read unfilled buy orders and decide what units to deploy
to fill them. The ISRUEvaluator specifically answers: "Do we have the right ISRU units
deployed to fill this buy order? If not, what should we deploy?" It does not calculate
yields itself — those come from unit operational data JSON via `UnitLookupService`.

**This is the second surgical target in the AI Manager 89→8 refactor.**
Complete `2026-04-03-CRITICAL-BUG-FIX-STATE-ANALYZER-REMOVE-RESOURCE-PROFILE.md` first.

**Mandatory reading before touching anything:**
- `docs/agent/ai_manager/AI_MANAGER_COMMAND.md` — mandatory patterns
- `docs/agent/ai_manager/AI_MANAGER_ROLE.md` — player-first + EAP role
- `docs/architecture/operations/isru_operations.md` — authoritative ISRU agent rules
- `docs/agent/README.md` — project rules

**The full Luna dependency chain this must support:**
```
Luna ISRU (correct) → regolith → water, O2, raw materials
  → manufacturing: I-beams, regolith panels
    → lava tube settlement (worldhouse)
      → L1 station components (same manufacturing pipeline)
        → Settlement::OrbitalSettlement at L1
          → cyclers → tugs → Mars expansion
```

If ISRUEvaluator reads hardcoded constants, this entire chain is built on fiction.

---

## Problem Statement

**Three classes of damage in `app/services/ai_manager/isru_evaluator.rb`:**

### Damage 1 — Hardcoded unit constants (duplicate operational data JSON)
```ruby
# WRONG — duplicates and will diverge from JSON
ISRU_UNITS = {
  'PLANETARY_VOLATILES_EXTRACTOR_MK1' => {
    input_rate_kg_per_hour: 5.0,   # already in JSON
    power_requirement_kw: 25.0,    # already in JSON
    outputs: { water: 0.30 }       # world-specific, belongs in geosphere
  }
}
GAS_COMPOSITION = { hydrogen: 0.50 }  # Mars-specific, belongs in live atmosphere
```

### Damage 2 — Power as weighted score instead of hard gate
```ruby
# WRONG — low power just lowers the score
power_score = [power_capacity / required_power.to_f, 1.0].min
scores << power_score

# CORRECT — insufficient power blocks ISRU entirely
return { status: :blocked, reason: :insufficient_power } if power_capacity < required_power
```

### Damage 3 — Unit inventory filtered by hardcoded constant keys
```ruby
# WRONG — invisible to any unit type not in the constant
@settlement.base_units.where(unit_type: ISRU_UNITS.keys)

# CORRECT — all processing-capable units, via UnitLookupService
@settlement.base_units.select(&:operational?).each do |unit|
  data = Lookup::UnitLookupService.new.find_unit(unit.unit_type)
  next unless data&.dig('processing_capabilities', 'geosphere_processing', 'enabled')
  # ... use data
end
```

### Damage 4 — Power output hardcoded per unit type
```ruby
# WRONG
when 'SOLAR_PANEL_ARRAY' then 10.0   # invented kW
when 'NUCLEAR_REACTOR_MK1' then 100.0

# CORRECT — read from operational data JSON
Lookup::UnitLookupService.new.find_unit(unit.unit_type)
  &.dig('operational_properties', 'power_output_kw') || 0
```

### Damage 5 — Resource availability reads from inventory items instead of live models
```ruby
# WRONG — CO2 and atmospheric gases are not inventory items
co2: inventory.items.find_by(name: 'carbon_dioxide')&.amount
ice: inventory.items.find_by(name: 'water_ice')&.amount

# CORRECT — atmospheric gases are live state
atmosphere.gases.pluck(:name, :percentage).to_h
geosphere.crust_composition.dig('volatiles')  # TEU volatile yields
surface_storage&.material_piles&.find_by(material_type: 'raw_regolith')&.amount  # regolith only
```

**Current behavior**: Evaluator reads hardcoded constants, gives wrong answers for any
world that isn't Mars, misses any unit type not in its constant list.
**Expected behavior**: Evaluator reads live geosphere, atmosphere, and unit operational
data. Returns correct assessment for any settlement on any body.

---

## Data Sources — All Already Built

### 1. Buy Order Queue — the canonical trigger
```ruby
Market::Order.where(
  settlement: @settlement,
  order_type: :buy,
  status: :open
)
```

### 2. Unit Operational Data — via UnitLookupService
```ruby
Lookup::UnitLookupService.new.find_unit(unit.unit_type)
# Returns full JSON: input_resources, output_resources,
# processing_capabilities, operational_properties (power_output_kw etc.)
```

### 3. Geosphere — Regolith Volatile Yields
```ruby
@settlement.celestial_body.geosphere.crust_composition
# => { 'oxides' => {...}, 'volatiles' => { 'H2O' => 2.0, 'CO2' => 1.5 } }
# TEU releases these volatiles when baking regolith
```

### 4. Atmosphere — Current Live Composition (NOT baseline)
```ruby
@settlement.celestial_body.atmosphere.gases.pluck(:name, :percentage).to_h
# => { 'CO2' => 95.32, 'N2' => 2.7, 'Ar' => 1.6 }
# This CHANGES over time — terraforming, MOXIE consumption, outgassing
# ALWAYS read gases association. NEVER read composition field.
```

### 5. Regolith — MaterialPile in SurfaceStorage (NOT inventory items)
```ruby
@settlement.surface_storage
           &.material_piles
           &.find_by(material_type: 'raw_regolith')
           &.amount.to_f || 0
```

---

## Files Involved

### Primary Files — you will rewrite
| File | Change |
|---|---|
| `app/services/ai_manager/isru_evaluator.rb` | Remove constants, implement live data reads, power as hard gate |
| `spec/services/ai_manager/isru_evaluator_spec.rb` | Rewrite to test correct interface with live data sources |

### Reference Files — read, do not edit
| File | Why You Need It |
|---|---|
| `app/services/lookup/unit_lookup_service.rb` | How to load unit operational data |
| `app/models/market/order.rb` | Buy order model — primary signal |
| `app/models/celestial_bodies/spheres/geosphere.rb` | `crust_composition` structure |
| `app/models/celestial_bodies/spheres/atmosphere.rb` | `gases` association — live state |
| `app/models/settlement/base_settlement.rb` | `delegate :celestial_body` |
| `app/models/storage/material_pile.rb` | Regolith storage model |
| `app/models/units/base_unit.rb` | `operational?` method |
| `app/services/ai_manager/task_execution_engine.rb` | Proven working pattern — read only |

---

## Implementation Steps

> Read ALL reference files before writing a single line.
> Do not apply any fix before Synthesis Report is approved.

### Step 1 — Blast radius audit
```bash
# Who calls ISRUEvaluator from outside ai_manager/?
grep -rn "ISRUEvaluator\|isru_evaluator" app/ spec/ --include="*.rb" \
  | grep -v "ai_manager/" | grep -v "_spec.rb"

# Confirm damage markers present
grep -n "ISRU_UNITS\|GAS_COMPOSITION\|resource_profile\|power_score\|water_ice\|atmosphere_composition" \
  app/services/ai_manager/isru_evaluator.rb
```

### Step 2 — Verify data chain resolves in test context
```bash
# Check factory provides celestial_body with geosphere + atmosphere
grep -rn "celestial_body\|geosphere\|atmosphere\|gases" spec/factories/ \
  --include="*.rb" | grep -v "terraforming" | head -30

# Confirm Market::Order interface
grep -n "order_type\|status\|enum\|scope" app/models/market/order.rb | head -20

# Confirm UnitLookupService interface
grep -n "def find_unit\|def self\|processing_capabilities" \
  app/services/lookup/unit_lookup_service.rb | head -15
```

### Step 3 — Produce Synthesis Report and STOP

### Step 4 — Rewrite evaluator (after approval)

**Remove entirely:**
- `ISRU_UNITS` constant
- `GAS_COMPOSITION` constant
- All methods that read from these constants directly
- Hardcoded power output values per unit type

**Implement:**

```ruby
def inventory_isru_units
  @settlement.base_units
             .select(&:operational?)
             .each_with_object({}) do |unit, h|
    data = Lookup::UnitLookupService.new.find_unit(unit.unit_type)
    next unless data&.dig('processing_capabilities', 'geosphere_processing', 'enabled')
    h[unit.unit_type] ||= { count: 0, operational_data: data }
    h[unit.unit_type][:count] += 1
  end
end

def assess_resource_availability
  geosphere  = @settlement.celestial_body&.geosphere
  atmosphere = @settlement.celestial_body&.atmosphere
  {
    raw_regolith:       @settlement.surface_storage
                                   &.material_piles
                                   &.find_by(material_type: 'raw_regolith')
                                   &.amount.to_f || 0,
    regolith_volatiles: geosphere&.crust_composition&.dig('volatiles') || {},
    atmospheric_gases:  atmosphere&.gases
                                   &.pluck(:name, :percentage)
                                   &.to_h || {}
  }
end

def assess_power_availability
  @settlement.base_units.select(&:operational?).sum do |unit|
    data = Lookup::UnitLookupService.new.find_unit(unit.unit_type)
    data&.dig('operational_properties', 'power_output_kw').to_f
  end
end
```

**Power gate — replace weighted score:**
```ruby
# In assess_capabilities, before calculating production rates:
required_power = calculate_total_power_requirement(units)
if required_power > 0 && assess_power_availability < required_power
  return {
    status: :blocked,
    reason: :insufficient_power,
    power_available: assess_power_availability,
    power_required: required_power
  }
end
```

**Keep public method signatures** where possible:
- `assess_capabilities` — keep, rewrite internals
- `should_use_isru?` — keep, rewrite to read from buy order queue
- `compare_isru_vs_import_cost` — keep if GCC cost data exists in market models,
  otherwise flag for follow-up and stub with TODO comment

### Step 5 — Rewrite spec
The new spec must test:
- Settlement with celestial body that has geosphere + atmosphere with gases
- Unit inventory reads from `UnitLookupService` (stub or real)
- Resource availability reads from live geosphere + atmosphere
- Power insufficient → returns `{ status: :blocked, reason: :insufficient_power }`
- Different world compositions produce different evaluation results
- Unfilled buy orders for water trigger correct unit deployment recommendation

**If factory for settlement with celestial body + geosphere + atmosphere does not
exist**, document the missing factory in your completion report as a follow-up task.
Do not create the factory in this task.

### Step 6 — Isolation run
```bash
docker exec -it web bash -c "unset DATABASE_URL && RAILS_ENV=test bundle exec \
  rspec spec/services/ai_manager/isru_evaluator_spec.rb \
  --format documentation 2>&1 | tail -40"
```
Expected: 0 failures.

### Step 7 — AI Manager regression check
```bash
docker exec -it web bash -c "unset DATABASE_URL && RAILS_ENV=test bundle exec \
  rspec spec/services/ai_manager/ 2>&1 | tail -20"
```
Report summary line only.

---

## Synthesis Report Format
```
BLAST RADIUS
External callers of ISRUEvaluator: [list or "none"]
Safe to remove ISRU_UNITS: [yes/no — confirm no external callers depend on constant]
Safe to remove GAS_COMPOSITION: [yes/no]

DATA CHAIN VERIFIED
Market::Order buy query: [yes/no]
geosphere.crust_composition resolves: [yes/no]
atmosphere.gases resolves: [yes/no]
Factory provides settlement with celestial body + geosphere + atmosphere: [yes/no — if no, describe gap]
UnitLookupService.find_unit confirmed: [yes/no]

DAMAGE SUMMARY
Constants to remove: [list]
Methods to delete entirely: [list]
Methods to partially rewrite: [list]
Power logic change: weighted score → hard gate [confirmed yes/no]

COST METHODS (compare_isru_vs_import_cost)
GCC cost data available in market models: [yes/no]
Proposed approach: [keep and rewrite / stub with TODO / flag for follow-up]

READY TO APPLY? — waiting for approval
```

---

## What NOT to Do
- Do not add any new hardcoded constants
- Do not read `atmosphere.composition` — always read `atmosphere.gases`
- Do not look for CO2 or water_ice in `inventory.items` — wrong model
- Do not touch `state_analyzer.rb` — separate task
- Do not touch `isru_optimizer.rb` — separate task (delete + rewrite)
- Do not touch any of the 8 core files listed in `AI_MANAGER_ROLE.md`
- Do not run the full suite

---

## Acceptance Criteria
- [ ] `ISRU_UNITS` constant removed
- [ ] `GAS_COMPOSITION` constant removed
- [ ] `inventory_isru_units` uses `UnitLookupService` — no hardcoded unit type list
- [ ] `assess_resource_availability` reads `atmosphere.gases` (live)
- [ ] `assess_resource_availability` reads `geosphere.crust_composition`
- [ ] `assess_resource_availability` reads `surface_storage.material_piles` for regolith
- [ ] Power is a hard gate — insufficient power returns `{ status: :blocked }`
- [ ] Power output per unit reads from `UnitLookupService` operational data
- [ ] Spec tests generic interface with real data sources
- [ ] Isolation run: 0 failures
- [ ] No regressions in `spec/services/ai_manager/`
- [ ] Different world compositions produce different evaluation results

---

## Stop Conditions — escalate immediately if:
- External callers depend on `ISRU_UNITS` constant structure
- `atmosphere.gases` returns nil for test settlements — factory issue, stop and report
- `geosphere.crust_composition` returns nil — factory issue, stop and report
- Power gate change breaks any currently passing spec
- `UnitLookupService.find_unit` returns nil for all unit types — data loading issue
- Any integration spec references the old constant-based interface

---

## Commit Instructions
Run on HOST after confirmed 0 failures:
```bash
git add app/services/ai_manager/isru_evaluator.rb \
        spec/services/ai_manager/isru_evaluator_spec.rb
git commit -m "fix: ISRUEvaluator — remove ISRU_UNITS/GAS_COMPOSITION constants, delegate to UnitLookupService + live geosphere/atmosphere, power as hard gate"
git push
```

---

## Dependencies
**Blocked by**: `2026-04-03-CRITICAL-BUG-FIX-STATE-ANALYZER-REMOVE-RESOURCE-PROFILE.md`
**Blocks**: `2026-04-03-HIGH-BUG-FIX-DELETE-REWRITE-ISRU-OPTIMIZER.md`
**Related tasks**:
- `2026-04-03-HIGH-BUG-FIX-DELETE-REWRITE-ISRU-OPTIMIZER.md`
- Escalation service rewrite (TEU+PVE chain for Luna water)
- `2026-03-31-HIGH-REFACTOR-ORBITAL-SETTLEMENT-ARCHITECTURE.md` (downstream)

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
