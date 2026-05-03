# TASK: Unified Docking Exchange — Market System Architecture Rewrite
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
market mechanics, ownership rules, game economy, player and AI
interaction patterns across surface and orbital contexts.
**Supervision Level**: 🟡 Standard

---

## Context

This task replaces `2026-04-10-HIGH-ARCHITECTURE-ORBITAL-MARKET-SYSTEM.md`
which was scoped incorrectly (assumed settlement-level order book).

The correct scope is a **unified docking exchange system** — any entity
that accepts docking (surface settlement spaceport, orbital structure
docking port) can host a local order book. The system works identically
at surface and orbital docking points.

**Key architecture decisions locked 2026-04-12:**

```
Same owner → direct transfer, no GCC, energy/time cost only
Different owner → market order required, GCC settles on fill
Surplus → owner places sell order on local order book
Order book scope → local to the docking point (structure or spaceport)
Processing → always has energy/time cost regardless of ownership
```

**Real world model**: Vertically integrated commodity company.
Own assets move freely (internal transfer). Third-party transactions
go through the local spot market at the docking terminal.

---

## Problem Statement

**Current**: Gas transfer is direct inventory manipulation. No price
discovery, no GCC settlement for third-party transfers, no player
participation, no AI Manager market strategy.

**Expected**: Every docking point hosts a local order book. Craft
arriving to sell see the local bid prices. Craft arriving to buy see
the local ask prices. Same-owner bypass skips the market entirely.
GCC settles automatically on fill for third-party transactions.

---

## Existing Infrastructure to Audit

Before designing, audit what already exists:

```bash
cat app/models/market/marketplace.rb
find app/models/market/ -name "*.rb" | sort
grep -n "def transfer\|def debit\|def credit\|def settle" \
  app/models/financial/account.rb | head -20
grep -rn "class.*Order\|MarketOrder\|BuyOrder\|SellOrder" \
  app/models/ --include="*.rb"
cat app/models/market/market_order.rb 2>/dev/null || echo "not found"
grep -n "has_one :marketplace\|has_many :market_orders" \
  app/models/settlement/base_settlement.rb \
  app/models/structures/base_structure.rb 2>/dev/null
```

---

## Design Questions to Answer

### 1. Existing Marketplace
What does `Market::Marketplace` currently do?
Does it already support order books?
Does `BaseSettlement has_one :marketplace` work?
Does `BaseStructure` have a marketplace?

### 2. Order model
Does `Market::MarketOrder` or equivalent already exist?
If so, document its fields and lifecycle.
If not, design the full model.

### 3. Order book location
Given the unified docking exchange model:
- Surface settlement → marketplace on the settlement (spaceport level)
- Orbital structure → marketplace on the structure (docking port level)
Does current schema support this? Does BaseStructure need marketplace?

### 4. GCC settlement on fill
How does `Financial::Account` handle atomic transfer?
Is there a `transfer!(from:, to:, amount:)` method?

### 5. Same-owner bypass integration
Where does the ownership check happen?
Before order placement, or inside the transfer service?

### 6. AI Manager participation
How does AI Manager set bid/ask prices?
How does it manage spread between raw input cost and processed output price?

---

## Output — Architecture Design Document

```
EXISTING INFRASTRUCTURE AUDIT
==============================
Market::Marketplace: [what it does, schema, current usage]
Market::MarketOrder: [exists/missing — fields if exists]
Financial::Account transfer: [method signature, atomic yes/no]
BaseSettlement marketplace: [has_one confirmed/missing]
BaseStructure marketplace: [has_one exists/needs adding]

UNIFIED DOCKING EXCHANGE DESIGN
================================

Order Book Location
-------------------
Surface settlement: [marketplace on settlement — confirm or propose]
Orbital structure: [marketplace on structure — confirm or propose]
Schema changes needed: [list]

Order Model
-----------
Fields: [list]
Types: [buy / sell / market_buy / market_sell]
Lifecycle: [open → partially_filled → filled | cancelled | expired]

Same-Owner Bypass
-----------------
Check location: [where in the call chain]
What happens: [direct transfer, log entry]
Energy cost: [how recorded]

Order Matching
--------------
Trigger: [when does matching run — on placement, on tick, on arrival]
Algorithm: [price-time priority]
Partial fills: [supported yes/no]
GCC settlement: [exact flow on fill]

Processing Pipeline Integration
--------------------------------
How raw gas becomes processed output available on market
Time and energy cost model
AI Manager automation of processing queue

AI Manager Participation
------------------------
Depot owner strategy: [bid/ask spread management]
Inventory trigger: [when AI places orders]
Profit tracking: [how ROI is measured]

Player Participation
--------------------
Harvester flow: [dock → see local book → place sell order → fill → undock]
Buyer flow: [dock → see local book → place buy order or market buy → fill]
Depot operator flow: [own structure → manage prices → process inventory]

MARKET EVENTS
=============
Events that trigger order matching: [list]
Events that trigger AI Manager decisions: [list]

IMPLEMENTATION PHASES
=====================
Phase 1 — Local order book MVP:
  [minimal viable order book at docking point]
  [same-owner bypass]
  [basic bid/ask, GCC settlement on fill]

Phase 2 — Processing pipeline integration:
  [raw → processed, time/energy cost, auto-list output]

Phase 3 — AI Manager participation:
  [spread management, inventory triggers, ROI tracking]

Phase 4 — Player UI hooks:
  [flag as separate frontend task — out of scope here]

RISKS AND OPEN QUESTIONS
========================
[list anything needing human decision before implementation]

SCHEMA CHANGES NEEDED
=====================
[list migrations required]

FOLLOW-UP IMPLEMENTATION TASKS
===============================
[list in phase order with scope and agent tier]
```

---

## Acceptance Criteria
- [ ] Existing market infrastructure fully audited
- [ ] Order book location confirmed for surface and orbital
- [ ] Same-owner bypass fully described
- [ ] Order model designed with full field list
- [ ] GCC settlement flow described
- [ ] Processing pipeline integration described
- [ ] AI Manager participation strategy described
- [ ] Implementation phases defined with schema changes
- [ ] No code changes made

## Stop Conditions
- `Market::Marketplace` already implements full order book — flag,
  design task may be simpler than expected
- `Financial::Account` cannot support atomic transfer — flag as
  blocking issue before designing settlement flow
- `BaseStructure` has no marketplace association and schema change
  is complex — flag before designing orbital order book

---

## Dependencies
**Blocked by**:
- `2026-04-12-HIGH-ARCHITECTURE-ORBITAL-SETTLEMENT-DECOUPLE-FROM-BASE.md` — completed ✓
**Blocks**:
- `2026-04-12-HIGH-ARCHITECTURE-GAS-STORAGE-CONCERN-DESIGN.md`
- All market implementation tasks
**Related**:
- `2026-04-07-HIGH-DATA-AI-MANAGER-MISSION-PROFILE-TRAINING-REFRESH.md`
- `2026-04-12-MEDIUM-ARCHITECTURE-POPULATION-MANAGEMENT-CONCERN.md`

---

## Notes
- Player UI for order placement is explicitly out of scope —
  flag as frontend task in implementation phases
- Wormhole network routing intersects with inter-system logistics —
  flag any dependencies found during audit
- Internal accounting log (transfer pricing for same-owner moves)
  is optional complexity — flag as Phase 4 or separate backlog item
