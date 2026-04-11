# TASK: OrbitalSettlement Location — CelestialLocation on Creation + Service Layer Audit
**Status**: BACKLOG
**Priority**: MEDIUM
**Type**: architecture
**Created**: 2026-04-10
**Last Updated**: 2026-04-10

---

## Agent Assignment
**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Requires architectural reasoning about surface vs orbital
location patterns across a large service layer. Audit and recommendation
first — no code changes until approved.
**Supervision Level**: 🟡 Standard

---

## Context

`Settlement::OrbitalSettlement` inherits `has_one :location` from
`BaseSettlement` via `Location::CelestialLocation` (polymorphic). However
no code currently creates a `CelestialLocation` record when an
`OrbitalSettlement` is created — meaning `settlement.location` returns nil
for all orbital settlements.

The service layer calls `settlement.location` in ~40 locations across AI
Manager, logistics, contracts, pressurization, and resource tracking. Most
of these calls are trying to determine one of two things:

1. **Which celestial body** is this settlement associated with?
   (`settlement.location&.celestial_body`)
2. **What is the physical location** of this settlement?
   (`settlement.location` passed as a value)

For surface settlements this is a point on a body's surface. For orbital
settlements this is an orbit around a body — the settlement is associated
with a celestial body but has no single surface point.

**Key distinction confirmed this session:**
- Surface settlement — `location` = point on surface, structures are nearby
- Orbital settlement — `location` = orbit association with a celestial body,
  each `OrbitalStructure` has its own `CelestialLocation`
- Logistics routing: surface uses spaceport/landing pad, orbital uses
  per-structure docking

---

## Problem Statement

**Current behavior**: `OrbitalSettlement#location` returns nil because no
`CelestialLocation` is created on initialization. Service layer calls
that do `settlement.location&.celestial_body` silently return nil for
all orbital settlements.

**Expected behavior**: `OrbitalSettlement` has a `CelestialLocation`
created on `after_create` that associates it with the celestial body it
orbits. Service layer calls work correctly for both surface and orbital
settlements.

---

## Audit Steps — This Task Produces a Report, No Code Changes

### Step 1 — Confirm CelestialLocation schema
```bash
grep -n -A 20 "create_table \"celestial_locations\"" db/schema.rb
```
Document all columns — particularly whether orbital altitude or context
is supported.

### Step 2 — Review existing CelestialLocation creation patterns
```bash
grep -rn "CelestialLocation.create\|celestial_location.create" app/ --include="*.rb"
```
Document how other models create their location records.

### Step 3 — Audit service layer location calls
For each service file that calls `settlement.location`, classify the call:
- Type A: `settlement.location&.celestial_body` — needs body association only
- Type B: `settlement.location` passed as value — needs full location object
- Type C: `Settlement::BaseSettlement.find_by(location: x)` — finder pattern

Files to audit (from grep results):
- `app/services/ai_manager/settlement_manager.rb:74`
- `app/services/ai_manager/task_execution_engine.rb:288,308,433,613,639`
- `app/services/ai_manager/system_architect.rb:559`
- `app/services/ai_manager/production_manager.rb:6`
- `app/services/ai_manager/logistics_coordinator.rb:324,325`
- `app/services/ai_manager/resource_allocator.rb:263,264`
- `app/services/ai_manager/mission_planner_service.rb:756,759,776,802,811`
- `app/services/logistics/contract_service.rb:101,135,136,149`
- `app/services/pressurization_service.rb:34,35`
- `app/services/resource_tracking_service.rb:180,185,200,206,219,231,238`
- `app/services/wormhole_expansion_service.rb:24`
- `app/services/market/npc_price_calculator.rb:107`

### Step 4 — Check OrbitalSettlement after_create
```bash
grep -n "after_create\|after_initialize" app/models/settlement/orbital_settlement.rb
grep -n "after_create\|after_initialize" app/models/settlement/base_settlement.rb
```
Confirm what callbacks fire on OrbitalSettlement creation.

### Step 5 — Check depot_adapter location creation
```bash
grep -n "CelestialLocation" app/services/ai_manager/depot_adapter.rb
```
The depot_adapter already creates a CelestialLocation for depots — document
this pattern as the reference implementation.

---

## Completion Report Format

```
CELESTIALLOCATION SCHEMA
Columns: [list]
Supports orbital altitude: [yes/no]
Supports location context (surface vs orbital): [yes/no]

EXISTING CREATION PATTERNS
[list models that create CelestialLocation and how]

SERVICE LAYER CALL CLASSIFICATION
Type A (needs body only): [list file:line]
Type B (needs full location object): [list file:line]
Type C (finder pattern): [list file:line]

IMPACT ASSESSMENT
Calls that work correctly once location is created: [list]
Calls that need surface vs orbital distinction added: [list]
Calls that are genuinely ambiguous: [list]

RECOMMENDATION
==============
OrbitalSettlement after_create: [describe what to create]
CelestialLocation fields to set: [list]
Migration needed: [yes/no — describe]

Service layer changes needed: [NONE | MINOR | SIGNIFICANT]
If changes needed: [describe scope]

Surface vs orbital routing distinction:
  [describe where and how to add it if needed]

FOLLOW-UP TASKS NEEDED
======================
1. [Implementation task to create CelestialLocation on OrbitalSettlement]
   Scope: [single file | multi-file]
   Agent: [tier]

2. [Service layer update task if needed]
   Scope: [describe]
   Agent: [tier]
```

---

## Acceptance Criteria
- [ ] CelestialLocation schema documented
- [ ] All ~40 service layer location calls classified
- [ ] Surface vs orbital distinction impact assessed
- [ ] Recommendation produced in format above
- [ ] No code changes made

---

## Stop Conditions
- CelestialLocation schema does not support orbital context — flag before
  recommending any implementation
- More than 10 service layer calls need surface vs orbital distinction
  added — this becomes a significant refactor, flag for human decision
  before scoping implementation task

---

## Dependencies
**Blocked by**: `2026-04-10-HIGH-REFACTOR-RETIRE-SPACESTATION-ORBITALDEPOT.md`
**Blocks**: nothing directly
**Related tasks**:
- `2026-04-10-HIGH-REFACTOR-AI-MANAGER-FULL-SPACE-STATION-CLEANUP.md`
- `2026-04-10-HIGH-ARCHITECTURE-ORBITAL-MARKET-SYSTEM.md`

---

## Completion Report
*Filled in by implementing agent after completion*

**Completed by**:
**Completion date**:
**Final test result**: N/A — audit only

### What was found
### Recommendations made
### Follow-up tasks created
### Lessons learned
