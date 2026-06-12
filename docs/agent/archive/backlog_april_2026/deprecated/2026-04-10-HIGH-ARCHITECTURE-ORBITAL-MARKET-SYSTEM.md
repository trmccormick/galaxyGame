# TASK: Orbital Market System — Architecture Design (ARCHIVED)
**Status**: DEPRECATED — SUPERSEDED BY IMPLEMENTATION
**Priority**: HIGH → N/A  
**Type**: architecture → EXTRACTED TO PHASE 5+ FEATURE TASKS
**Created**: 2026-04-10
**Last Updated**: 2026-06-08 (archived during backlog triage)

---

## ⚠️ ARCHIVE NOTE — DO NOT IMPLEMENT FROM THIS FILE

Original task requested architecture design for orbital market system with order books, GCC settlement, and gas processing pipelines. **Core infrastructure already implemented between April-June 2026.** This file is preserved for historical reference only.

### What Was Implemented (Supersedes Original Task)
- ✅ `Market::Order` model + `Marketplace#match_orders` — order book system LIVE  
- ✅ `Financial::Account.transfer_funds()` with tax collection service — GCC settlement LIVE  
- ✅ `Market::TradeExecutionService` orchestrates trades with inventory updates — LIVE  
- ✅ AI Manager monitors buy orders via StateAnalyzer/ISRU Optimizer (Luna Phase 3) — LIVE
- ✅ `Structures::OrbitalStructure` fully implemented with docking/storage capabilities — LIVE

### What Was Extracted as New Task (Actionable Work Remaining)
**Gas processing pipeline gap identified during triage → extracted to:**  
📄 `docs/new_agent/projects/galaxy_game/tasks/backlog/phase5+/2026-06-HIGH-FEATURE-ORBITAL-GAS-PROCESSING-PIPELINE.md`

This Phase 5+ task implements:
- Raw gas → processed propellant transformation at L1 Station  
- Skimmer overflow routing logic (L1 primary, secondary depot fallback)  
- AI Manager as orbital depot owner managing bid/ask spreads  
- Auto-listing of processed outputs on marketplace  

**Why Phase 5?** Luna Phases 1-3 establish Earth→Luna supply chain. Gas processing at L1 becomes critical when skimmers harvest Venus atmosphere and cyclers need refueling stops for interplanetary transit.

### Implementation Evidence (For Reference)
See `docs/new_agent/projects/galaxy_game/status.md` — "Confirmed Architecture" section:
- Market order system fully implemented with buy/sell enums, expiration tracking  
- Financial account transfer_funds supports NPC overdraft + transaction logging  
- Trade execution service integrates tax collection, inventory updates, trade records creation

---

## Agent Assignment (Original — Historical Reference Only)
**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Architecture design task — requires reasoning about
market mechanics, game economy, player and AI interaction patterns.
No code changes. Design document output only.
**Supervision Level**: 🟡 Standard

---

## Context

The orbital economy core loop is:

1. **Harvester craft** docks at an `OrbitalStructure` fitted as a depot
2. Harvester wants to **sell** raw harvested gases (methane, CO2, H2, etc.)
3. Harvester wants to **buy** processed propellant (LOX, liquid CH4) to refuel
4. **Depot owner** (AI Manager or player) runs processing equipment on the
   structure — buys raw inputs, processes them, sells outputs at margin
5. **Market orders** — any account holder can place buy/sell orders at any
   structure they have docking access to
6. **Order matching** — lowest sell price fills first, highest buy price
   fills first, GCC settles immediately on fill
7. **Processing pipeline** — raw gas → processing unit → processed output,
   time and energy cost, output listed on market automatically

**Key design decisions confirmed:**
- Both players and AI Manager participate in the same order book
- AI Manager is the depot owner in most cases but players can own depots too
- The structure (`OrbitalStructure`) is the physical location of the exchange
- The settlement (`OrbitalSettlement`) owns the structures and holds the account
- Gas storage on the structure inventory is the escrow for pending orders
- Each structure has its own docking and its own local market/order book
- `BaseSettlement` already has `has_one :marketplace` — understand this
  before designing

**Existing market infrastructure to audit:**
- `Market::Marketplace` — already exists on settlements
- `Financial::Account` — GCC settlement already works
- `Inventory` system — already handles item storage

---

## Problem Statement

**Current behavior**: Gas transfer between craft and depot is modeled as
direct inventory manipulation (`add_gas`, `remove_gas` methods on
`OrbitalDepot` — now retired). No market orders, no price discovery,
no GCC settlement, no player participation.

**Expected behavior**: A proper order book at each orbital structure where:
- Sellers list resources at ask prices
- Buyers place orders at bid prices or buy at market
- Orders match and GCC settles automatically
- Processing equipment transforms inputs to outputs and lists them
- AI Manager participates as depot owner, managing spread and inventory
- Players participate as harvesters, traders, or depot operators

---

## Design Questions to Answer

### 1. Order book location
Does the order book live on the `OrbitalStructure`, the `OrbitalSettlement`,
or the existing `Market::Marketplace`? What does `Market::Marketplace`
currently do and does it already support order books?

```bash
cat app/models/market/marketplace.rb
```

### 2. Order model
Does a market order model already exist? If so, what does it look like?
```bash
find app/models/market/ -name "*.rb" | xargs ls
grep -rn "class.*Order\|BuyOrder\|SellOrder" app/models/ --include="*.rb"
```

### 3. GCC settlement
How does `Financial::Account` currently handle transfers?
```bash
grep -n "def transfer\|def debit\|def credit" app/models/financial/account.rb
```

### 4. Processing pipeline
How do processing units currently work? What triggers output production?
```bash
grep -rn "processing_service\|ProcessingService" app/services/ --include="*.rb" | head -10
cat app/services/processing_service.rb | head -60
```

### 5. AI Manager market participation
How does AI Manager currently make economic decisions?
```bash
grep -n "buy_order\|sell_order\|market_order\|place_order" app/services/ai_manager/ -r --include="*.rb"
```

---

## Output — Architecture Design Document

Produce a design document covering:

```
EXISTING INFRASTRUCTURE AUDIT
==============================
Market::Marketplace: [what it does, what it doesn't do]
Order model: [exists / doesn't exist — describe]
Financial::Account transfer: [how it works]
Processing pipeline: [how it works currently]
AI Manager market participation: [current state]

PROPOSED ARCHITECTURE
=====================

Order Book
----------
Location: [OrbitalStructure | OrbitalSettlement | Marketplace — recommend one]
Reasoning: [why]

Order Model
-----------
Fields: [list]
Types: [buy / sell / market]
Lifecycle: [open → partially_filled → filled | cancelled]

Order Matching
--------------
Trigger: [when does matching run]
Algorithm: [price-time priority or other]
GCC settlement: [how transfer happens on fill]

Processing Pipeline
-------------------
Trigger: [what starts processing]
Input consumption: [how raw materials are drawn from inventory]
Output production: [how processed goods enter inventory and market]
Time model: [tick-based / real-time / instant]

AI Manager Participation
------------------------
Depot owner strategy: [how AI sets bid/ask prices]
Inventory management: [when AI buys raw / sells processed]
Profit optimization: [how AI Manager measures success]

Player Participation
--------------------
Interface: [how players place orders — UI hooks out of scope, flag for frontend task]
Harvester flow: [dock → sell raw → buy processed → undock]
Depot operator flow: [own structure → set prices → manage inventory]

MARKET EVENTS
=============
Events that trigger market notifications: [list]
Events that trigger AI Manager decisions: [list]

IMPLEMENTATION PHASES
=====================
Phase 1 — [describe minimal viable order book]
Phase 2 — [describe processing pipeline integration]
Phase 3 — [describe AI Manager participation]
Phase 4 — [describe player UI hooks — flag for frontend task]

RISKS AND OPEN QUESTIONS
========================
[list anything that needs human decision before implementation]

FOLLOW-UP IMPLEMENTATION TASKS NEEDED
======================================
[list tasks in phase order with scope and recommended agent tier]
```

---

## Acceptance Criteria
- [ ] Existing market infrastructure fully audited
- [ ] Order book location decided with reasoning
- [ ] Order model designed with full field list
- [ ] GCC settlement flow described
- [ ] Processing pipeline integration described
- [ ] AI Manager participation strategy described
- [ ] Implementation phases defined
- [ ] No code changes made

---

## Stop Conditions
- `Market::Marketplace` already implements a full order book — flag
  immediately, design task may be unnecessary
- `Financial::Account` cannot support atomic transfer on order fill —
  flag before designing settlement flow
- Processing pipeline requires a game tick system that doesn't exist —
  flag as a dependency

---

## Dependencies
**Blocked by**:
- `2026-04-10-HIGH-REFACTOR-RETIRE-SPACESTATION-ORBITALDEPOT.md`
- `2026-04-10-MEDIUM-ARCHITECTURE-ORBITAL-SETTLEMENT-LOCATION.md`
**Blocks**: All orbital market implementation tasks
**Related tasks**:
- `2026-04-07-HIGH-DATA-AI-MANAGER-MISSION-PROFILE-TRAINING-REFRESH.md`
  — AI Manager needs training data updated after market system is designed

---

## Notes
- Player UI for order placement is explicitly out of scope for this design
  task — flag it as a frontend task when implementation phases are written
- The `structure_lookup_service` and `logistics_service` path references
  to `space_stations` are a separate cleanup task — do not include here
- Wormhole network routing intersects with logistics and market — flag
  any dependencies found during audit

---

## Completion Report
*Filled in by implementing agent after completion*

**Completed by**:
**Completion date**:
**Final test result**: N/A — design document only

### Design document location
### Key decisions made
### Open questions requiring human input
### Follow-up tasks created
### Lessons learned
