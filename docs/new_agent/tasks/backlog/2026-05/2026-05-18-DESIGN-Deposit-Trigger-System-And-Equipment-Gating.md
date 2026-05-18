---
status: design-needed
priority: HIGH
type: design
system_domain: AI_MANAGER
parent_task: AI Manager Resource Spawning System (2026-05-01)
created: 2026-05-18supervision_level: 🔴 WATCHED CAREFULLY - Core progression mechanic
assigned_to: You (game design/UX) + Gemini (progression balance)depends_on: 2026-05-18-DESIGN-Resource-Deposit-Model-And-Persistence.md
---

# DESIGN: Deposit Trigger System and Equipment Gating

**Status**: DESIGN INVESTIGATION REQUIRED  
**Priority**: HIGH  
**Type**: design  
**Parent**: AI Manager Resource Spawning System  
**Supervision**: 🔴 Watched carefully — gates early vs advanced game progression  
**Depends On**: Resource Deposit Model (design must come first)  
**Blockers**: Blocks all trigger-based spawning implementation

---

## Design Principles (Inherited from Architecture)

### Equipment tier gates access, not existence
- All deposits exist on a celestial body regardless of player equipment
- Equipment tier determines **visibility** and **accessibility**
- Tier-0 equipment: only surface resources visible
- Tier-1 equipment: subsurface resources revealed
- Tier-2+ equipment: deep resource access unlocked
- **This separation enables early/mid/late game progression pacing**

### Surface resources are always accessible (early ISRU)
- Regolith, PSR deposits always visible
- No survey required for surface resources
- Enables basic settlement ISRU from Day 1

### Subsurface resources require progressive unlocks
- Survey missions reveal what tier-2+ deposits exist
- Mining equipment tier gates which deposits are accessible
- Gating creates mid-game progression bottleneck

## Problem Statement

The codebase has no system to:
- Trigger deposit spawning at appropriate game moments (survey, settlement planning, mission start)
- Gate deposit access by player equipment tier
- Reveal deposits progressively as player capability increases

## Design Questions to Answer

### 1. Trigger Events

**When should deposits be spawned?**

Possible triggers:
```
ON SURVEY:
  - Player scans a region/hemisphere
  - Action: Reveal existing deposits, spawn undiscovered ones
  - Question: How do we define "a region"? (hex tile? lat/long band?)

ON SETTLEMENT PLANNING:
  - Player indicates intent to build settlement
  - Action: Spawn nearby deposits for ISRU planning
  - Question: How far from settlement should deposits be visible?
  - Question: Should rare deposits spawn on demand, or pre-exist?

ON MISSION INITIATION:
  - Player launches exploration/mining mission
  - Action: Ensure mission has access to target deposits
  - Question: Should deposits be guaranteed, or probabilistic?

ON FIRST VISIT:
  - Player first lands on a celestial body
  - Action: Generate initial deposit map
  - Question: Should all deposits spawn, or only surface resources?
```

**Design Decision Needed**:
- Which triggers are required for MVP?
- Should triggers be asynchronous (background job) or synchronous?
- Do we pre-generate all deposits upfront, or on-demand?

### 2. Equipment Tiers & Access Control

**What equipment does a player need to access each deposit type?**

Example structure needed:
```
TIER 0 - Basic (hand tools, rover):
  ✓ Regolith (surface dust)
  ✓ Surface volatiles (water ice if PSR monitoring)
  ✗ Subsurface reserves
  ✗ Rare metals
  
TIER 1 - Early ISRU (simple extractors):
  ✓ Everything from Tier 0
  ✓ Water ice (with ice harvester)
  ✓ Methane/CO2 (with atmospheric processor)
  ✗ Clathrates (requires specialized equipment)
  ✗ Deep subsurface (requires mining operation)
  
TIER 2 - Advanced Mining:
  ✓ Everything from Tier 1
  ✓ Clathrate deposits
  ✓ Rare metals (if surveyed)
  ✗ Deep mantle resources
  
TIER 3 - Industrial (orbital-scale):
  ✓ Everything
  ✓ Deep subsurface
  ✓ Speculative "dark matter" resources
```

**Design Questions**:
- Are tiers defined globally, or per-body?
- Should equipment be tracked per Unit/Settlement?
- How do we gate: at spawn time, at access time, or both?
- What happens if player tries to access tier-2 deposit with tier-1 equipment?

### 3. Deposit Visibility Rules

**When should a deposit be visible to the player?**

Visibility states:
```
UNKNOWN:
  - Deposit exists, but player has no equipment to detect it
  - Not shown in UI

DETECTED (via survey):
  - Equipment tier sufficient to detect it
  - Shown in UI, not yet extracted

SURVEYED (detailed exploration):
  - Player has detailed composition/quantity data
  - Ready for extraction planning

DEPLETED:
  - Resource exhausted
  - No longer available
```

**Design Decision Needed**:
- Should surveys require mission/rover deployment?
- Should surveys take time (game turns)?
- Should player see "unknown deposits exist here" before equipment upgrade?

### 4. Settlement-Specific Rules

**When settlement plans for ISRU, what deposits should be accessible?**

Questions:
- Should settlement only see deposits within X km?
- Should settlement-founded deposits be permanent, or competitive?
- Can multiple settlements extract from same deposit?
- What happens when deposit depletes?

---

## Trigger Implementation

### Scenario: Player Surveys Luna's South Pole

**Current State**: Luna has real geological feature data, but no spawned deposits for undiscovered resources

**Trigger Flow**:
```
1. Player initiates survey mission to South Pole region
2. Survey completes
3. System checks: what does player equipment tier allow?
4. PlausibilityEngine evaluates Luna properties (stored_volatiles, etc.)
5. DepositSpawner creates deposits matching:
   - Player equipment tier
   - Geological plausibility
   - Real scientific data (max amounts)
6. DepositRepository persists new deposits
7. Player sees results in UI
```

**Design Questions**:
- Should step 5 create ALL tier-0 deposits, or sample them?
- Should subsequent surveys create additional deposits, or re-check?
- How long before deposits can be re-surveyed?

---

## Acceptance Criteria for Design

- [ ] Define all trigger events (survey, settlement, mission, first-visit)
- [ ] Specify which triggers are MVP vs future
- [ ] Document equipment tier structure (0-3 minimum)
- [ ] Define what equipment each tier can access
- [ ] Specify deposit visibility rules (unknown/detected/surveyed/depleted)
- [ ] Document settlement ISRU deposit access rules
- [ ] Propose trigger implementation strategy (who calls when?)
- [ ] Show example: "Luna survey with Tier 1 equipment reveals X deposits"

---

## Next Steps After Design Approval

Once this design is approved:
1. Create EquipmentTierService or Gem
2. Create TriggerDispatcher or event system
3. Integrate with DepositSpawner
4. Add trigger tests (factories for equipment states)

---

## Required Input From

- **You**: Game design - what's the player progression? When should they access what?
- **Gemini**: Geological accuracy - can players really mine deep subsurface easily?
- **Local Agent**: Event system implementation patterns in Rails

