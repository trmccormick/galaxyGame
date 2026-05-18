# 2026-03-29-HIGH-REFACTOR-WORMHOLE-EXPANSION-SERVICE

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — High priority refactor for wormhole expansion service AWS construction option evaluation
**Supervision Level**: 🔴 Watched carefully

## Context
WormholeExpansionService called when natural wormhole connection exists to system. Evaluates AWS (Artificial Wormhole Station) construction strategy viable given discovered system assets. Currently checks settlements/colonies — wrong domain. Correct logic evaluates system assets (asteroids, moons, local resources, available tugs) and passes construction options to StationCostBenefitAnalyzer#select_optimal_strategy.

## Problem Statement
WormholeExpansionService#find_expansion_opportunities calls infrastructure_free_deployment_possible? which queries settlements via colony traversal — wrong domain, causes NoMethodError and PG::UndefinedColumn errors.

**Expected**: Evaluates system assets, generates construction options, passes to StationCostBenefitAnalyzer, returns optimal strategy.

## Files Involved
### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `app/services/wormhole_expansion_service.rb` | Main expansion logic | Rewrite find_expansion_opportunities and infrastructure_free_deployment_possible? methods |
| `spec/services/wormhole_expansion_service_spec.rb` | Spec tests | Rewrite specs to validate new decision tree logic |

## Implementation Steps
1. **Research phase**: Read all reference files, run diagnostics to understand current implementation and required patterns
2. **Implement decision tree**: Replace settlement/colony queries with system asset evaluation (asteroids, moons, resources, tugs)
3. **Integrate cost-benefit analyzer**: Pass construction options to StationCostBenefitAnalyzer#select_optimal_strategy
4. **Update specs**: Rewrite tests to validate new AWS construction option evaluation logic
5. **Verify integration**: Ensure service works with existing wormhole expansion protocol

## Acceptance Criteria
- [ ] No more NoMethodError or PG::UndefinedColumn errors in wormhole expansion service
- [ ] Service evaluates system assets (asteroids, moons, resources, tugs) instead of settlements
- [ ] Construction options passed to StationCostBenefitAnalyzer for optimal strategy selection
- [ ] All specs pass with new decision tree implementation
- [ ] Service integrates properly with wormhole expansion protocol

## Stop Conditions
- Breaking existing wormhole expansion functionality
- Changes beyond wormhole expansion service and related specs

## Commit Instructions
```bash
git add app/services/wormhole_expansion_service.rb
git add spec/services/wormhole_expansion_service_spec.rb
git commit -m "refactor: Rewrite WormholeExpansionService for AWS construction option evaluation"
```