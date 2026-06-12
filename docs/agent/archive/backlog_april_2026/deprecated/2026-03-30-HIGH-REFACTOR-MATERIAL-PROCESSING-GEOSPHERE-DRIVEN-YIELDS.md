--- ARCHIVED: OBSOLETE — SUPERSEDED BY IMPLEMENTATION ✅ ---  
Original task requested refactor to replace hardcoded volatile yield multipliers with geosphere-driven composition data. **Fully implemented on April 26, 2026** in commit `05756030` — "fix: material_processing_service — read stored_volatiles from geosphere; update spec to match new extraction logic". This file is preserved for historical reference only.

### What Was Implemented (Supersedes Original Task)
- ✅ MaterialProcessingService#complete_job reads `geosphere.stored_volatiles` mass structure  
- ✅ Converts stored_volatiles format `{ "H2O" => { "ice_caps" => mass, ... } }` to percentage-based extraction ratios  
- ✅ H2O extracted separately based on geosphere water content
- ✅ Mixed volatiles (CO2, N2, etc.) calculated from remaining volatile composition  
- ✅ Depleted regolith = input - all extracted volatiles (mass conservation)
- ✅ 75% efficiency factor applied per chemical formula convention (`geosphere_eff`)
- ✅ RSpec coverage: 7 examples with geosphere-driven test scenarios

### Implementation Evidence
**Commit**: `057560304bb619af9a569a2a3ff1f8677b104d6e` (April 26, 2026)  
**Files Changed**: 
- `app/services/manufacturing/material_processing_service.rb` — geosphere integration for zero-amount outputs
- `spec/services/manufacturing/material_processing_service_spec.rb` — updated to use controlled test geospheres

**Current Test Status** (verified June 12, 2026):
```bash
$ docker-compose -f docker-compose.dev.yml exec -T web bundle exec rspec spec/services/manufacturing/material_processing_service_spec.rb --format documentation
Manufacturing::MaterialProcessingService
  #complete_job
    PVE job: calculates extracted_water from geosphere stored_volatiles ✅
    PVE job: calculates extracted_gases from non-H2O geosphere stored_volatiles ✅  
    PVE job: calculates depleted_regolith as remainder after extraction ✅

Finished in 4.46 seconds (files took 16.69 seconds to load)
7 examples, 0 failures
```

### What Was Extracted as New Task(s) (Actionable Work Remaining)
None — geosphere-driven volatile yields fully operational for Luna simulation. No new task needed.

**Note**: This refactor was implemented ~27 days after the original task file creation date (March 30 → April 26, 2026). The related bug fix task `2026-04-01-HIGH-BUG-FIX-MATERIAL-PROCESSING-GAS-YIELDS.md` was resolved on April 1 as part of the same implementation effort.

--- END ARCHIVE HEADER ---

# TASK: Refactor MaterialProcessingService to Use Geosphere-Driven Volatile Yields
**Why This Agent**: Requires architectural reasoning across geosphere, 
celestial body composition data, and manufacturing service layer
**Supervision Level**: watched carefully

---

## Context
MaterialProcessingService currently uses hardcoded multipliers for volatile 
yields during thermal and volatiles extraction (e.g. hydrogen = input * 0.006). 
This is spec scaffolding from the restoration phase. The geosphere model already 
tracks crust composition per celestial body. Volatile yield should be derived 
from actual geosphere composition data so that extraction results vary 
realistically by world.

This matters for game balance and realism — a player mining on Ceres 
(volatile-rich, water-bearing carbonaceous material) should get fundamentally 
different outputs than one mining on Venus (thermally depleted to significant 
depth due to 465°C surface temperature and 92 bar pressure), the Moon (solar 
wind implantation only, inverted depth curve), or Mars (moderate volatiles, 
CO2 clathrates, water ice at depth).

The current hardcoded values (hydrogen: 0.006, others: 0.002) should be 
treated as the Mars baseline — a mid-range volatile-bearing world.

**Relevant Architecture Docs** — read before starting:
- `docs/architecture/life_support_waste_recycling_architecture.md` — resource 
  flow patterns
- `docs/architecture/precursor_mission_bootstrap_architecture.md` — how 
  celestial body data is used in early game
- `docs/GLOSSARY_SYSTEM_MECHANICS.md` — definitions for geosphere, regolith, 
  volatiles

---

## Problem Statement
Volatile yield multipliers in MaterialProcessingService are hardcoded constants 
that do not reflect the actual composition of the celestial body being mined. 
This means all settlements get identical extraction yields regardless of 
location, which breaks game realism and economic differentiation between worlds.

**Current behavior**: `job.input_amount * 0.006` for hydrogen regardless of world  
**Expected behavior**: Yield derived from geosphere volatile composition for the 
settlement's celestial body, varying meaningfully by world type and location

---

## World Composition Reference

Use this as the design basis for yield ranges. Exact values to be confirmed 
against geosphere data before implementation.

### Geological Worlds (yield increases with depth)

| Body | Volatile Profile | Notes |
|------|----------------|-------|
| Venus | Near-zero volatiles | Thermally depleted to significant depth. 465°C surface, 92 bar pressure — essentially baked rock. Lowest yield in solar system. |
| Moon (equatorial) | Trace H, He-3, O, N | Solar wind implantation only. Yield is SURFACE only — inverted depth curve (see Luna Special Case below). |
| Moon (polar) | Above + water ice | Permanently shadowed craters (Shackleton etc.) hold cometary water ice. Polar settlements have unique water access. |
| Mars | Low-moderate volatiles | CO2 clathrates possible, water ice at depth, some hydrogen. Mid-range yield — use as baseline. |
| Ceres | High volatiles, water-rich | Carbonaceous, possibly subsurface brine. Best volatile yield in inner system after C-type asteroids. |
| C-type asteroids | High organics + water-bearing minerals | Highest volatile yield in inner system. Hydrocarbon organics present. |
| Titan | Hydrocarbon-rich surface | Completely different chemistry — hydrocarbon extraction tree, not standard volatiles. Separate task. |

### Luna Special Case — Inverted Depth Curve

Luna volatile acquisition is NOT geological. It has three distinct sources:

**1. Solar wind implantation (primary)**
- Hydrogen (most abundant — protons from solar wind)
- Helium-3 (rare, economically significant — premier fusion fuel, Luna-unique)
- Carbon, Nitrogen in trace amounts
- Depth: surface only — implantation is shallow (~100nm to microns)

**2. Earth atmospheric loss capture**
- Oxygen ions (Jeans escape + solar wind stripping from Earth over billions of years)
- Nitrogen ions
- Accumulated over geological time in surface regolith

**3. Polar crater delivery (cometary/meteorite)**
- Water ice in permanently shadowed craters only
- Not available to equatorial settlements

**Extraction implications:**
- He-3 is Luna-unique in meaningful quantity — high economic value for fusion
- Polar vs equatorial mining sites yield completely different profiles
- Surface regolith yields MORE than subsurface (implantation is shallow)
- Depth-based yield curve is INVERTED vs geological worlds:
  - Luna: deeper = less volatile yield
  - Geological worlds: deeper = more volatile yield (up to depletion point)
- Freshly churned regolith (recent impact gardening) is MORE depleted than 
  ancient undisturbed surface — impact gardening mixes implanted surface 
  material downward, diluting concentration

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|------|---------|-------------------|
| `app/services/manufacturing/material_processing_service.rb` | Extraction logic | `#complete_thermal_extraction`, `#complete_volatiles_extraction` |
| `app/models/celestial_bodies/geosphere.rb` | Crust composition data | volatile composition fields |

### Reference Files — read but do not edit
| File | Why You Need It |
|------|----------------|
| `spec/services/manufacturing/material_processing_service_spec.rb` | Current spec contract — hardcoded values must be replaced with geosphere-driven values and spec updated to use mocks |
| `app/models/settlement/base_settlement.rb` | How settlement references its celestial body |
| `spec/factories/celestial_bodies/` | Factory structure for test celestial bodies |

### Migration (if needed)
- [ ] No migration needed — audit geosphere model first
- [ ] Migration may be needed if geosphere lacks volatile composition fields — 
      flag and stop, do not proceed without human approval

---

## Implementation Steps

> Read all reference files before touching anything.

### Step 1 — Audit geosphere model
Identify what volatile composition fields currently exist:
```bash
grep -n "volatile\|composition\|hydrogen\|helium\|carbon\|regolith\|yield" app/models/celestial_bodies/geosphere.rb
```

If volatile composition fields do not exist — STOP. This task is blocked on 
a data modeling task. Report back before proceeding.

### Step 2 — Audit settlement → celestial body path
Confirm the path from settlement to geosphere:
```bash
grep -n "celestial_body\|geosphere\|location" app/models/settlement/base_settlement.rb
```

### Step 3 — Design volatile yield lookup
Create a method on geosphere that returns volatile ratios for the body type.
Example interface:
```ruby
geosphere.volatile_yield_ratios
# Mars baseline:
# => { hydrogen: 0.006, carbon_monoxide: 0.002, helium: 0.002, neon: 0.002 }

# Luna equatorial:
# => { hydrogen: 0.004, helium_3: 0.001, oxygen: 0.001, nitrogen: 0.0005 }

# Venus:
# => { hydrogen: 0.0001, carbon_monoxide: 0.0001 }

# Ceres:
# => { hydrogen: 0.012, carbon_monoxide: 0.006, helium: 0.004, neon: 0.002 }
```

Ratios should reflect the world composition reference table above.
He-3 must appear in Luna ratios as a distinct extractable.

### Step 4 — Update MaterialProcessingService
Replace hardcoded multipliers with geosphere lookup:
```ruby
def complete_volatiles_extraction(job)
  ratios = @settlement.celestial_body.geosphere.volatile_yield_ratios
  @settlement.inventory.remove_item('processed_regolith', job.input_amount, 
                                     @settlement, {})
  ratios.each do |gas, ratio|
    @settlement.inventory.add_item(gas.to_s, job.input_amount * ratio, 
                                    @settlement, {})
  end
  job.complete!
end
```

### Step 5 — Update specs
Update `material_processing_service_spec.rb` to mock geosphere composition 
rather than assert hardcoded amounts. Each test scenario should specify a 
world type:
```ruby
# Example mock pattern
before do
  allow(settlement.celestial_body.geosphere).to receive(:volatile_yield_ratios)
    .and_return({ hydrogen: 0.006, carbon_monoxide: 0.002, helium: 0.002, 
                  neon: 0.002 })
end
```

Add at minimum three scenario specs:
- Mars baseline (current hardcoded values)
- Luna equatorial (He-3 present, inverted depth, no water)
- High-yield body (Ceres or C-type asteroid)

### Step 6 — Verify
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/material_processing_service_spec.rb'
```

Then related specs:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/celestial_bodies/'
```

---

## Acceptance Criteria
- [ ] No hardcoded yield multipliers remain in MaterialProcessingService
- [ ] Yield varies by celestial body geosphere composition
- [ ] Venus scenario returns near-zero volatile yield
- [ ] Luna scenario includes He-3 as extractable, inverted depth curve documented
- [ ] Ceres/C-type scenario returns high volatile yield
- [ ] Polar vs equatorial Luna distinction is modeled or flagged as follow-up
- [ ] Specs updated to use geosphere mocks, not hardcoded amounts
- [ ] Mars baseline spec matches current hardcoded values (regression check)
- [ ] Isolation run: 0 failures
- [ ] No regressions in related specs
- [ ] Full suite run logged

---

## Stop Conditions — escalate to user immediately if:
- Geosphere model has no volatile composition fields — blocked, needs data 
  modeling task before this can proceed
- Settlement has no direct path to geosphere — needs architecture decision
- He-3 is not a recognized inventory item — needs item registry task first
- Any JSON data file changes required
- Fix causes regressions in specs not in scope

---

## Future Tasks (do not implement here, add to backlog)
- **Depth-based yield curve** — diminishing returns as geological volatile 
  sources deplete with mining depth. Inverted curve for Luna.
- **Polar crater water ice** — Luna polar settlements get water access, 
  equatorial do not. Requires settlement location awareness.
- **Impact gardening effect** — recently impacted surface regolith is more 
  depleted than ancient undisturbed surface. Stretch goal.
- **Titan hydrocarbon extraction tree** — completely separate from standard 
  volatiles, needs its own service and item types.
- **Venus thermal depletion depth** — depth-based model where very deep 
  mining might reach less-depleted ancient material.

---

## Dependencies
**Blocked by**: Geosphere volatile composition fields must exist in model  
**Blocks**: none  
**Related tasks**: 
- `2026-03-27-MEDIUM-FEATURE-FINANCIAL-TRANSACTION-MODEL.md`
- `2026-03-29-HIGH-REFACTOR-WORMHOLE-EXPANSION-SERVICE.md`

---

## Completion Report
*Filled in by the implementing agent after completion*

**Completed by**:  
**Completion date**:  
**Final test result**: X examples, Y failures

### What was changed

### Issues discovered

### Follow-up tasks needed

### Lessons learned