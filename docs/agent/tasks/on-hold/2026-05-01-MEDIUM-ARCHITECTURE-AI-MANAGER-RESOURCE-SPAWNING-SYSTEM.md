# TASK: AI Manager Resource Spawning System
**Status**: ON-HOLD
**Priority**: MEDIUM
**Type**: architecture
**Created**: 2026-05-01
**Promote to active**: Phase 3
**Last Updated**: 2026-05-01

---

## Agent Assignment
**Assigned To**: Claude 1x + GPT-4.1 0x
**Why This Agent**: Architectural design (Claude) + implementation (GPT-4.1)
**Supervision Level**: 🔴 Watched carefully — core game mechanic

---

## Context

During Phase 1 data integrity work (2026-05-01), the team established
that sol.json contains only **confirmed real scientific data** for known
bodies. This means:

- Known deposit locations are in geological features files
- Estimated total amounts are in stored_volatiles and materials
- **No speculative or procedural deposit data is hardcoded in JSON**

For generated worlds and unexplored regions of known worlds, deposit
locations do not exist in any JSON file — they must be spawned by the
AI Manager at the appropriate game moment (survey, exploration, 
settlement planning).

This task designs and implements that spawning system.

---

## Problem Statement

**Current behavior**:
- sol.json tracks confirmed scientific data for known bodies
- Generated worlds have no JSON data at all
- No system exists to place mineable deposit locations procedurally
- PrecursorCapabilityService reads total amounts but cannot tell the
  player where to actually mine

**Required behavior**:
- AI Manager reads body properties (atmosphere, geosphere, stored_volatiles,
  materials, geological_features) to understand what resources are plausible
- AI Manager spawns deposit locations procedurally when triggered
  (player surveys a region, settlement is planned, mission is initiated)
- Generated worlds get full resource deposit sets on first survey
- Known worlds (Luna, Mars etc.) get deposit locations spawned for
  unconfirmed/unknown deposits — confirmed deposits already exist in
  geological features
- Spawned deposits persist in the database as discovered resources

---

## Design Principles

### Real data drives plausibility
- `stored_volatiles` amounts = scientific upper bound on what exists
- `materials` array = confirmed resource types present on body
- `crust_composition` = mineral makeup, informs ore deposit types
- AI Manager uses these as input — never ignores them

### Civ4/FreeCiv resource placement model
- Resources spawn in geologically appropriate locations
- Rare resources spawn rarely
- Surface resources (regolith, psr_deposits) are always present
- Subsurface resources (clathrates, sedimentary) require survey to reveal
- Generated worlds follow same rules as known worlds

### Early ISRU vs advanced mining
- Surface/regolith resources always accessible with basic equipment
- PSR deposits require ice mining operation
- Clathrates, sedimentary, deep subsurface require advanced equipment
  and discovered deposit location
- Equipment tier gates what the player can access regardless of
  what exists in the data

### No hardcoding for generated worlds
- AI Manager must work from body properties alone
- Cannot assume Sol system structure
- Must handle any combination of atmosphere, temperature, geology

---

## Implementation Steps

### Step 1 — Design deposit schema
Define what a spawned deposit record looks like:
- Body reference
- Deposit type (surface, psr, subsurface, atmospheric)
- Resource compound
- Amount (with variance — no deposit is exactly the scientific mean)
- Location (coordinates or region)
- Discovered flag
- Equipment tier required
- Spawned by (AI Manager version/seed)

### Step 2 — Train AI Manager on placement rules
Document placement rules derived from Civ4/FreeCiv patterns adapted
for realistic planetary science:
- PSR deposits → permanently shadowed craters only
- Clathrate deposits → cold subsurface regions
- Ore deposits → geologically active or ancient volcanic regions
- Regolith → everywhere on airless bodies
- Atmospheric skimming → bodies with sufficient atmospheric pressure

### Step 3 — Implement ResourceSpawnerService
New service under `app/services/ai_manager/resource_spawner_service.rb`:
- Takes a celestial body as input
- Reads body properties
- Applies placement rules
- Creates deposit records with variance
- Marks confirmed known deposits as pre-discovered

### Step 4 — Trigger points
Define when spawning occurs:
- First survey of a region
- Settlement planning initiated
- Mission profile generated for a body
- Admin/debug: full system spawn for testing

### Step 5 — Integration with PrecursorCapabilityService
- `can_produce_locally?` checks spawned deposits for body
- `local_resources` returns discovered deposits not just data totals
- Undiscovered deposits not returned until surveyed

---

## Acceptance Criteria
- [ ] Deposit schema defined and migrated
- [ ] ResourceSpawnerService generates plausible deposits for Luna
- [ ] ResourceSpawnerService works for a generated world with no JSON data
- [ ] PrecursorCapabilityService reads spawned deposits
- [ ] Survey trigger spawns deposits for unsurveyed regions
- [ ] Confirmed known deposits (Shackleton PSR ice) pre-marked as discovered
- [ ] No hardcoded world identifiers in spawner logic

---

## Dependencies
**Blocked by**: Luna MVP completion (Phase 1-2)
**Blocks**: Generated world gameplay, exploration loop
**Related tasks**:
- CELESTIAL_BODY_DATA_CONVENTIONS.md (Phase 1 data integrity work)
- AI Manager mission planner (Phase 3)
- TaskExecutionEngineV2 (Phase 1 Task 2)

---

## Notes from Session 2026-05-01
- CH4 clathrates remain in Luna stored_volatiles as confirmed science
- CO2 sedimentary_rocks remain in Luna stored_volatiles same reason
- These are total amount estimates not deposit locations
- AI Manager will spawn actual clathrate deposit locations procedurally
- Only confirmed data (PSR ice, He3 regolith) is pre-discovered
- Generated worlds need full procedural treatment — no JSON fallback

---

## Completion Report
*Filled in by implementing agent after completion*

**Completed by**:
**Completion date**:
**Final test result**:

### What was changed
### Issues discovered
### Follow-up tasks needed
### Lessons learned