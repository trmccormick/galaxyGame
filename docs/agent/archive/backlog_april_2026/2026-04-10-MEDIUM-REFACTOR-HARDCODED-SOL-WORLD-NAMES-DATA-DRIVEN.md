# TASK: Audit and Rewrite Hardcoded Sol World Names — Data-Driven Refactor
**Status**: BACKLOG
**Priority**: MEDIUM
**Type**: refactor
**Created**: 2026-04-10
**Last Updated**: 2026-04-10

---

## Agent Assignment
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
