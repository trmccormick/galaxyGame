# Mission Plan Refinement: AI Manager Bootstrap Phase Integration

## Task Overview
Refine mission plans to properly integrate AI Manager's critical bootstrap harvesting role during early foothold establishment, while maintaining clear separation from ongoing operational resource management.

## Background
Upon review, the AI Manager DOES handle resource harvesting during the critical bootstrap phase - when missions establish footholds but bases aren't yet operational. This is essential for building initial infrastructure before players arrive. The key is distinguishing between:

- **Bootstrap Harvesting** (AI Manager): Initial resource gathering to make base operational
- **Operational Harvesting** (Players + AI Fallback): Ongoing resource management after base is established

## Current Understanding (Corrected)

### ✅ Missions Should Handle:
- **Development Corporation Creation**: Establishing new DCs with initial funding and charters
- **Initial Footholds**: Basic infrastructure for presence (landing sites, basic habitats)
- **Bootstrap Resource Setup**: Initial AI-managed harvesting to build operational base
- **Transition Triggers**: Clear handoff to player-driven operations

### ✅ AI Manager Bootstrap Role:
- **Early Harvesting**: Resource gathering during foothold establishment (before players arrive)
- **Infrastructure Building**: Using harvested resources to make base operational
- **Pattern Learning**: Learning bootstrap techniques from mission demonstrations
- **Transition Handoff**: Shifting to operational mode when base becomes player-accessible

### ✅ AI Manager Operational Role:
- **Fallback Harvesting**: Only when players don't fill buy orders
- **Sell Order Creation**: For excess materials
- **Mega Projects**: Stations, worldhouses, terraforming after establishment

## CRITICAL DISCOVERY: Operational Phase Implementation Gap

### ❌ **Major Finding**: Operational Escalation Logic Not Implemented
**Status**: The AI Manager's operational phase escalation system is **fully documented but completely unimplemented**

**What's Documented** (PLAYER_CONTRACT_SYSTEM.md):
- `handle_expired_buy_orders()` function
- 3-tier escalation: Special Missions → Automated Harvesters → Scheduled Imports
- Cost optimization (harvesters cheapest, imports most expensive)
- 48-hour player opportunity windows

**What's Missing**:
- No `EscalationService` or `handle_expired_buy_orders` implementation
- No automated harvester deployment logic
- No special mission creation for expired orders
- No scheduled import coordination
- Existing `ContractCreationService` is stub-level only

**Impact**: AI Manager cannot currently perform operational fallback harvesting - the entire escalation system is missing!

## Mission Plan Analysis (Revised)

### ✅ Correctly Included Bootstrap Phases:
- **Mars Settlement**: Resource phases are bootstrap harvesting to build operational base
- **Titan Resource Hub**: Early harvesting establishes fuel depot before player operations
- **Ceres Settlement**: Initial mining creates operational water/metal supply chain

### ⚠️ Issues Still Present:

#### 1. Bootstrap vs Operational Clarity
**Problem**: Mission phases don't clearly distinguish bootstrap harvesting from operational phases
**Impact**: Unclear when AI Manager transitions from bootstrap to operational mode

#### 2. Transition Triggers Missing
**Problem**: No clear "base operational" triggers for AI Manager mode switch
**Impact**: AI Manager might continue bootstrap harvesting when it should switch to fallback mode

#### 3. Pattern Documentation
**Problem**: Bootstrap harvesting patterns not clearly documented for AI learning
**Impact**: AI Manager may not learn correct bootstrap techniques

#### 4. 🚨 **CRITICAL**: Operational Escalation Implementation Missing
**Problem**: The documented operational fallback system doesn't exist in code
**Impact**: AI Manager cannot handle expired buy orders or perform automated harvesting
**Priority**: **BLOCKER** - Must implement before operational phases can work

## Required Refinements (Revised)

### Phase 1: Bootstrap Phase Clarification
- **Label Bootstrap Phases**: Clearly mark which resource phases are AI bootstrap harvesting
- **Transition Conditions**: Define when base becomes "operational" (player-accessible)
- **AI Mode Documentation**: Document bootstrap vs operational AI Manager behaviors

### Phase 2: Transition Integration
- **Handoff Triggers**: Define conditions for AI Manager to switch from bootstrap to operational mode
- **Player Integration Points**: When players can start filling buy orders
- **Resource Buffer Requirements**: Minimum resources needed for operational transition

### Phase 3: Pattern Learning Enhancement
- **Bootstrap Pattern Documentation**: Clear documentation of bootstrap harvesting techniques
- **Success Metrics**: What constitutes successful bootstrap completion
- **Failure Scenarios**: When bootstrap harvesting should trigger player intervention

## Bootstrap vs Operational Distinction

### Bootstrap Harvesting (AI Manager - Early Phase):
```json
"bootstrap_harvesting": {
  "purpose": "Build operational base infrastructure",
  "ai_role": "Primary resource manager",
  "player_role": "Not yet available",
  "completion_trigger": "base_operational_with_3_month_resource_buffer",
  "transition_to": "operational_fallback_mode"
}
```

### Operational Harvesting (AI Manager - Fallback):
```json
"operational_harvesting": {
  "purpose": "Fill unfilled player buy orders",
  "ai_role": "Fallback resource manager",
  "player_role": "Primary resource manager",
  "trigger": "player_buy_orders_unfilled_for_48_hours",
  "sell_orders": "create_for_excess_materials"
}
```

## Success Criteria
- [ ] Bootstrap harvesting phases clearly labeled in missions
- [ ] Transition triggers defined for AI Manager mode switching
- [ ] Pattern learning documentation enhanced for bootstrap techniques
- [ ] Clear distinction between bootstrap and operational AI harvesting roles
- [ ] Player integration points properly defined

## Files to Create/Modify
- `docs/architecture/ai_manager/BOOTSTRAP_HARVESTING.md` - New documentation
- Update mission profiles with bootstrap phase labels
- `data/json-data/missions/_metadata/bootstrap_patterns.json` - Pattern documentation
- `docs/architecture/ai_manager/AI_MODE_TRANSITIONS.md` - Transition logic

## Estimated Time
3-4 hours

## Priority
HIGH (Critical Role Clarification)