# 2026-04-03-HIGH-ARCHITECTURE-MATURITY BASED SNAP TRIGGERS

**Agent:** GPT-4.1 (0.25x)
**Priority:** HIGH
**Type:** ARCHITECTURE
**Status:** BACKLOG

## Context
Migrated from backlog_april_2026 archive.

## Summary
# Status: Verified March 15, 2026 — No evidence of completion in CURRENT_STATUS.md or git log. Task remains active.
# Implement Maturity-Based Snap Event Triggers

## Overview
Implement a two-stage ma...

---

## Original Content

# Status: Verified March 15, 2026 — No evidence of completion in CURRENT_STATUS.md or git log. Task remains active.
# Implement Maturity-Based Snap Event Triggers

## Overview
Implement a two-stage maturity system where expansion is triggered by infrastructure readiness—specifically the presence of Tugs, Cyclers, and Station IOC—coupled with the "Natural Window" (Random Event) logic. Remove all hard population limits. Snap events are triggered organically by infrastructure mass, transport volume, and the occurrence of a natural expansion window, not by arbitrary timelines or population thresholds.

## Task Breakdown

### Phase 1: Core System Maturity Tracking (2-3 weeks)
**Goal**: Implement Stage 1 maturity tracking for expansion readiness

**Tasks**:
1. **Create CoreSystemMaturityMonitor Class**
   - Add core system tracking to AI Manager
   - Implement population pressure calculations
   - Track economic capacity and GCC reserves
   - Monitor transportation readiness (ship counts)

2. **Expansion Readiness Assessment**
   - Infrastructure readiness: Tugs, Cyclers, and Station IOC must be present
   - Economic capacity and resource surplus (as supporting factors)
   - Transportation readiness (minimum viable inter-system vessels)
   - Natural Window: Random Event logic must trigger expansion opportunity

3. **Expansion Gate Logic**
   - Block wormhole discovery until infrastructure readiness and Natural Window are met
   - Implement gradual approach indicators (infrastructure milestones)
   - Create expansion preparation protocols

4. **AI Manager Integration**
   - Add infrastructure readiness and Natural Window logic to decision cycles
   - Implement core system development priorities
   - Create expansion planning logic

### Phase 2: Eden System Maturity Tracking (2-3 weeks)
**Goal**: Implement Stage 2 maturity tracking for snap triggers (infrastructure mass, transport volume, and network complexity)

**Tasks**:
1. **Create EdenSystemMaturityMonitor Class**
   - Add Eden system tracking to AI Manager
   - Implement infrastructure mass calculations
   - Track transport volume and settlement networks
   - Monitor economic activity levels

2. **Infrastructure Mass Tracking**
   - Track mass of all orbital and surface structures
   - Include settlements, stations, satellites, and transportation assets
   - Implement mass calculation algorithms with counterbalance effects
   - Account for system-specific stability multipliers (Eden: 0.6 vs Sol: 1.0)
   - Snap trigger requires both infrastructure mass and a triggered Natural Window event

3. **Economic Activity Monitoring**
   - Track monthly resource transport volumes
   - Monitor trade route activity
   - Calculate ISRU efficiency metrics

4. **Settlement Network Analysis**
   - Track operational settlements and network complexity
   - Snap trigger is based on network maturity and infrastructure, not a fixed settlement count

### Phase 3: Unified Risk Assessment (1-2 weeks)
**Goal**: Create comprehensive risk assessment across both stages

**Tasks**:
1. **Stage 1 Risk Logic**
   - Implement infrastructure readiness and Natural Window assessment
   - Define approach indicators (infrastructure milestones met)
   - Create expansion preparation warnings

2. **Stage 2 Risk Logic**
   - Implement snap risk assessment algorithm with counterbalance effects
   - Define risk thresholds accounting for system stability differences
   - Create risk progression logic that delays snap timing with slow buildup
   - Include buildup rate calculations for strategic timing
   - Snap risk is only present when both infrastructure and Natural Window are active

3. **AI Manager Integration**
   - Integrate dual-stage monitoring into decision cycles
   - Add maturity-based decision modifiers
   - Implement pre-snap preparation logic

4. **Warning Systems**
   - Add dual-stage status to admin dashboard
   - Create risk level notifications
   - Implement recommended action suggestions

### Phase 4: Mission Profile Updates (1-2 weeks)
**Goal**: Update mission profiles to include dual-stage maturity impacts

**Tasks**:
1. **Dual-Stage Impact Schema**
   - Define Stage 1 (expansion readiness) impact data structure
   - Define Stage 2 (snap risk) impact data structure
   - Add maturity fields to mission profile JSON schema
   - Create validation for dual-stage maturity data

2. **Core System Profile Updates**
   - Update missions affecting population growth
   - Add economic capacity building missions
   - Include transportation development impacts
   - Create resource surplus generation missions

3. **Eden System Profile Updates**
   - Update existing mission profiles with maturity impacts
   - Add maturity tracking to construction missions
   - Include economic activity modifiers
   - Create settlement network development missions

4. **Testing Validation**
   - Test dual-stage maturity calculations with sample missions
   - Validate risk progression with mission completion
   - Ensure backward compatibility

### Phase 5: UI Integration (1-2 weeks)
**Goal**: Add dual-stage maturity monitoring to admin interface

**Tasks**:
1. **Core System Dashboard**
   - Create expansion readiness display component
   - Add progress bars for population, economy, transportation
   - Implement readiness level indicators

2. **Eden System Dashboard**
   - Create maturity status display component
   - Add progress bars for infrastructure mass, transport volume
   - Implement risk level indicators

3. **Unified Maturity View**
   - Connect dual-stage data to live updates
   - Add maturity change notifications
   - Implement historical maturity tracking

4. **Admin Controls**
   - Add maturity simulation controls (for testing)
   - Create manual expansion gate override
   - Create manual snap trigger (emergency override)
   - Implement maturity threshold configuration

### Phase 6: Snap Event Logic (2-3 weeks)
**Goal**: Implement actual snap triggering and response

**Tasks**:
1. **Expansion Gate Control**
   - Implement wormhole discovery blocking until Stage 1 readiness
   - Add gradual expansion preparation phases
   - Create expansion readiness notifications

2. **Snap Trigger Conditions**
   - Implement Stage 2 maturity-based snap detection
   - Add mass limit checking logic
   - Create snap probability calculations

3. **Snap Event Handler**
   - Implement wormhole exit shifting
   - Handle colony orphaning logic
   - Create reconnection protocols

4. **AWS Activation**
   - Implement pre-built AWS activation
   - Add EM harvesting startup
   - Create dual-link network establishment

5. **Consortium Formation**
   - Implement automatic Consortium creation
   - Add voting system initialization
   - Create dividend distribution setup

### Phase 7: Testing & Balancing (2 weeks)
**Goal**: Test and balance the dual-stage maturity system

**Tasks**:
1. **Unit Testing**
   - Test Stage 1 expansion readiness calculations
   - Test Stage 2 maturity calculations
   - Validate risk assessments
   - Check snap trigger conditions

2. **Integration Testing**
   - Test with full AI Manager cycles
   - Validate mission profile impacts
   - Check UI updates across both stages

3. **Balance Tuning**
   - Adjust Stage 1 expansion thresholds
   - Tune Stage 2 snap timing curves
   - Balance progression between stages

4. **Scenario Testing**
   - Test different development paths through both stages
   - Validate snap timing variability
   - Check edge cases and error conditions

## Success Criteria
- ✅ AI Manager tracks Stage 1 core system expansion readiness accurately
- ✅ Wormhole discovery blocked until core system maturity requirements met
- ✅ AI Manager tracks Stage 2 Eden system maturity metrics accurately
- ✅ Snap events triggered by Eden system maturity conditions, not fixed timelines
- ✅ Admin interface displays dual-stage maturity status and risk levels
- ✅ Mission profiles include dual-stage maturity impact data
- ✅ Snap event properly orphans colonies and establishes dual-link network
- ✅ Consortium formation works correctly
- ✅ System scales across different development speeds and play styles

## Dependencies
- AI Manager Phase 4A complete (multi-body coordination)
- Mission profile system operational
- Admin dashboard framework available
- Wormhole mechanics implemented
- Core system development tracking (population, economy, transportation)

## Risk Assessment
**High Risk**: Dual-stage logic complexity could introduce integration issues
**Mitigation**: Implement stages separately, integrate with comprehensive testing

**Medium Risk**: Balancing expansion readiness thresholds for different play styles
**Mitigation**: Make thresholds configurable, allow testing overrides, gather player feedback

**Medium Risk**: Ensuring organic progression between stages feels natural
**Mitigation**: Extensive scenario testing, iterative balance tuning

**Low Risk**: UI integration for dual-stage display
**Mitigation**: Standard component development with clear data separation

## Timeline
- **Phase 1-2**: 4-6 weeks (dual-stage maturity tracking)
- **Phase 3-4**: 2-4 weeks (profiles and UI)
- **Phase 5-6**: 4-5 weeks (expansion gates, snap logic)
- **Phase 7**: 2 weeks (testing and balancing)
- **Total**: 12-17 weeks for complete implementation

## Testing Approach
1. **Unit Tests**: Individual maturity calculations for both stages
2. **Integration Tests**: Full AI Manager with dual-stage maturity tracking
3. **Scenario Tests**: Different development paths through both stages to snap
4. **Balance Tests**: Adjust thresholds for desired timing and feel
5. **UI Tests**: Dual-stage maturity dashboard functionality

## Deliverables
- CoreSystemMaturityMonitor class implementation
- EdenSystemMaturityMonitor class implementation with counterbalance effects
- Updated mission profile schema with dual-stage maturity data
- Dual-stage maturity dashboard UI components
- Expansion readiness gate logic
- Snap event triggering logic with buildup rate delays
- Counterbalance effect calculations for system stability
- Consortium formation system
- Comprehensive test suite
- Documentation updates for two-stage system with corrected mass limits</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/active/implement_maturity_based_snap_triggers.md
