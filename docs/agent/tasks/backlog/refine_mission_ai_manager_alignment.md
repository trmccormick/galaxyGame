# Mission Plan Refinement: AI Manager Role Alignment

## Task Overview
Review and refine mission plans to properly separate Development Corporation establishment (missions) from ongoing AI Manager operations (mega projects, resource management, terraforming). Missions should focus on footholds and handoffs, while AI Manager handles sustained operations.

## Background
Current mission plans include resource harvesting and operational management that should be handled by the AI Manager. This creates role confusion and potential conflicts. Missions should establish the initial foothold and Development Corporation, then hand off to AI Manager for ongoing operations.

## Current Role Separation Analysis

### ✅ Missions Should Handle:
- **Development Corporation Creation**: Establishing new DCs with initial funding and charters
- **Initial Footholds**: Basic infrastructure for presence (landing sites, basic habitats)
- **Pattern Demonstration**: Showing AI Manager the "establishment technique"
- **Handoff Triggers**: Clear conditions for AI Manager takeover

### ✅ AI Manager Should Handle:
- **Mega Projects**: Stations, worldhouses, terraforming after establishment
- **Resource Management**: Harvesting only when players don't fill buy orders
- **Sell Order Creation**: For excess materials
- **Ongoing Operations**: Sustained corporate management

## Mission Plan Issues Identified

### 1. Resource Harvesting in Missions
**Problem**: Missions include detailed resource harvesting phases that duplicate AI Manager responsibilities
**Example**: Mars settlement phases include "Resource Extraction Infrastructure" and "Fuel Processing"
**Impact**: Conflicts with AI Manager's resource procurement logic

### 2. Operational Management in Missions
**Problem**: Missions extend into operational phases that should be AI-managed
**Example**: Titan mission includes "Interplanetary Logistics Network" phase
**Impact**: Missions become too long and overlap with AI Manager scope

### 3. Missing Handoff Points
**Problem**: No clear transition from mission completion to AI Manager takeover
**Example**: Missions end with "establishment complete" but don't specify AI Manager activation
**Impact**: Gap between mission completion and sustained operations

## Required Refinements

### Phase 1: Mission Scope Reduction
- **Remove Resource Operations**: Strip out detailed harvesting phases from missions
- **Focus on Establishment**: Limit missions to initial foothold creation
- **Add Handoff Metadata**: Include AI Manager activation triggers

### Phase 2: AI Manager Integration Points
- **Handoff Conditions**: Define when AI Manager takes over (e.g., "DC established with 6-month resource buffer")
- **Pattern Learning Hooks**: Ensure missions demonstrate techniques for AI learning
- **Resource Baseline**: Missions should leave sufficient initial resources for AI Manager bootstrap

### Phase 3: Mission Template Updates
- **Establishment Template**: Standardize initial foothold creation
- **DC Charter Template**: Consistent Development Corporation setup
- **AI Handoff Template**: Standardized transition protocols

## Mission Refinement Examples

### Current Mars Mission (Too Operational):
```
Phase 1: Orbital Establishment
Phase 2: Surface Outposts
Phase 3: Resource Mining Operations ← Should be AI Manager
Phase 4: Industrial Processing ← Should be AI Manager
```

### Refined Mars Mission (Establishment-Focused):
```
Phase 1: Orbital Establishment (DC Creation)
Phase 2: Initial Surface Foothold (Basic habitat + ISRU seed)
Phase 3: AI Manager Handoff (Resource buffer + operational patterns demonstrated)
```

### AI Manager Takeover Triggers:
```json
"handoff_conditions": {
  "development_corporation_established": true,
  "initial_resource_buffer_months": 6,
  "basic_infrastructure_online": true,
  "ai_pattern_demonstrated": "mars_phobos_model"
}
```

## Success Criteria
- [ ] Missions focus only on establishment, not ongoing operations
- [ ] Clear handoff points to AI Manager defined
- [ ] No resource harvesting phases in mission plans
- [ ] AI Manager integration points documented
- [ ] Pattern learning hooks preserved for AI training

## Files to Create/Modify
- `data/json-data/missions/templates/establishment_template.json` - New template
- `data/json-data/missions/templates/ai_handoff_template.json` - New template
- Update all existing mission profiles to remove operational phases
- `docs/architecture/ai_manager/MISSION_AI_INTEGRATION.md` - New integration guide

## Estimated Time
4-6 hours

## Priority
HIGH (Role Clarity)