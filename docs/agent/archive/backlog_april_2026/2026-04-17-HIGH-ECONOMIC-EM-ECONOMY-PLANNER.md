# EM Economy Planner (0x Subtask)

**Layer:** ECONOMIC (Simulation)
**Created:** 2026-04-17
**Priority:** HIGH
**Status:** TODO

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Requires architectural reasoning, cross-service integration, and strict template compliance
**Supervision Level**: watched carefully

---

## Scope
Integrate Exotic Matter (EM)—harvested from natural wormholes—as a fuel/resource powering artificial wormholes and (eventually) portal technology. Model EM like any other fuel source: ensure it can be stored, consumed, and traded; implement logic for EM usage in powering infrastructure, market participation (buy/sell), and profitability calculation for harvesting and sale. Simulate EM price volatility only as appropriate for a fuel/resource. All logic must be independently testable and integrate with EM harvesting, storage, and consumption systems.

## Target Files
- app/services/ai_manager/em_economy_planner.rb
- spec/services/ai_manager/em_economy_planner_spec.rb

## Acceptance Criteria
- EM is modeled as a fuel/resource (not a currency)
- EM can be stored, consumed by artificial wormholes/portal tech, and traded in the market
- Profitability calculation logic for EM harvesting, storage, and sale is implemented and testable
- Market volatility simulation for EM as a fuel/resource is implemented and testable (if appropriate)
- RSpec: full coverage for all logic branches
- No duplication with existing market, fuel, or economic logic

## Implementation Steps
1. Audit the codebase and /docs for any existing EM market, profitability, or volatility logic. STOP if found—refactor or extend instead of duplicating.
2. Create em_economy_planner.rb service with methods for:
   - storage_and_consumption(em_amount, infrastructure_state): handles EM storage, usage by artificial wormholes/portals, and depletion
   - market_participation(em_amount, market_state): handles EM listing, buying, and selling as a fuel/resource
   - profitability(em_harvested, costs, market_state): calculates net profit from EM harvesting, storage, and sale
   - simulate_volatility(market_state, events): simulates price fluctuations for EM as a fuel/resource (if appropriate)
3. Write/extend RSpec for all logic branches and edge cases.
4. Document all formulas and assumptions in code comments and, if needed, in /docs/agent/market/ or /docs/agent/economics/.

## Stop Conditions
- Any existing implementation or task is found—STOP and refactor/extend instead
- Requirements are unclear or overlap with other economic simulation work—STOP and clarify

## Risks
- Overlap with Unified Docking Exchange or Market System tasks
- Economic logic may already exist in /docs/agent/market/ or /docs/agent/economics/

## Commit Instructions
```
git add docs/agent/tasks/backlog/2026-04-17-HIGH-ECONOMIC-EM-ECONOMY-PLANNER.md app/services/ai_manager/em_economy_planner.rb spec/services/ai_manager/em_economy_planner_spec.rb
mv docs/agent/tasks/backlog/2026-02-11-HIGH-ECONOMIC-EM-ECONOMY-PLANNER.md docs/agent/tasks/backlog/old/
git commit -m "feat: rewrite EM Economy Planner for EM as market item, not currency"
git push
```
