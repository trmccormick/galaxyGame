# TASK: AI Manager Resource Spawning System
**Status**: COMPLETED - DECOMPOSED
**Priority**: MEDIUM
**Type**: architecture
**Created**: 2026-05-01
**Decomposed**: 2026-05-18
**Last Updated**: 2026-05-18

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

---

## COMPLETION NOTES (2026-05-18)

This monolithic skeleton task has been **decomposed into 7 focused work items** in the new_agent workflow:

**Design Investigation Tasks** (require collaborative refinement):
- 2026-05-18-DESIGN-Resource-Deposit-Model-And-Persistence.md
- 2026-05-18-DESIGN-Deposit-Plausibility-Engine.md
- 2026-05-18-DESIGN-Deposit-Trigger-System-And-Equipment-Gating.md

**Implementation-Ready Tasks** (blocked until design approval):
- 2026-05-18-IMPL-Create-ResourceDeposit-Model.md
- 2026-05-18-IMPL-Create-DepositSpawner-Service.md
- 2026-05-18-IMPL-Integrate-Spawning-With-Game-Events.md

**Overview & Tracking**:
- 2026-05-18-OVERVIEW-Resource-Spawning-Task-Breakdown.md

Location: `docs/new_agent/tasks/backlog/2026-05/`

Each task includes specific acceptance criteria, design questions, dependencies, and implementation steps. This decomposition allows for collaborative design refinement before implementation begins.
