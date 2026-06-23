# TASK: Rewrite WormholeExpansionService — AWS Construction Option Evaluation
**Status**: BACKLOG
**Priority**: HIGH
**Type**: refactor
**Created**: 2026-03-29
**Last Updated**: 2026-03-29

---

## Agent Assignment
**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Complex multi-system architectural reasoning — must understand wormhole expansion protocol, AWS construction options, and StationCostBenefitAnalyzer integration
**Supervision Level**: 🟢 Autonomous OK — must stop at Synthesis Report before applying anything

---

## Context
The `WormholeExpansionService` is called when a natural wormhole connection already exists to a system. Its job is to evaluate what AWS (Artificial Wormhole Station) construction strategy is viable given the discovered system's assets. Currently the service checks settlements and colonies — completely wrong domain. The correct logic evaluates system assets (asteroids, moons, local resources, available tugs) and passes construction options to `StationCostBenefitAnalyzer#select_optimal_strategy` which already implements the financial/risk evaluation.

The wormhole is already open when this service runs. The question is not "can we get there" but "what can we build there and is it worth it."

**Relevant Architecture Docs** — read before starting:
- `docs/wormhole_expansion/wh-expansion.md` — full wormhole expansion protocol, Hammer Protocol, AWS construction, ROI thresholds
- `docs/architecture/systems/asteroid_conversion_physics.md` — asteroid conversion mechanics, Rule B hollowing, mass-to-hull efficiency
- `docs/architecture/services/ai_manager/strategy_selector.md` — AI Manager decision framework
- `docs/architecture/services/ai_manager/mission_scorer.md` — scoring and prioritization

---

## Problem Statement
`WormholeExpansionService#find_expansion_opportunities` calls `infrastructure_free_deployment_possible?` which queries settlements via colony traversal — wrong domain, causes `NoMethodError` and `PG::UndefinedColumn` errors.

**Current behavior**: Crashes with column errors, returns wrong data.
**Expected behavior**: Evaluates system assets, generates construction options, passes to `StationCostBenefitAnalyzer`, returns optimal strategy.

---

## The Correct Decision Tree
```
System connected via natural wormhole — AWS needed
    ↓
Option A: Asteroid conversion (preferred — lowest cost)
  - Suitable Phobos-sized asteroid present? (mass, composition check)
  - Tug available with sufficient thrust? (craft inventory)
  - Hollow asteroid for propellant during transit
  - Cycler delivers conversion materials
    ↓
Option B: Luna-type moon base construction
  - Suitable moon present? (celestial body survey)
  - Resources to bootstrap settlement?
  - Manufacture panels/I-beams locally → deliver to AWS site
    ↓
Option C: Earth L1-style imported construction
  - No asteroid, no suitable moon
  - Natural wormhole capacity to import materials?
  - 3D print panels/I-beams → ship to construction site
    ↓
Option D: Hold and harvest
  - None viable yet
  - Keep wormhole open, harvest system resources
  - Build capacity until A/B/C viable
    ↓
Option E: Hammer Protocol — close and move on
  - ROI below threshold (System_ROI < defined threshold)
  - Deploy WS MK1-H for EM/resource extraction only
  - Let wormhole decay naturally, scout next system
```

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `galaxy_game/app/services/wormhole_expansion_service.rb` | Main expansion logic | `#find_expansion_opportunities`, `#infrastructure_free_deployment_possible?` |
| `galaxy_game/spec/services/wormhole_expansion_service_spec.rb` | Spec — needs rewrite | line 17 |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `galaxy_game/app/services/ai_manager/station_cost_benefit_analyzer.rb` | `#select_optimal_strategy` — already implements option evaluation |
| `galaxy_game/app/services/ai_manager/precursor_capability_service.rb` | How to query system resources |
| `galaxy_game/app/models/solar_system.rb` | SolarSystem associations |
| `galaxy_game/app/models/celestial_bodies/celestial_body.rb` | CelestialBody associations |
| `galaxy_game/app/models/craft/base_craft.rb` | Tug/craft queries |

---

## Implementation Steps

### Step 1 — Research phase (read only)
```bash
docker exec -it web bash -c 'cat galaxy_game/app/services/wormhole_expansion_service.rb'
docker exec -it web bash -c 'grep -n "def select_optimal_strategy" galaxy_game/app/services/ai_manager/station_cost_benefit_analyzer.rb'
docker exec -it web bash -c 'grep -n "has_many\|belongs_to" galaxy_game/app/models/solar_system.rb'
docker exec -it web bash -c 'grep -n "has_many\|belongs_to" galaxy_game/app/models/celestial_bodies/celestial_body.rb | head -20'
docker exec -it web bash -c 'grep -n "def total_thrust\|thrust\|tug" galaxy_game/app/models/craft/base_craft.rb | head -10'
```

### Step 2 — Produce Synthesis Report and STOP

### Step 3 — Rewrite `find_expansion_opportunities`

Replace current settlement-based logic with asset evaluation:
```ruby
def find_expansion_opportunities(solar_system)
  opportunities = []
  
  solar_system.celestial_bodies.each do |body|
    construction_options = evaluate_construction_options(body, solar_system)
    next if construction_options.empty?
    
    analyzer = AIManager::StationCostBenefitAnalyzer.new(shared_context)
    optimal = analyzer.select_optimal_strategy(construction_options)
    
    opportunities << {
      celestial_body: body,
      recommended_strategy: optimal,
      construction_options: construction_options
    }
  end
  
  opportunities
end
```

### Step 4 — Implement `evaluate_construction_options`
```ruby
def evaluate_construction_options(body, solar_system)
  options = []
  
  # Option A — asteroid conversion
  if suitable_asteroid?(body) && tug_available?(solar_system)
    options << { type: :asteroid_conversion, body: body, priority: 1 }
  end
  
  # Option B — moon base
  if suitable_moon?(body)
    options << { type: :moon_base_construction, body: body, priority: 2 }
  end
  
  # Option C — L1 style import
  if wormhole_import_capacity?(solar_system)
    options << { type: :imported_construction, body: body, priority: 3 }
  end
  
  # Option D — harvest and hold
  options << { type: :harvest_and_hold, body: body, priority: 4 }
  
  options
end
```

### Step 5 — Implement asset detection helpers
```ruby
def suitable_asteroid?(body)
  # Phobos-sized: mass between 1e15 and 1e18 kg
  body.type == 'asteroid' && 
  body.mass.to_f.between?(1e15, 1e18)
end

def tug_available?(solar_system)
  # Query crafts in system with thrust > 0
  # Use operational_data['performance']['nominal_thrust_kn']
  # See base_craft.rb for pattern
end

def suitable_moon?(body)
  body.type == 'moon' && body.mass.to_f > 1e20
end

def wormhole_import_capacity?(solar_system)
  solar_system.wormholes.any? { |w| w.stability > 0.5 }
end
```

### Step 6 — Remove `infrastructure_free_deployment_possible?`

Replace with `evaluate_construction_options` pattern. Delete the old method entirely.

### Step 7 — Rewrite spec

Spec should test:
- Returns opportunities for systems with suitable asteroids
- Returns moon base option when suitable moon present
- Returns harvest_and_hold when no better option
- Returns empty when ROI below threshold (Hammer Protocol)

---

## Acceptance Criteria
- [ ] No settlement/colony queries in wormhole expansion logic
- [ ] `find_expansion_opportunities` uses `StationCostBenefitAnalyzer`
- [ ] Asset detection checks celestial body properties
- [ ] Tug detection reads `operational_data` thrust values
- [ ] Spec passes with 0 failures
- [ ] No regressions in related specs

---

## Stop Conditions
- `StationCostBenefitAnalyzer#select_optimal_strategy` interface differs significantly
- Solar system has no celestial body associations
- Tug thrust query pattern unclear from base_craft
- Any architectural decision beyond what wh-expansion.md covers

---

## Commit Instructions
```bash
git add galaxy_game/app/services/wormhole_expansion_service.rb
git add galaxy_game/spec/services/wormhole_expansion_service_spec.rb
git commit -m 'refactor: wormhole_expansion_service — AWS construction option evaluation via StationCostBenefitAnalyzer'
git push
```

---

## Dependencies
**Blocked by**: none
**Blocks**: none
**Related tasks**: `2026-03-26-HIGH-FEATURE-SEISMIC-SURVEY-SCOUT-SHIPS.md`

---

## Completion Report
*Filled in by implementing agent*