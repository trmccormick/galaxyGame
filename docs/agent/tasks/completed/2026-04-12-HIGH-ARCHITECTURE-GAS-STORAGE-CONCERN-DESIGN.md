# TASK: GasStorage Concern — Architecture Design
**Status**: COMPLETED
#
# NOTE (2026-04-17): This architecture design task is superseded by the following tasks, per Claude's review and session handoff:
#
# - 2026-04-16-HIGH-ARCHITECTURE-RAW-RESOURCE-EXTRACTION-PRICING.md
# - 2026-04-16-HIGH-FEATURE-MARKETPLACE-ON-STRUCTURE.md
# - 2026-04-16-HIGH-FEATURE-DOCKING-TRANSACTION-SERVICE.md
# - 2026-04-16-MEDIUM-DATA-ECONOMIC-PARAMETERS-MARKET-FEES.md
# - 2026-04-16-MEDIUM-ARCHITECTURE-MATERIAL-STORAGE-CLASSIFICATION.md
#
# This file is retained for historical reference only. All future work should reference the above tasks.
**Priority**: HIGH
**Type**: architecture
**Created**: 2026-04-12
**Last Updated**: 2026-04-12

---

## Agent Assignment
**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Architecture design — requires reasoning about
ownership rules, market integration, and concern placement across
multiple model types.
**Supervision Level**: 🟡 Standard

---

## Context

Gas transfer between craft and depot/settlement was previously
implemented as direct inventory manipulation (`add_gas`/`remove_gas`
on `OrbitalDepot` — now retired). The correct architecture routes all
gas transfers through either a same-owner bypass or a market order,
depending on ownership.

This concern will be included by any entity that can accept or provide
gas at a docking point:
- `Settlement::BaseSettlement` (surface — craft land at spaceport)
- `Structures::OrbitalStructure` (orbital — craft dock at structure)
- Potentially `Craft::BaseCraft` (craft-to-craft transfer)

---

## Core Business Rules — Locked

```
Rule 1 — Same owner bypass:
  craft.owner == docking_target.owner
  → direct inventory transfer
  → no GCC settlement
  → energy/time cost only
  → optional internal accounting log
  Use case: AI Manager moving its own gas between its own assets
  Use case: Player moving cargo between own craft and own settlement

Rule 2 — Different owner market path:
  craft.owner != docking_target.owner
  → market order required
  → place_sell_order or place_buy_order
  → GCC settles on fill
  → inventory moves as consequence of fill only
  Use case: independent harvester selling to NPC depot
  Use case: player buying fuel from AI Manager depot

Rule 3 — Surplus sale:
  Owner places sell order on local order book at ask price
  Any buyer (player or AI) can fill at market

Rule 4 — Processing cost:
  Always applies regardless of ownership
  Energy consumed, time elapsed

Rule 5 — Internal accounting log (optional, AI Manager):
  Same-owner transfers log notional transfer price for ROI tracking
  No GCC moves but cost-of-operations is recorded
```

---

## Real World Analogy

Vertically integrated oil company (ExxonMobil model):
- Owns drill platform, tanker, and refinery
- Crude moving between own assets = internal transfer, no market price
- Selling refined product to third parties at terminal = spot market price
- Internal transfers still logged for management accounting

---

## Design Questions to Answer

### 1. Concern interface
What are the public methods? What are the private primitives?

```
Public (called by external code):
  transfer_gas(gas, amount, from:, to:)  — routes to bypass or market
  place_sell_order(gas, amount, ask_price)
  place_buy_order(gas, amount, bid_price)

Private (internal only, called after order fill or bypass):
  add_gas(gas, amount)
  remove_gas(gas, amount)
```

### 2. Where does the order book live?
Confirm from market system design task. GasStorage concern should
not define the order book — it calls into whatever the market system
provides.

### 3. Inventory primitive
`add_gas`/`remove_gas` use the entity's `inventory` association.
Confirm `has_one :inventory` is available on all includers via
`SettlementCore` or directly.

### 4. Same-owner check
```ruby
def same_owner?(craft, target)
  craft.owner == target.owner
end
```
Confirm `owner` is available on all includers.

### 5. Energy cost tracking
How is energy cost recorded for same-owner transfers?
Does a `Transaction` record get created?

---

## Output — Design Document

```
CONCERN INTERFACE
================
Public methods: [list with signatures]
Private methods: [list with signatures]
Error conditions: [list]

SAME-OWNER BYPASS FLOW
======================
Steps: [describe exactly]
What gets logged: [describe]
Energy cost mechanism: [describe]

MARKET ORDER FLOW
=================
Steps: [describe exactly]
How order fill triggers inventory move: [describe]
GCC settlement: [describe]

INCLUDERS
=========
Settlement::BaseSettlement: [how gas storage works at surface]
Structures::OrbitalStructure: [how gas storage works at structure]
Craft::BaseCraft: [yes/no — craft-to-craft transfer needed?]

DEPENDENCIES
============
Requires market system: [yes — describe interface needed]
Requires inventory: [confirm has_one :inventory on all includers]
Requires account: [confirm for GCC settlement path]

IMPLEMENTATION PHASES
=====================
Phase 1: [same-owner bypass + add_gas/remove_gas primitives]
Phase 2: [market order integration]
Phase 3: [internal accounting log]

FOLLOW-UP TASKS
===============
[list implementation tasks with scope and agent tier]
```

---

## Acceptance Criteria
- [ ] All 5 business rules addressed in design
- [ ] Public vs private interface clearly defined
- [ ] Same-owner bypass flow fully described
- [ ] Market order flow fully described
- [ ] All includers identified
- [ ] No code changes made

## Stop Conditions
- Market system design task not yet complete — this concern depends
  on knowing the market order interface. If market system is not
  designed, produce the concern interface only and flag dependency.

---

## Dependencies
**Blocked by**: `2026-04-10-HIGH-ARCHITECTURE-ORBITAL-MARKET-SYSTEM.md`
  (rewrite needed — see session handoff 2026-04-12)
**Blocks**: All gas transfer implementation tasks
**Related**:
- `2026-04-12-HIGH-ARCHITECTURE-ORBITAL-SETTLEMENT-DECOUPLE-FROM-BASE.md` — completed
