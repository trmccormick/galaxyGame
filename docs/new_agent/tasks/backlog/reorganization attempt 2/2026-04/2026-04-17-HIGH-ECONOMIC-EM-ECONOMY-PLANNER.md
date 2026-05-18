# 2026-04-17-HIGH-ECONOMIC-EM-ECONOMY-PLANNER

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Economic simulation task for EM economy planner
**Supervision Level**: 🔴 Watched carefully

## Context
Exotic Matter (EM) harvested from natural wormholes needs integration as fuel/resource powering artificial wormholes and portal technology. Must be modeled like any other fuel source: stored, consumed, traded.

## Problem Statement
EM not integrated as market fuel/resource. No logic for EM usage in infrastructure, market participation, profitability calculation for harvesting/sale.

**Expected**: EM modeled as fuel/resource with storage, consumption, trading, profitability calculation, appropriate market volatility simulation.

## Files Involved
### Primary Files — you will create
| File | Purpose | Action |
|---|---|---|
| `app/services/ai_manager/em_economy_planner.rb` | EM economy logic | Create service with all methods |
| `spec/services/ai_manager/em_economy_planner_spec.rb` | Test coverage | Create comprehensive RSpec |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `docs/agent/market/` | Existing market logic |
| `docs/agent/economics/` | Existing economic logic |

## Implementation Steps
1. **Audit codebase**: Check for existing EM market, profitability, volatility logic
2. **Create service**: Implement storage_and_consumption, market_participation, profitability, simulate_volatility methods
3. **Write specs**: Full RSpec coverage for all logic branches and edge cases
4. **Document formulas**: Code comments and docs for all assumptions

## Acceptance Criteria
- [ ] EM modeled as fuel/resource (not currency)
- [ ] EM can be stored, consumed by artificial wormholes/portal tech, traded in market
- [ ] Profitability calculation logic for EM harvesting, storage, sale implemented and testable
- [ ] Market volatility simulation for EM as fuel/resource implemented and testable
- [ ] RSpec: full coverage for all logic branches
- [ ] No duplication with existing market, fuel, or economic logic

## Stop Conditions
- Existing implementation or task found
- Requirements unclear or overlap with other economic simulation work

## Commit Instructions
```bash
git add app/services/ai_manager/em_economy_planner.rb
git add spec/services/ai_manager/em_economy_planner_spec.rb
git commit -m "feat: EM economy planner — integrate EM as market fuel/resource with profitability and volatility simulation"
```