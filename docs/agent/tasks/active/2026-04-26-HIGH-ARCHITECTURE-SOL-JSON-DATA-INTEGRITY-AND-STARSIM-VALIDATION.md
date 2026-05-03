# TASK: Sol.json Data Integrity Audit and StarSim Validation Layer
**Status**: PARTIALLY COMPLETE — data audit done, StarSim validation layer pending
**Priority**: HIGH
**Type**: architecture
**Created**: 2026-04-26
**Last Updated**: 2026-05-02

### Completed (2026-05-02, commit 05c668fc + session work)
- ✅ sol.json and sol-complete.json cross-sphere contamination removed
- ✅ H2O.oceans removed from Luna (physically impossible)
- ✅ H2O.groundwater removed from Luna (unconfirmed, wrong sphere)
- ✅ N2.atmosphere removed from Luna (belongs in atmosphere sphere)
- ✅ H2O.ice_caps → H2O.psr_deposits (standard key established)
- ✅ H2O.polar_craters → H2O.psr_deposits on Mercury
- ✅ Inline lava tube data removed from both files (exists in geological features)
- ✅ CELESTIAL_BODY_DATA_CONVENTIONS.md created as reference document
- ✅ Both files validated clean against sphere separation rules

### Remaining
- ❌ StarSim validation layer — SystemBuilderService still loads JSON with no schema checks
- ❌ Physical plausibility guards not yet implemented
- Promote this remaining work to active after Phase 1 gate (Task 4) completes

---

## Agent Assignment

**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Requires cross-file reasoning, physical plausibility judgment,
and architectural awareness of the sphere model separation. Too much inference
required for a 0x agent.
**Supervision Level**: 🔴 Watched carefully for any JSON data edits or service changes

---

## Context

During test setup work on 2026-04-26, GPT-4.1 audited sol.json and found
significant data quality issues introduced by a previous agent. The game uses
a modular sphere architecture — atmosphere, hydrosphere, geosphere, biosphere
are separate models each tracking their own data. The `stored_volatiles` field
on the geosphere should only contain volatiles physically accessible in the
crust/subsurface — not atmospheric or hydrospheric data which is tracked
elsewhere.

Additionally, geological features (lava tubes, craters) are sometimes embedded
inline in celestial body JSON definitions when they should reference separate
feature files per the established modular pattern.

**Relevant files:**
- `docs/agent/TEST_ENVIRONMENT_SETUP.md` — world constants architecture
- `app/models/celestial_bodies/spheres/geosphere.rb` — geosphere model
- `app/models/concerns/geosphere_concern.rb` — geosphere concern
- `app/services/star_sim/system_builder_service.rb` — data loader

---

## Problem Statement

**Current behavior**: `sol.json` contains data that:
1. Mixes sphere-specific data across sphere boundaries
2. Contains physically impossible volatile reservoirs for some bodies
3. Embeds geological features inline instead of referencing separate files
4. Is loaded blindly by `SystemBuilderService` with no validation

**Specific confirmed issues found 2026-04-26:**

Luna's `stored_volatiles` in sol.json contains:
```json
"stored_volatiles": {
  "H2O": {
    "oceans": 1.35e+21,      ← impossible, Luna has no oceans
    "ice_caps": 2.7e+19,     ← plausible, polar ice
    "groundwater": 2.3e+19   ← tracked in hydrosphere, not geosphere
  },
  "CO2": {"sedimentary_rocks": 1.0e+20},  ← plausible
  "CH4": {"clathrates": 1.0e+18},          ← plausible
  "N2": {"atmosphere": 3.9e+18},           ← wrong sphere, belongs in atmosphere
  "He3": {"regolith": 1000000.0}           ← correct
}
```

The `geosphere.stored_volatiles` field should ONLY contain volatiles that are
physically in the ground — polar ice deposits, regolith-trapped volatiles,
subsurface clathrates. Atmospheric volatiles belong in `atmosphere.composition`,
liquid/ice bodies belong in `hydrosphere`.

**Expected behavior**: Each sphere's data is cleanly separated. `stored_volatiles`
contains only geosphere-accessible volatiles. `MaterialProcessingService` can
read geosphere volatiles and calculate extraction amounts correctly.

---

## Files Involved

### Primary Files — audit and edit
| File | Known Issue |
|---|---|
| `data/json-data/star_systems/sol.json` | Luna stored_volatiles cross-sphere contamination confirmed. Other bodies need audit. |
| `app/services/star_sim/system_builder_service.rb` | No validation of incoming data — blindly writes whatever is in JSON |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/models/celestial_bodies/spheres/geosphere.rb` | Understand stored_volatiles field definition |
| `app/models/celestial_bodies/spheres/atmosphere.rb` | Understand what atmosphere tracks |
| `app/models/celestial_bodies/spheres/hydrosphere.rb` | Understand what hydrosphere tracks |
| `app/models/concerns/geosphere_concern.rb` | Understand how stored_volatiles is used |
| `app/services/manufacturing/material_processing_service.rb` | Understand how stored_volatiles is consumed |
| `data/json-data/star_systems/sol-complete.json` | Reference for correct data structure |

### Geological Features Pattern
| File | Why You Need It |
|---|---|
| `data/json-data/geological_features/luna/lava_tubes.json` | Correct modular pattern for features |
| `data/json-data/geological_features/luna/craters.json` | Correct modular pattern for features |

---

## Implementation Steps

> Claude 1x: use judgment throughout. Flag anything uncertain before editing.
> Do NOT edit any file until the audit report is approved.

### Step 1 — Audit all Sol bodies in sol.json for sphere data contamination

For each body, classify its `stored_volatiles` entries as:
- **CORRECT**: physically in the ground (regolith, subsurface ice, clathrates,
  polar craters)
- **WRONG SPHERE — ATMOSPHERE**: belongs in atmosphere.composition
- **WRONG SPHERE — HYDROSPHERE**: belongs in hydrosphere (liquid bodies,
  ice caps tracked as water bodies)
- **PHYSICALLY IMPOSSIBLE**: cannot exist on this body

Also check:
- Are geological features embedded inline or referenced separately?
- Does any body have data that belongs in a different sphere model?

### Step 2 — Produce Audit Report and STOP

```
SOL.JSON DATA INTEGRITY AUDIT REPORT — 2026-04-26

LUNA stored_volatiles:
| Entry | Value | Classification | Correct Location |
|---|---|---|---|
| H2O.oceans | 1.35e+21 | PHYSICALLY IMPOSSIBLE | N/A |
| H2O.ice_caps | 2.7e+19 | CORRECT | geosphere |
| H2O.groundwater | 2.3e+19 | WRONG SPHERE | hydrosphere |
| N2.atmosphere | 3.9e+18 | WRONG SPHERE | atmosphere |
| He3.regolith | 1000000.0 | CORRECT | geosphere |
[repeat for each body]

GEOLOGICAL FEATURES:
| Body | Feature Type | Location | Status |
|---|---|---|---|
| Luna | lava_tubes | inline in sol.json | SHOULD BE SEPARATE FILE |
[repeat for each body]

STARSIM VALIDATION GAPS:
[list specific cases where the service should reject or warn about data]

RECOMMENDED FIXES (in priority order):
1. [specific change — file, line, before, after]
2. [specific change]

ESTIMATED SCOPE:
Bodies needing correction: N
Files to edit: N
Risk level: MEDIUM — changes affect test DB seeding
```

Do not edit any file until the report is approved.

### Step 3 — Fix sol.json stored_volatiles for each affected body

For each body with contaminated stored_volatiles:
- Remove entries that belong to atmosphere or hydrosphere
- Remove physically impossible entries
- Keep only ground-accessible volatiles

Luna corrected stored_volatiles should be approximately:
```json
"stored_volatiles": {
  "H2O": {
    "polar_craters": 2.7e+19
  },
  "He3": {
    "regolith": 1000000.0
  }
}
```

### Step 4 — Fix geological features (if inline)

If features are embedded inline, extract them to reference the separate
feature files per the established pattern. Do not create new feature files
during this task — flag if separate files don't exist.

### Step 5 — Add basic validation to SystemBuilderService

Add a `validate_geosphere_data` method that warns (does not raise) when:
- `stored_volatiles` contains keys matching known atmosphere gases for a
  vacuum body
- `stored_volatiles` contains `oceans` or `groundwater` for bodies with
  no hydrosphere
- Any sphere attribute appears to be in the wrong sphere

Log warnings with `puts "[WARNING]: ..."` when `@debug_mode` is true.
Do not add hard failures — data integrity is the responsibility of the
JSON files, not the service.

### Step 6 — Re-seed test DB and verify

After sol.json corrections:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rails db:drop db:create db:schema:load'
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/material_processing_service_spec.rb 2>&1 | tail -5'
```

Expected: MaterialProcessingService specs reflect correct volatile data.

---

## Acceptance Criteria
- [ ] All Sol bodies audited — cross-sphere contamination documented
- [ ] Luna stored_volatiles corrected — only geosphere-accessible volatiles
- [ ] Other affected bodies corrected
- [ ] Geological features follow modular pattern or gaps flagged
- [ ] SystemBuilderService logs warnings for obvious data issues
- [ ] Test DB re-seeded and MaterialProcessingService specs pass
- [ ] No regressions in other specs

---

## Stop Conditions — escalate to human immediately if:
- A body's correct volatile data is genuinely unknown — use "unknown" placeholder
- Fixing one body's data causes unexpected failures in other specs
- The geological features separate file pattern doesn't exist for a body
- More than 8 bodies need significant correction — scope has grown

---

## Commit Instructions

Run git commands on **host**, not inside container:
```bash
git add data/json-data/star_systems/sol.json
git commit -m "fix: sol.json — remove cross-sphere volatile contamination, keep only geosphere-accessible volatiles"

git add app/services/star_sim/system_builder_service.rb
git commit -m "feat: system_builder_service — add debug validation warnings for cross-sphere data"
```

---

## Background — What Was Found 2026-04-26

During test setup debugging, Luna's geosphere `stored_volatiles` was found to
contain `oceans: 1.35e+21` — physically impossible for the Moon — along with
`N2: {atmosphere: 3.9e+18}` which belongs in the atmosphere model, not
geosphere. This data was introduced by a previous agent that updated sol.json
without following the sphere separation architecture.

The `MaterialProcessingService` reads `geosphere.stored_volatiles` to
calculate volatile extraction amounts. Contaminated data in this field
produces incorrect extraction calculations.

---

## Documentation
- [ ] Update `docs/agent/TEST_ENVIRONMENT_SETUP.md` — add note about sol.json
  data conventions and sphere separation rules
- [ ] Flag doc gap: no formal data conventions document exists for JSON
  celestial body definitions — add to backlog

---

## Dependencies
**Blocked by**: none
**Blocks**: `MaterialProcessingService` spec correctness (partial)
**Related tasks**: `TEST_ENVIRONMENT_SETUP.md` (completed 2026-04-26)

---

## Completion Report
*Filled in by the implementing agent after completion*

**Completed by**:
**Completion date**:
**Final test result**:

### What was changed

### Issues discovered

### Follow-up tasks needed

### Lessons learned
