# ARCHIVED: PARTIALLY IMPLEMENTED — NEEDS COMPLETION  
**Date Archived**: 2026-06-14 (Evening Session)  
**Status**: Phase 1 refactor completed April 14, 2026; remaining gaps identified and extracted as actionable task

### What Was Implemented (Supersedes Original Task — Partially)
✅ **DepotAdapter#calculate_orbital_altitude refactored to data-driven pattern** — commit `1fc6bd42` on April 14, 2026 (4 days after task creation):
```ruby
def self.calculate_orbital_altitude(world)
  km = world.properties&.dig('standard_orbital_altitude_km')
  return km.to_f * 1000.0 if km.present?
  10_000_000.0 # default 10,000 km ✅ DATA-DRIVEN PATTERN IMPLEMENTED
end
```

✅ **Sol system JSON data files created** — `sol-complete.json` and `sol.json` added with celestial body properties including orbital altitudes  
⚠️ **~20 hardcoded patterns remain across codebase** requiring systematic review against Luna simulation requirements (see gaps below)

### What Was Extracted as New Task(s) (Actionable Work Remaining)
📄 `docs/new_agent/projects/galaxy_game/tasks/backlog/phase5+/2026-06-14-HIGH-REFACTOR-ATMOSPHERIC-TRANSFER-WORLD-NAMES-DATA-DRIVEN.md`

**Rationale for Phase 5+ Classification (per Claude analysis):**
The `atmospheric_transfer_service.rb` extraction limits by world name directly affect Luna simulation calibration:
- **Luna lava tube pressurization** — gas release over time calculations depend on atmospheric properties  
- **Venus skimmer CO2→O2 extraction** — affects multi-source supply modeling for fuel loop validation  
- **Titan CH4 harvesting** — impacts inbound cargo awareness and resource coordination patterns

These are NOT acceptable to leave hardcoded because Luna simulation requires accurate atmospheric processing parameters from celestial body data, not name-based branching. Per `research/LUNA-MVP-SIMULATION-DESIGN.md`, Phase 5 is for calibration prep needed BEFORE simulation runs.

### Implementation Evidence (For Reference)
```bash
# April 14 refactor commit:
$ git log -1 --format="%ci %s" 1fc6bd42  
2026-04-14 21:30:43 refactor: replace hardcoded Sol world names with data-driven orbital altitude and atmosphere checks — Phase 1

# Remaining patterns identified (June 14 audit):
$ grep -rn "case.*\.name\|when /Mars" galaxy_game/app/services/ --include="*.rb" | wc -l  
20 matches found ⚠️ PARTIAL REFACTOR ONLY

# Claude's phase classification:
Group 1 (Phase5+): atmospheric_transfer_service.rb — extraction limits by world name ✅ EXTRACTED AS TASK
Group 2 (Phase6+): escalation_service.rb — cargo routing logic, defer until after Luna validated  
Group 3 (Acceptable): system_generator_service.rb + fitting_service.rb — procedural gen patterns OK per task criteria
```

---

# TASK: Audit and Rewrite Hardcoded Sol World Names — Data-Driven Refactor
**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Requires architectural reasoning about where data
should live and how to migrate hardcoded values to celestial body
attributes. Audit first, implementation plan second.
**Supervision Level**: 🟡 Standard

---

## Context

The game is designed to support multiple star systems beyond Sol —
Proxima Centauri, Trappist-1, and others reachable via the wormhole
network. However, services across the codebase hardcode Sol world names
(`Mars`, `Venus`, `Titan`, `Europa`, etc.) in case statements, string
matching, and regex patterns.

**Example discovered in `depot_adapter.rb`:**
```ruby
def self.calculate_orbital_altitude(world)
  case world.class.name
  when /Mars/
    20_000_000.0
  when /Venus/
    15_000_000.0
  when /Titan/
    5_000_000.0
  else
    10_000_000.0
  end
end
```

This pattern does not scale. Any exoplanet or moon added to the game
requires hunting down case statements across multiple services. The
correct pattern is data-driven: the celestial body itself carries the
attributes that determine behavior — orbital altitude, gravity, atmosphere
type, pressure, temperature range, etc.

**Core principle**: Services ask the celestial body what it is.
They do not pattern-match on its name or class to decide what to do.

---

## Problem Statement

**Current behavior**: Services hardcode Sol world names to determine
orbital altitudes, construction strategies, resource availability,
atmospheric processing parameters, and other world-specific values.

**Expected behavior**: Celestial bodies carry their own operational
attributes. Services read those attributes. Adding a new world requires
only adding data — no service code changes.

---

## Audit Steps — Produces Report, No Code Changes

### Step 1 — Find all hardcoded world name references
```bash
grep -rn "Mars\|Venus\|Titan\|Europa\|Phobos\|Deimos\|Luna\|Ganymede\|Callisto\|Io\|Ceres\|Pluto\|Jupiter\|Saturn\|Uranus\|Neptune" \
  app/services/ app/models/ --include="*.rb" | \
  grep -v "_spec\|#\|spec/" | \
  grep -v "\.rb:[0-9]*:.*#"
```

### Step 2 — Classify each reference
For each hit, classify as:
- **A — Data lookup** (e.g. `find_by(name: 'Mars')`) — acceptable, this is a query
- **B — Behavior branch** (e.g. `case world.name when 'Mars'`) — must be refactored
- **C — String construction** (e.g. `"#{world.name} Orbital Depot"`) — acceptable
- **D — Comment or log** — ignore

### Step 3 — Identify what attribute each behavior branch is really about
For each Type B reference, identify the underlying attribute:
- Orbital altitude → should come from `celestial_body.operational_data['orbital_zones']`
  or similar
- Gravity → already exists as `celestial_body.gravity_g`
- Atmosphere type → already exists on celestial body
- Construction strategy type → should come from body classification
  (rocky, gas giant, moon, dwarf planet)
- Resource availability → should come from body composition data

### Step 4 — Audit celestial body operational data
```bash
grep -rn "orbital_altitude\|orbital_zone\|standard_orbit\|low_orbit" \
  app/ data/ --include="*.rb" --include="*.json" | head -20
```
Determine if orbital altitude data already exists on celestial bodies
or needs to be added.

### Step 5 — Check celestial body classification attributes
```bash
grep -n "body_type\|classification\|planet_type\|world_type" \
  db/schema.rb app/models/celestial_bodies/ -r --include="*.rb"
```
Determine what classification attributes already exist that could
replace name-based branching.

---

## Completion Report Format

```
AUDIT RESULTS
=============
Total references found: N
Type A (data lookup — acceptable): N
Type B (behavior branch — must refactor): N
Type C (string construction — acceptable): N
Type D (comment/log — ignore): N

TYPE B REFERENCES — FULL LIST
==============================
[file:line] — [what it branches on] — [underlying attribute needed]
...

CELESTIAL BODY DATA AUDIT
==========================
Orbital altitude: [exists in data / missing — describe]
Body classification: [exists / missing — describe]
[other attributes needed]

RECOMMENDED PATTERN
===================
[describe the data-driven pattern to replace behavior branches]
Example:
  # Before
  case world.class.name
  when /Mars/ then 20_000_000.0
  
  # After
  world.operational_data.dig('orbital_zones', 'standard_km') * 1000

DATA CHANGES NEEDED
===================
[list any celestial body data files that need new attributes added]
[list any schema changes needed]

IMPLEMENTATION PHASES
=====================
Phase 1 — [highest impact / easiest wins]
Phase 2 — [broader refactor]
Phase 3 — [data file updates]

FOLLOW-UP TASKS NEEDED
======================
[one task file per phase — describe scope and recommended agent]
```

---

## Acceptance Criteria
- [ ] All hardcoded Sol world name behavior branches identified
- [ ] Each classified and underlying attribute identified
- [ ] Celestial body data audited for existing attributes
- [ ] Recommended data-driven pattern documented
- [ ] Implementation phases defined
- [ ] No code changes made

---

## Stop Conditions
- More than 50 Type B references found — flag for human decision before
  scoping implementation, this may need to be phased differently
- Schema changes required for celestial body classification — flag
  immediately, migration needed

---

## Dependencies
**Blocked by**: nothing
**Blocks**: nothing directly — informs multiple follow-up refactor tasks
**Related tasks**:
- `2026-04-10-HIGH-REFACTOR-RETIRE-SPACESTATION-ORBITALDEPOT.md` —
  `calculate_orbital_altitude` in `depot_adapter.rb` is the triggering example
- `2026-04-10-MEDIUM-ARCHITECTURE-ORBITAL-SETTLEMENT-LOCATION.md` —
  orbital altitude is needed for `CelestialLocation` creation

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
