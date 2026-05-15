# 2026-03-29-HIGH-REFACTOR-WORMHOLE-EXPANSION-SERVICE

**Agent**: 0.33x  
**Priority**: HIGH  
**Type**: refactor  
**Status**: BACKLOG  

## Context
The `WormholeExpansionService` is called when a natural wormhole connection already exists to a system. Its job is to evaluate what AWS (Artificial Wormhole Station) construction strategy is viable given the discovered system's assets. Currently the service checks settlements and colonies — completely wrong domain. The correct logic evaluates system assets (asteroids, moons, local resources, available tugs) and passes construction options to `StationCostBenefitAnalyzer#select_optimal_strategy` which already implements the financial/risk evaluation.

The wormhole is already open when this service runs. The question is not "can we get there" but "what can we build there and is it worth it."

**Relevant Architecture Docs** — read before starting:
- `docs/wormhole_expansion/wh-expansion.md` — full wormhole expansion protocol, Hammer Protocol, AWS construction, ROI thresholds
- `docs/architecture/systems/asteroid_conversion_physics.md` — asteroid conversion mechanics, Rule B hollowing, mass-to-hull efficiency
- `docs/architecture/services/ai_manager/strategy_selector.md` — AI Manager decision framework
- `docs/architecture/services/ai_manager/mission_scorer.md` — scoring and prioritization

## Problem
`WormholeExpansionService#find_expansion_opportunities` calls `infrastructure_free_deployment_possible?` which queries settlements via colony traversal — wrong domain, causes `NoMethodError` and `PG::UndefinedColumn` errors.

**Current behavior**: Crashes with column errors, returns wrong data.
**Expected behavior**: Evaluates system assets, generates construction options, passes to `StationCostBenefitAnalyzer`, returns optimal strategy.

## Decision Tree
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

## Files
- `galaxy_game/app/services/wormhole_expansion_service.rb` — Main expansion logic, `#find_expansion_opportunities`, `#infrastructure_free_deployment_possible?`
- `galaxy_game/spec/services/wormhole_expansion_service_spec.rb` — Spec — needs rewrite, line 17

## Steps
1. **Research phase** (read only)
   - Read all reference files to understand current implementation and correct patterns

2. **Rewrite `find_expansion_opportunities`**
   - Remove settlement/colony queries
   - Implement system asset evaluation
   - Generate construction options based on available resources

3. **Integrate with StationCostBenefitAnalyzer**
   - Pass construction options to `select_optimal_strategy`
   - Return optimal strategy instead of wrong data

4. **Update spec**
   - Rewrite to test correct system asset evaluation
   - Test decision tree options

## Acceptance Criteria
- [ ] No settlement/colony queries in expansion service
- [ ] System assets properly evaluated (asteroids, moons, resources, tugs)
- [ ] Construction options generated correctly
- [ ] StationCostBenefitAnalyzer integration working
- [ ] No more NoMethodError or PG::UndefinedColumn errors
- [ ] Spec tests correct behavior
- [ ] All tests pass

## Stop Conditions
- StationCostBenefitAnalyzer interface doesn't match expectations
- System asset queries not available
- Construction options don't align with existing AWS types
- Integration causes circular dependencies

## Commit Message
`refactor: wormhole_expansion_service — AWS construction option evaluation`