---
status: design-needed
priority: HIGH
type: design
system_domain: AI_MANAGER
parent_task: AI Manager Resource Spawning System (2026-05-01)
created: 2026-05-18
supervision_level: 🔴 WATCHED CAREFULLY - Core resource persistence mechanic
assigned_to: You (game design) + Local Agent (Rails patterns)
---

# DESIGN: Resource Deposit Model and Persistence Layer

**Status**: DESIGN INVESTIGATION REQUIRED  
**Priority**: HIGH  
**Type**: design  
**Parent**: AI Manager Resource Spawning System  
**Supervision**: 🔴 Watched carefully — foundational persistence layer  
**Blockers**: Blocks all spawning implementation tasks  
**Requires**: You (game design intent) + Local Agent (Rails pattern expertise)

---

## Context

**Data Integrity Foundation**: During Phase 1 work (2026-05-01), the team established that sol.json contains **only confirmed real scientific data** for known bodies:
- Known deposit locations: in geological features files
- Estimated total amounts: in stored_volatiles and materials
- No speculative or procedural deposit data is hardcoded

For generated worlds and unexplored regions, deposit locations must be spawned procedurally by AI Manager.

## Design Principles (Inherited from Architecture)

### Real data drives plausibility
- `stored_volatiles` = scientific upper bound on what exists
- `materials` array = confirmed resource types present
- `crust_composition` = mineral makeup informing ore types
- AI Manager uses these as input constraints

### Civ4/FreeCiv resource placement model  
- Resources spawn in geologically appropriate locations
- Rare resources spawn rarely
- Surface resources always present (regolith, PSR deposits)
- Subsurface resources require survey to reveal

### Equipment tier gates access
- Basic equipment: surface/regolith only
- Advanced equipment: subsurface/rare resources
- Deposit exists regardless; visibility determined by tier

## Problem Statement

The codebase has `ResourcePositioningService` for map-based resource placement, but **no database model to persist spawned deposits as discovered resources**. This prevents:

- Storing deposit locations on celestial bodies
- Tracking which deposits have been surveyed
- Persisting deposit state across game sessions
- Equipment-gated access to different deposit types

## Design Questions to Answer

### 1. Deposit Model Structure

**Needed Design Decision**:
- Should deposits be owned by a CelestialBody, Settlement, or both?
- What attributes define a deposit?
  - Location (lat/long? region_id? hex grid?)
  - Resource type (regolith, water_ice, methane_clathrate, ore, etc.)
  - Quantity (total available, extraction depth)
  - Equipment tier required to access
  - Discovery status (unknown, surveyed, depleted, etc.)
- Should deposits have geological features (lava tubes, subsurface caverns)?

### 2. Deposit Types & Tiers

**Need to Define**:
```
Surface/Regolith (always accessible):
  - regolith
  - dust
  - psr_volatiles
  
Early ISRU (basic equipment):
  - water_ice
  - simple_ores
  
Advanced (specialized equipment):
  - clathrate_deposits
  - rare_metals
  - geothermal_vents
  
Deep Subsurface (expensive to access):
  - deep_water_reserves
  - rare_earth_elements
```

Question: Are these tiers enforced in the model, or in the UI/capability layer?

### 3. Database Schema

**Questions**:
- New table: `resource_deposits`?
- Polymorphic relationship? (deposits can belong to Bodies, Settlements, or Regions?)
- How do we store deposit location on spherical bodies? (lat/long, grid tile, feature_id?)
- Do we need versioning if deposits change (deplete over time)?

### 4. Relationship to Existing Models

**Current Context**:
- `CelestialBody` has `stored_volatiles` (totals, not locations)
- `CelestialBody` has `materials` array (confirmed types, not locations)
- `GeologicalFeature` has `surveyed?` status
- `Settlement` tracks resources via Inventory

**Design Decision Needed**:
- Should deposits be linked to GeologicalFeatures?
- Should Settlement inventory pull from nearby deposits?
- How do we track depletion?

---

## Acceptance Criteria for Design

- [ ] Define complete Deposit model schema (attributes, relationships)
- [ ] Specify deposit types and access tiers
- [ ] Document how deposits relate to CelestialBody properties (stored_volatiles, materials)
- [ ] Propose database table structure
- [ ] Define location representation for spherical bodies
- [ ] Document how deposits are discovered/surveyed
- [ ] Specify depletion mechanics (if applicable)
- [ ] Show example JSON structure for a deposit

---

## Next Steps After Design Approval

Once this design is approved:
1. Create migration for resource_deposits table
2. Create ResourceDeposit model
3. Create factories for testing
4. Link to other implementation tasks

---

## Required Input From

- **Gemini**: Deep-dive on geological plausibility - what deposit types go where?
- **Local Agent**: Database schema design and Rails model patterns
- **You**: Game design intent - how should players interact with deposits?

