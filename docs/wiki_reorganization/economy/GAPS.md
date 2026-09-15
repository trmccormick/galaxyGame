# Economic Documentation Gaps — Tracking File

**Status**: Active  
**Created**: 2026-09-12  
**Last Updated**: 2026-09-12  
**Purpose**: Track discrepancies between economic documentation, implementation, and backlog coverage

---

## 1. Unresolved Economic Gaps

### Gap A: EAP Calculation Helpers — MISSING
**Description**: No dedicated helper service exists for computing Earth Anchor Price (EAP) across destinations. `Tier1PriceModeler` computes EAP per material per destination but is not exposed as a reusable service with clear API contract.

**Evidence**: 
- `full_run_order.txt` references `Tier1PriceModeler` and `reward_eap` validation
- Wiki 03-market-and-pricing.md documents EAP formula: `EAP = (Earth spot price × refining factor) + transport cost to destination`
- No `Financial::EapCalculator` or similar service exists in codebase

**Impact**: AI Manager acquisition logic (`NpcPriceCalculator`) must duplicate EAP computation or rely on implicit coupling with `Tier1PriceModeler`.

**Backlog Coverage**: Partial — planning doc `projects_galaxy_game_backlog_economy_2026-09-07-PLANNING-OVERVIEW-ECONOMIC-SUBSYSTEM.md` discusses EAP migration to TCO model but no task file exists.

---

### Gap B: Standardized Blueprint Cost Schemas — MISSING
**Description**: No canonical schema for blueprint cost data (materials, labor, time). Blueprints reference costs inconsistently across files.

**Evidence**:
- `filtered_diff.txt` shows deleted task `2026-04-04-HIGH-REFACTOR-MANUFACTURING-SERVICE-BOM-COST-VIA-NPC-PRICE-CALCULATOR.md` — suggests past awareness of this gap
- Wiki 05-launch-and-operational-fees.md documents launch cost calculation but no blueprint-level cost schema exists
- `full_run_order.txt` references `EAP-COGS` for unit assembly but no standardized schema

**Impact**: AI Manager cannot reliably evaluate construction profitability across different craft/unit types.

**Backlog Coverage**: None — no active or backlog task addresses this gap.

---

### Gap C: Local-First Precursor Enforcement — MISSING
**Description**: No enforcement mechanism ensures local production is attempted before Earth imports for bulk commodities (LOX, water, regolith products).

**Evidence**:
- Wiki 03-market-and-pricing.md documents AI Manager acquisition logic: `local < NPC market < Earth import`
- Wiki 01-overview-and-design.md documents ISRU pipeline phases but no code enforces priority ordering
- Planning doc mentions `NpcPriceCalculator.cost_based_bid` should "branch between high-tech imports (retaining EAP) and local bulk/ISRU resources"

**Impact**: AI Manager may import from Earth when local production is economically viable, wasting GCC.

**Backlog Coverage**: Partial — planning doc Phase 2 proposes pricing floor refactor but no task file exists.

---

### Gap D: Hybrid GCC Supply Model — MISSING
**Description**: No implementation of the documented hybrid GCC supply model (pre-seeded + mining satellite emission + halving schedule).

**Evidence**:
- Wiki 04-bonds-and-financing.md documents: 250M pre-seeded + 1M GCC/cycle daily from LDC mining satellites
- Mining rate: 1,000 GCC/hour per satellite = 6,000 GCC per cycle = 24,000 GCC/day/satellite
- Halving schedule: TBD (every N months, mining rate halves)
- Supply cap: TBD

**Impact**: Monetary base is static at launch; no disincentive for early accumulation; no inflation control.

**Backlog Coverage**: None — no task file addresses halving schedule or supply cap implementation.

---

### Gap E: Settlement Fees Parity Bug — KNOWN
**Description**: `OrbitalSettlement` lacks `SettlementFees` concern, causing silent zero-fee calculations for orbital nodes.

**Evidence**:
- Planning doc Phase 1 explicitly lists this as "Parity Fix" priority
- Wiki 05-launch-and-operational-fees.md documents fee structure but orbital nodes bypass it

**Impact**: Orbital settlements charge zero broker/transaction fees, distorting market pricing.

**Backlog Coverage**: Partial — planning doc Phase 1 identifies the fix but no task file exists.

---

### Gap F: Manufacturing COGS Integration — ORPHANED
**Description**: `Manufacturing::CostCalculator` service exists but is not wired into market pricing ledgers.

**Evidence**:
- Planning doc Phase 3 proposes wiring orphaned `Manufacturing::CostCalculator` to market pricing
- Wiki 03-market-and-pricing.md documents EAP-COGS concept but no integration exists

**Impact**: Manufacturing costs don't flow into NPC buy/sell orders; prices decoupled from production reality.

**Backlog Coverage**: None — no task file addresses COGS integration.

---

### Gap G: GCC/USD Peg Phase Automation — MISSING
**Description**: No automated mechanism transitions between peg phases (Hard → Soft → Managed Float → Full Float).

**Evidence**:
- Wiki 02-currencies-and-accounts.md documents three peg phases but no implementation exists
- `Financial::ExchangeRateService` defaults to 1:1 at seed time with no phase transition logic

**Impact**: Economy remains at hard peg indefinitely; no dynamic price discovery mechanism.

**Backlog Coverage**: None — no task file addresses peg automation.

---

### Gap H: GCC Issuance Schedule — MISSING
**Description**: No enforcement of the documented daily issuance schedule (1,000,000 GCC/cycle from LDC mining satellites).

**Evidence**:
- Wiki 02-currencies-and-accounts.md documents: "Daily issuance: 1,000,000 GCC/cycle from LDC mining satellites"
- Crypto mining satellite operational data shows 1,000 GCC/hour per satellite (not 1M/day)
- Discrepancy between documented issuance rate and satellite operational parameters

**Impact**: Monetary base growth is uncontrolled; documentation and implementation are inconsistent.

**Backlog Coverage**: None — no task file addresses issuance schedule enforcement.

---

### Gap I: GCC Mining — recalculate_stats / mine_gcc Disconnection
**Description**: `recalculate_stats` (base_craft.rb line 372) computes and stores a base-plus-fit mining rate in `current_mining_rate_gcc_per_hour`, but the current `mine_gcc` path independently aggregates fitted computer units via MiningUnitAdapter without consuming the stored recalculated rate.

**Evidence**:
- Source-trace: two independent code paths with no data flow between them
- `recalculate_stats` stores result in operational_data['operational_properties']['current_mining_rate_gcc_per_hour']
- `mine_gcc` reads from MiningUnitAdapter which queries each fitted unit's operational_data directly
- The satellite-level `base_mining_rate_gcc_per_hour: 1000` field is not part of the shown runtime `mine_gcc` calculation

**Impact**: Documentation claiming "mining rate = base rate + fitted components" describes recalculate_stats behavior, not mine_gcc behavior. This is a verified source-trace discrepancy; runtime differential validation pending.

**Backlog Coverage**: None — addressed by P0 task candidate below.

---

## 2. Backlog Status Summary

| Gap | Backlog Task Exists? | Task File Path | Status |
|-----|---------------------|---------------|--------|
| A: EAP Calculation Helpers | Partial (planning doc only) | `backlog/economy/projects_galaxy_game_backlog_economy_2026-09-07-PLANNING-OVERVIEW-ECONOMIC-SUBSYSTEM.md` | No task file |
| B: Standardized Blueprint Cost Schemas | None | — | Needs new task |
| C: Local-First Precursor Enforcement | Partial (planning doc only) | Same as Gap A | No task file |
| D: Hybrid GCC Supply Model | None | — | Needs new task |
| E: Settlement Fees Parity Bug | Partial (planning doc only) | Same as Gap A | No task file |
| F: Manufacturing COGS Integration | None | — | Needs new task |
| G: GCC/USD Peg Phase Automation | None | — | Needs new task |
| H: GCC Issuance Schedule | None | — | Needs new task |
| I: GCC Mining recalculate_stats/mine_gcc Disconnection | None | — | Addressed by P0 candidate |

**Summary**: 9 gaps identified. 0 have dedicated backlog tasks. 3 have planning docs but no task files. 6 need entirely new tasks.

---

## 3. Recommended Next Steps (Priority Order)

### Priority 1: Critical (Economic Foundation)
1. **Gap E — Settlement Fees Parity** (LOW effort, HIGH impact)
   - Add `SettlementFees` concern to `OrbitalSettlement`
   - Unblocks accurate fee calculations across all settlement types
   - Estimated: 1-2 hours

2. **Gap D — Hybrid GCC Supply Model** (HIGH effort, HIGH impact)
   - Implement halving schedule logic in `economic_parameters.yml`
   - Add emission enforcement to LDC mining satellite lifecycle
   - Estimated: 4-6 hours

3. **Gap A — EAP Calculation Helpers** (MEDIUM effort, HIGH impact)
   - Create `Financial::EapCalculator` service with clear API contract
   - Expose for AI Manager acquisition logic and NPC pricing
   - Estimated: 3-4 hours

### Priority 2: Important (Market Integrity)
4. **Gap C — Local-First Precursor Enforcement** (MEDIUM effort, MEDIUM impact)
   - Refactor `NpcPriceCalculator.cost_based_bid` to enforce local-first priority
   - Wire into AI Manager acquisition decision logic
   - Estimated: 3-4 hours

5. **Gap F — Manufacturing COGS Integration** (MEDIUM effort, MEDIUM impact)
   - Wire orphaned `Manufacturing::CostCalculator` to market pricing ledgers
   - Ensure production costs flow into NPC buy/sell orders
   - Estimated: 3-4 hours

### Priority 3: Strategic (Long-Term Economy Health)
6. **Gap G — GCC/USD Peg Phase Automation** (HIGH effort, HIGH impact)
   - Implement phase transition triggers and exchange rate dynamics
   - Requires careful testing to avoid economic instability
   - Estimated: 8-12 hours

7. **Gap B — Standardized Blueprint Cost Schemas** (MEDIUM effort, MEDIUM impact)
   - Define canonical schema for blueprint cost data
   - Update all existing blueprints to conform
   - Estimated: 4-6 hours

8. **Gap H — Emission Schedule Enforcement** (LOW effort, HIGH impact)
   - Resolve discrepancy between documented rate (1M/day) and satellite data (24k/day)
   - Align implementation with documentation
   - Estimated: 1-2 hours

---

## 4. Cross-Reference: Wiki Coverage Status

| Wiki File | Covers This Gap? | Notes |
|-----------|-----------------|-------|
| README.md | Partial | Documents three-pillar structure but not gap details |
| 01-overview-and-design.md | Partial | Documents EAP concept, GCC emission schedule (docs only) |
| 02-currencies-and-accounts.md | Partial | Documents peg phases, emission schedule (docs only) |
| 03-market-and-pricing.md | Partial | Documents EAP formula, AI Manager logic (no implementation) |
| 04-bonds-and-financing.md | Partial | Documents GCC mining bonds, halving schedule (TBD) |
| 05-launch-and-operational-fees.md | Partial | Documents fee structure, launch costs (docs only) |
| 06-contracts-and-players.md | No | Focuses on contracts, not economic gaps |
| 07-npc-economy-lifecycle.md | Partial | Documents NPC pricing modes (no enforcement mechanism) |

**Note**: All wiki files document the *intended* economic behavior but none implement the missing pieces. This is expected — wiki documents architecture; implementation tasks fill the gaps.

---

## 5. Known Resolved Gaps (For Reference)

| Gap | Resolution | Date |
|-----|-----------|------|
| NPC Price Calculator `.evaluate_strategy` | ✅ Committed `792e670b`, 28 tests passing | 2026-09-10 |
| RH-400 duplicate blueprint | ✅ Consolidation direction identified, task completed | 2026-09-09 |
| CNT-fabricator naming collision | ✅ Closed via commit `e95b0c7` | 2026-09-10 |
| Settlement Fees (Luna) | ✅ Implemented for `BaseSettlement` | Prior to this audit |
