# TASK: Phase 1 — Data-Driven Orbital Altitude (depot_adapter + extraction_service)
**Status**: ACTIVE
**Priority**: MEDIUM
**Type**: refactor
**Created**: 2026-04-12
**Last Updated**: 2026-04-12

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Fully specified, two files, explicit before/after code
provided. No inference required.
**Supervision Level**: 🔴 Watched carefully

---

## Context

The Sol world names audit (2026-04-10) identified ~12 Type B behavior
branches across the codebase that hardcode Sol world names to determine
runtime behavior. This task addresses Phase 1 only — the two
highest-impact, lowest-risk fixes plus the data file updates that
enable them.

Phase 1 scope:
1. `depot_adapter.rb#calculate_orbital_altitude` — replace 3-world
   case statement with data lookup
2. `extraction_service.rb` line 5 — replace name check with atmosphere
   composition check
3. Add `standard_orbital_altitude_km` to Sol world operational data
   files

Phases 2-4 are separate tasks. Do not touch anything outside this scope.

---

## Problem Statement

**Current behavior**:
```ruby
# depot_adapter.rb
def self.calculate_orbital_altitude(world)
  case world.class.name
  when /Mars/  then 20_000_000.0
  when /Venus/ then 15_000_000.0
  when /Titan/ then 5_000_000.0
  else              10_000_000.0
  end
end

# extraction_service.rb
return false unless settlement.location&.celestial_body&.name == 'Mars'
```

**Expected behavior**:
```ruby
# depot_adapter.rb
def self.calculate_orbital_altitude(world)
  km = world.operational_data&.dig('standard_orbital_altitude_km')
  return km * 1000.0 if km.present?
  10_000_000.0 # 10,000 km default
end

# extraction_service.rb
body = settlement.location&.celestial_body
return false unless body&.atmosphere_composition&.dig('Ar').to_f > 0.01
```

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Change |
|---|---|---|
| `app/services/ai_manager/depot_adapter.rb` | Depot creation | Replace calculate_orbital_altitude |
| `app/services/extraction_service.rb` | Argon extraction gate | Replace name check |
| Sol world operational data JSON files | Body attributes | Add orbital altitude field |

### Finding the data files
```bash
find app/data -name "*.json" | xargs grep -l "Mars\|Venus\|Titan\|Luna\|Europa" | head -20
find app/data -name "mars*" -o -name "venus*" -o -name "titan*" -o -name "luna*" 2>/dev/null
```

Run these to locate the correct operational data files for each body.
The files will be in `app/data/json-data/` or similar. Do not guess paths.

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/models/celestial_bodies/celestial_body.rb` | Confirm `operational_data` and `atmosphere_composition` method signatures |
| `db/schema.rb` | Confirm celestial_bodies table has operational_data jsonb |

---

## Implementation Steps

> Follow exactly in order. Do not skip steps.

### Step 1 — Read current files
```bash
cat app/services/ai_manager/depot_adapter.rb
cat app/services/extraction_service.rb
grep -n "atmosphere_composition\|operational_data" \
  app/models/celestial_bodies/celestial_body.rb | head -20
```

### Step 2 — Locate and read Sol world data files
Run the find commands above. Read the operational_data structure for
Mars, Venus, Titan, Luna, and Europa to confirm where to add the
new field.

### Step 3 — Validate JSON before and after any edit
Before editing any JSON file, validate it:
```bash
python3 -c "import json; json.load(open('path/to/file.json'))"
```
Run again after editing. A single bad comma breaks the file silently.

### Step 4 — Add standard_orbital_altitude_km to data files
Add to each Sol world's operational data JSON:
```json
"standard_orbital_altitude_km": VALUE
```

Use these values (derived from real orbital mechanics):
| Body | Value (km) | Notes |
|---|---|---|
| Mars | 20000 | Mars L1 / high orbit |
| Venus | 15000 | High circular orbit above atmosphere |
| Titan | 5000 | Low orbital insertion |
| Luna | 1800 | Low lunar orbit |
| Europa | 500 | Low orbital insertion |

For any body not listed: do not add the field. The default fallback
(10,000 km) will apply.

### Step 5 — Update depot_adapter.rb
Replace `calculate_orbital_altitude` with:
```ruby
def self.calculate_orbital_altitude(world)
  km = world.operational_data&.dig('standard_orbital_altitude_km')
  return km.to_f * 1000.0 if km.present?
  10_000_000.0 # default 10,000 km
end
```

### Step 6 — Update extraction_service.rb
Read the full file first. Find line 5. Replace:
```ruby
# Before
return false unless settlement.location&.celestial_body&.name == 'Mars'

# After
body = settlement.location&.celestial_body
return false unless body&.atmosphere_composition&.dig('Ar').to_f > 0.01
```

Note: 0.01 = 1% argon threshold. Mars atmosphere is ~1.9% Ar.
This correctly identifies Mars-like bodies with extractable argon
without hardcoding the name.

### Step 7 — Run related specs
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/'
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/extraction_service_spec.rb'
```

### Step 8 — Run models suite to check for regressions
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/ > /home/galaxy_game/log/rspec_models_$(date +%s).log 2>&1'
```
Report final summary line only.

---

## Synthesis Report Format

Before touching any file, produce this and STOP:

```
FILES FOUND
Depot adapter: [path confirmed]
Extraction service: [path confirmed]
Data files found: [list paths for Mars, Venus, Titan, Luna, Europa]
atmosphere_composition method: [confirmed exists / not found]
operational_data on CelestialBody: [confirmed jsonb / other]

PROPOSED CHANGES
depot_adapter.rb: [confirm before/after matches spec above]
extraction_service.rb: [confirm before/after — note exact line number]
Data files: [list each file and the value being added]

RISK
Any shared code affected beyond these 3 targets: [yes/no]
JSON validation: [will run before and after each edit]

READY TO APPLY? — waiting for approval
```

---

## Acceptance Criteria
- [ ] `calculate_orbital_altitude` contains no world name references
- [ ] `extraction_service.rb` contains no world name string check
- [ ] All 5 Sol world data files validated before and after edit
- [ ] All AI manager specs pass
- [ ] No regressions in models suite

## Stop Conditions — escalate immediately if:
- `atmosphere_composition` method does not exist on `CelestialBody`
- `operational_data` is not a jsonb column on `celestial_bodies`
- Sol world data files not found at expected paths
- JSON validation fails after edit — revert immediately, do not proceed
- `extraction_service_spec.rb` does not exist — flag, do not create it

---

## Commit Instructions
```bash
git add app/services/ai_manager/depot_adapter.rb
git add app/services/extraction_service.rb
git add [each data file individually — never git add .]
git commit -m "refactor: replace hardcoded Sol world names with data-driven orbital altitude and atmosphere checks — Phase 1"
git push
```

---

## Dependencies
**Blocked by**: nothing — independent of OrbitalSettlement decoupling task
**Blocks**: Phase 2 Sol world names refactor
**Related tasks**:
- `2026-04-10-MEDIUM-REFACTOR-HARDCODED-SOL-WORLD-NAMES-DATA-DRIVEN.md`
- `2026-04-12-HIGH-ARCHITECTURE-ORBITAL-SETTLEMENT-DECOUPLE-FROM-BASE.md`

---

## Completion Report
*Filled in by implementing agent after completion*

**Completed by**:
**Completion date**:
**Final test result**: X examples, Y failures

### What was changed
### Issues discovered
### Follow-up tasks needed
### Lessons learned
