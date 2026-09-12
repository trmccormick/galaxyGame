# Economy Documentation Audit Report

**Date**: 2026-09-11
**Auditor**: Implementation Agent (Copilot)

---

## STEP 1 — EXISTING FILES INVENTORY

### A. `docs/architecture/economy/` (13 files) — Legacy canonical location

| # | File | Primary Focus | Authority Status |
|---|------|--------------|-----------------|
| 1 | `CONTRACTS.md` | Player contract system (courier, manufacturing, exploration, station expansion) | CANONICAL |
| 2 | `CURRENCY_AND_EXCHANGE.md` | GCC/USD peg phases, exchange mechanics, stability measures | CANONICAL |
| 3 | `FISCAL_POLICY_AND_FEES.md` | Transaction taxes, corporate income tax, maintenance costs, reserve requirements | CANONICAL |
| 4 | `GCC_MINTING_AND_PRESEEDING.md` | Mining satellite deployment, halving schedule, supply cap, LDC mint authority | DRAFT (new, 2026-09-08) |
| 5 | `ISRU_PRICING_MODEL.md` | ISRU pricing logic, NpcPriceCalculator, ManufacturingService flow | REFERENCE |
| 6 | `LEDGERS.md` | Virtual Ledger mechanics, NPC debt, settlement flows, overdraft controls | CANONICAL |
| 7 | `MARKET_OPERATIONS.md` | EAP calculation, market vs build logic, virtual ledger protocols, contract ceiling limits | REFERENCE |
| 8 | `PLAYER_CONTRACT_SYSTEM.md` | Player contract system design, GCC=USD starting point, automated market building | CANONICAL |
| 9 | `PRICE_DISCOVERY_LIFECYCLE.md` | EAP calculation, infrastructure maturity pricing, decoupling stages | CANONICAL |
| 10 | `VIRTUAL_LEDGER_FLOWS.md` | Virtual ledger transaction flows (NPC supply chain, construction contracts, crisis procurement) | CANONICAL |
| 11 | `economic_baseline.md` | Global EM economy status, burn rate metrics, link contributions | REFERENCE (snapshot data) |
| 12 | `financial_system.md` | Financial::Account model, Virtual Ledger system architecture | CANONICAL |
| 13 | `gcc_coupling_status.md` | GCC coupling status tracker per system (SOL, AOL, AC) | REFERENCE (dynamic state) |

### B. `docs/new_agent/projects/galaxy_game/economy/` (2 files) — Agent notes

| # | File | Primary Focus | Authority Status |
|---|------|--------------|-----------------|
| 14 | `economy_models.md` | Data model inventory (Market::Marketplace, Market::Condition, etc.) with code evidence | REFERENCE (agent documentation) |
| 15 | `npc_economy_lifecycle.md` | NPC lifecycle phases: initialization, price setting, order creation, player contracts, fallback | REFERENCE (agent documentation) |

### C. `docs/wiki_reorganization/economy/` (4 files) — Draft wiki destination

| # | File | Primary Focus | Authority Status |
|---|------|--------------|-----------------|
| 16 | `ECONOMY_OVERVIEW.md` | Entry point, system architecture, documentation map, key models/services | DRAFT (canonical hub) |
| 17 | `CURRENCIES_AND_ACCOUNTS.md` | Currency model, account model, GCC/USD peg phases, stability measures — supersedes CURRENCY_AND_EXCHANGE + financial_system | DRAFT (supersedes #2, #12) |
| 18 | `BONDS_AND_FINANCING.md` | Bond model, bond lifecycle, launch service bonds, GCC mining bonds, inter-DC bonds | NEW (consolidated from GCC_MINTING + general bond concepts) |
| 19 | `LAUNCH_PAYMENT_MODEL.md` | Launch payment flow, mass calculation, configuration structure, GCC mining satellite example | NEW (derived from GCC_MINTING + launch service patterns) |

---

## STEP 2 — OVERLAP & REDUNDANCY ANALYSIS

### High Overlap Pairs

| Overlap | Files Involved | Issue |
|---------|---------------|-------|
| **GCC/USD peg & exchange mechanics** | `CURRENCY_AND_EXCHANGE.md` (#2) + `CURRENCIES_AND_ACCOUNTS.md` (#17) | #17 explicitly supersedes #2. Content is largely identical but #17 adds numeraire rules and pre-seeding overview. **Action: merge into #17, deprecate #2** |
| **Financial system / account model** | `financial_system.md` (#12) + `CURRENCIES_AND_ACCOUNTS.md` (#17) | #17 supersedes #12. Account model content is duplicated. **Action: merge into #17, deprecate #12** |
| **Virtual Ledger mechanics** | `VIRTUAL_LEDGER_FLOWS.md` (#10) + `LEDGERS.md` (#6) + `CURRENCIES_AND_ACCOUNTS.md` (#17) | Three files cover virtual ledger. #10 covers transaction flow examples, #6 covers overdraft/account model, #17 covers account model basics. **Action: merge #6 into #17; keep #10 as separate "Virtual Ledger Transaction Flows" doc** |
| **GCC minting & pre-seeding** | `GCC_MINTING_AND_PRESEEDING.md` (#4) + `CURRENCIES_AND_ACCOUNTS.md` (#17, section 7) + `ECONOMY_OVERVIEW.md` (#16) | #4 is the deep dive. #17 and #16 reference it. **Action: keep #4 as canonical minting doc** |
| **Player contract system** | `PLAYER_CONTRACT_SYSTEM.md` (#8) + `CONTRACTS.md` (#1) | Identical content — both describe player contract system with courier/manufacturing/exploration/station expansion types. **Action: merge into one, deprecate other** |
| **Fiscal policy / fees** | `FISCAL_POLICY_AND_FEES.md` (#3) + referenced in `MARKET_OPERATIONS.md` (#7) and `CURRENCIES_AND_ACCOUNTS.md` (#17) | #3 is the canonical fee source. Others reference it. **Action: keep #3 as canonical** |
| **Price discovery / EAP** | `PRICE_DISCOVERY_LIFECYCLE.md` (#9) + `MARKET_OPERATIONS.md` (#7, EAP section) | #7 has a duplicate EAP section. #9 is the deep dive. **Action: keep #9 as canonical; remove EAP section from #7** |
| **GCC coupling status** | `gcc_coupling_status.md` (#13) + `CURRENCIES_AND_ACCOUNTS.md` (#17, peg phases) | #13 is dynamic state data (per-system rates). #17 covers the mechanism. **Action: keep #13 as reference (dynamic data)** |

### Low Overlap / Unique Content

| File | Unique Value |
|------|-------------|
| `ISRU_PRICING_MODEL.md` (#5) | ISRU-specific pricing logic, NpcPriceCalculator details, manufacturing flow |
| `economic_baseline.md` (#11) | Snapshot data (EM metrics, burn rates) — ephemeral, not canonical architecture |
| `economy_models.md` (#14) | Data model inventory with code evidence — agent reference |
| `npc_economy_lifecycle.md` (#15) | NPC lifecycle phase documentation — agent reference |

---

## STEP 3 — BROKEN LINK CHECK

### Files with references to `docs/architecture/economy/`:

| File | References | Status |
|------|-----------|--------|
| `docs/GUARDRAILS.md` (lines 39, 43, 71) | References `MARKET_OPERATIONS.md`, `CURRENCY_AND_EXCHANGE.md`, `FISCAL_POLICY_AND_FEES.md` | **BROKEN** — will need update after move |
| `docs/agent/rules/GUARDRAILS.md` (lines 39, 43, 71) | Same references as above | **BROKEN** — will need update after move |
| `docs/wiki_reorganization/proposals/PROPOSED_DOCUMENTATION_STRUCTURE.md` | Maps old paths to proposed new structure | **INFO** — proposal doc, not active reference |
| `docs/wiki_reorganization/inventory/DOCUMENT_INVENTORY.md` | Lists all 13 economy files with paths | **INFO** — inventory doc, will need update |
| `docs/wiki_reorganization/inventory/DOCUMENT_AUTHORITY_MAP.md` | Authority mapping for all 13 files | **INFO** — authority map, will need update |
| `docs/wiki_reorganization/phase4/CANONICAL_DOCUMENT_INDEX.md` | References `economic_baseline.md`, `financial_system.md`, `FISCAL_POLICY_AND_FEES.md` | **BROKEN** — will need update after move |
| `docs/wiki_reorganization/phase3_alignment/DOCUMENTATION_UPDATE_PLAN.md` | References `CURRENCY_AND_EXCHANGE.md`, `contracts.md` | **INFO** — phase 3 plan, may be obsolete |
| `docs/wiki_reorganization/economy/CURRENCIES_AND_ACCOUNTS.md` (line 5) | Supersedes `docs/architecture/economy/CURRENCY_AND_EXCHANGE.md`, `financial_system.md` | **INFO** — correct supersession notice |
| `docs/wiki_reorganization/economy/LAUNCH_PAYMENT_MODEL.md` (line 5) | References `economy/CURRENCIES_AND_ACCOUNTS.md`, `BONDS_AND_FINANCING.md`, `GCC_MINTING_AND_PRESEEDING.md` | **OK** — relative wiki paths, will work after consolidation |
| `docs/wiki_reorganization/economy/BONDS_AND_FINANCING.md` (line 5) | References `economy/CURRENCIES_AND_ACCOUNTS.md`, `GCC_MINTING_AND_PRESEEDING.md`, `LAUNCH_PAYMENT_MODEL.md` | **OK** — relative wiki paths, will work after consolidation |
| `docs/wiki_reorganization/economy/CURRENCIES_AND_ACCOUNTS.md` (line 194) | References `economy/GCC_MINTING_AND_PRESEEDING.md` | **OK** — relative wiki path |

### Internal cross-references within wiki_reorganization/economy/:

All internal references use relative paths (`economy/FILENAME.md`) which will remain valid after consolidation. No broken internal links detected.

---

## STEP 4 — PROPOSED REORGANIZATION MAP

### Target Structure: `docs/wiki_reorganization/economy/`

| # | Target File | Source(s) | Action |
|---|------------|-----------|--------|
| **Hub** | `README.md` | `ECONOMY_OVERVIEW.md` (#16) | Rename to `README.md` — serves as main hub |
| **01** | `01-overview-and-design.md` | `ECONOMY_OVERVIEW.md` (#16, content not in README) + `economic_baseline.md` (#11, snapshot section moved to appendix) | Consolidate overview, architecture diagram, key models |
| **02** | `02-currencies-and-accounts.md` | `CURRENCIES_AND_ACCOUNTS.md` (#17) + `CURRENCY_AND_EXCHANGE.md` (#2, merged into #17) + `financial_system.md` (#12, merged into #17) | Already consolidated — keep as-is |
| **03** | `03-market-and-pricing.md` | `PRICE_DISCOVERY_LIFECYCLE.md` (#9) + `ISRU_PRICING_MODEL.md` (#5) + `MARKET_OPERATIONS.md` (#7, EAP section) + `gcc_coupling_status.md` (#13, as appendix) | Consolidate price discovery, ISRU pricing, market operations |
| **04** | `04-bonds-and-financing.md` | `BONDS_AND_FINANCING.md` (#18) + `GCC_MINTING_AND_PRESEEDING.md` (#4) | GCC minting is financing mechanism — merge into bonds doc |
| **05** | `05-launch-and-operational-fees.md` | `LAUNCH_PAYMENT_MODEL.md` (#19) + `FISCAL_POLICY_AND_FEES.md` (#3) | Launch payments + fiscal policy/fees |
| **06** | `06-contracts-and-players.md` | `PLAYER_CONTRACT_SYSTEM.md` (#8) + `CONTRACTS.md` (#1, merge) + `VIRTUAL_LEDGER_FLOWS.md` (#10, as appendix) | Player contracts + virtual ledger flows |
| **07** | `07-npc-economy-lifecycle.md` | `economy_models.md` (#14) + `npc_economy_lifecycle.md` (#15) | Agent documentation — keep as reference |

### Files to DEPRECATE (after merge):
- `CURRENCY_AND_EXCHANGE.md` → merged into `02-currencies-and-accounts.md`
- `financial_system.md` → merged into `02-currencies-and-accounts.md`
- `MARKET_OPERATIONS.md` → EAP section merged into `03-market-and-pricing.md`; remaining content deprecated (covered by PRICE_DISCOVERY + CURRENCIES)
- `PRICE_DISCOVERY_LIFECYCLE.md` → merged into `03-market-and-pricing.md`
- `ISRU_PRICING_MODEL.md` → merged into `03-market-and-pricing.md`
- `gcc_coupling_status.md` → moved to appendix in `03-market-and-pricing.md`
- `GCC_MINTING_AND_PRESEEDING.md` → merged into `04-bonds-and-financing.md`
- `BONDS_AND_FINANCING.md` → kept as `04-bonds-and-financing.md`
- `LAUNCH_PAYMENT_MODEL.md` → moved to `05-launch-and-operational-fees.md`
- `FISCAL_POLICY_AND_FEES.md` → moved to `05-launch-and-operational-fees.md`
- `PLAYER_CONTRACT_SYSTEM.md` + `CONTRACTS.md` → merged into `06-contracts-and-players.md`
- `VIRTUAL_LEDGER_FLOWS.md` → appendix in `06-contracts-and-players.md`
- `LEDGERS.md` → content merged into `02-currencies-and-accounts.md` (account model)
- `economic_baseline.md` → snapshot data, moved to appendix in `01-overview-and-design.md`

### Files to PRESERVE (agent documentation):
- `economy_models.md` → `07-npc-economy-lifecycle.md`
- `npc_economy_lifecycle.md` → `07-npc-economy-lifecycle.md`

---

## STEP 5 — FILES REQUIRING CROSS-REFERENCE UPDATES

After reorganization, these files need their `docs/architecture/economy/` references updated:

1. `docs/GUARDRAILS.md` (3 references)
2. `docs/agent/rules/GUARDRAILS.md` (3 references)
3. `docs/wiki_reorganization/phase4/CANONICAL_DOCUMENT_INDEX.md` (3 references)
4. `docs/wiki_reorganization/inventory/DOCUMENT_INVENTORY.md` (13 references — update to new paths)
5. `docs/wiki_reorganization/inventory/DOCUMENT_AUTHORITY_MAP.md` (13 references — update to new paths)
6. `docs/wiki_reorganization/proposals/PROPOSED_DOCUMENTATION_STRUCTURE.md` (proposal doc — update for consistency)
