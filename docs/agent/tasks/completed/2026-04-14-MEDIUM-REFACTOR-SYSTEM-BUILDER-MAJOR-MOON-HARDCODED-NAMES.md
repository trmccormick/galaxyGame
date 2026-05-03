# TASK: Replace Hardcoded Major Moon Name List in SystemBuilderService
**Status**: BACKLOG
**Priority**: MEDIUM
**Type**: refactor
**Created**: 2026-04-14
**Last Updated**: 2026-04-14

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Single method, fully specified, explicit before/after provided.
**Supervision Level**: 🔴 Watched carefully

---

## Context

`StarSim::SystemBuilderService#normalize_celestial_bodies_structure` classifies
moons as `major_moons` or `moons` using a hardcoded name list. This is a Type B
hardcoded Sol world name dependency — it works for Sol but will misclassify major
moons in generated exoplanet systems where names are procedurally generated.

This was identified during the Phase 1 Sol world names refactor (2026-04-14).
The fix follows the same data-driven pattern established in that task.

---

## Problem Statement

**Current behavior**:
```ruby
if ['Luna', 'Titan', 'Ganymede', 'Callisto', 'Io', 'Europa', 'Rhea',
    'Iapetus', 'Dione', 'Tethys', 'Enceladus', 'Mimas', 'Titania',
    'Oberon', 'Umbriel', 'Ariel', 'Miranda'].include?(body[:name])
  'major_moons'
else
  'moons'
end
```

**Expected behavior**: Classification is data-driven using two criteria in
priority order:
1. Explicit `properties.major_moon: true` flag in the JSON body entry
2. Mass threshold fallback — bodies with mass > 1e20 kg are major moons
   (consistent with the existing threshold already used in
   `should_generate_terrain?`)

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method |
|---|---|---|
| `app/services/star_sim/system_builder_service.rb` | System builder | `#normalize_celestial_bodies_structure` |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/data/star_systems/sol-complete.json` | Confirm major Sol moons have mass values present |
| `app/data/star_systems/sol.json` | Same — confirm for test file |

---

## Implementation Steps

### Step 1 — Read the current method
```bash
grep -n "normalize_celestial_bodies_structure\|major_moon\|major_moons" \
  galaxy_game/app/services/star_sim/system_builder_service.rb
```

### Step 2 — Verify mass values exist for major Sol moons
```bash
docker exec -it web bash -c '
python3 << "EOF"
import json
with open("/home/galaxy_game/app/data/star_systems/sol-complete.json") as f:
    data = json.load(f)
moons = [b for b in data.get("celestial_bodies", []) if b.get("type") == "moon"]
for m in moons:
    print(m.get("name"), "mass:", m.get("mass"), "major_moon:", m.get("properties", {}).get("major_moon"))
EOF
'
```

Report output. If mass values are missing for known major moons, flag it —
do not proceed until resolved.

### Step 3 — Replace the classification logic

**Before**:
```ruby
if ['Luna', 'Titan', 'Ganymede', 'Callisto', 'Io', 'Europa', 'Rhea',
    'Iapetus', 'Dione', 'Tethys', 'Enceladus', 'Mimas', 'Titania',
    'Oberon', 'Umbriel', 'Ariel', 'Miranda'].include?(body[:name])
  'major_moons'
else
  'moons'
end
```

**After**:
```ruby
if body.dig(:properties, :major_moon) ||
   body[:mass].to_f > 1e20
  'major_moons'
else
  'moons'
end
```

### Step 4 — Add major_moon flag to Sol world data files

For each confirmed major Sol moon in `sol-complete.json` and `sol.json`,
add `"major_moon": true` to their `properties` hash using the same
targeted Python approach from the Phase 1 task. Do not re-serialize
the full file.

Known major Sol moons to flag:
Luna, Titan, Ganymede, Callisto, Io, Europa, Rhea, Iapetus, Dione,
Tethys, Enceladus, Mimas, Titania, Oberon, Umbriel, Ariel, Miranda

Only add the flag where the body is present in each file. Validate
both files after editing.

### Step 5 — Run specs
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/star_sim/ 2>&1 | tail -5'
```

If no star_sim specs exist, flag it — do not create them.

---

## Synthesis Report Format
METHOD FOUND
File: [path]
Line: [line number of the name list]
MASS VALUES
[list each major moon and whether mass is present in sol-complete.json]
PROPOSED CHANGE
[confirm before/after matches spec above]
DATA FILE UPDATES
[list each moon getting major_moon: true flag, in which files]
RISK
[any other code that references the major_moons category or the name list]
READY TO APPLY? — waiting for approval

---

## Acceptance Criteria
- [ ] No hardcoded moon name list in `normalize_celestial_bodies_structure`
- [ ] Classification uses `properties.major_moon` flag first, mass threshold fallback
- [ ] `major_moon: true` added to all known major Sol moons in both JSON files
- [ ] Both JSON files validated before and after edit
- [ ] No regressions in star_sim specs

## Stop Conditions — escalate immediately if:
- Mass values are missing for more than 3 known major moons — flag before proceeding
- Any other method in the codebase references the hardcoded name list
- JSON validation fails after edit — revert immediately

---

## Commit Instructions
```bash
git add app/services/star_sim/system_builder_service.rb
git add data/json-data/star_systems/sol-complete.json
git add data/json-data/star_systems/sol.json
git commit -m "refactor: replace hardcoded major moon name list with data-driven mass threshold and properties flag"
git push
```

---

## Dependencies
**Blocked by**: none
**Blocks**: none
**Related tasks**: `2026-04-12-MEDIUM-BUG-FIX-PHASE1-SOL-WORLD-NAMES-DATA-DRIVEN.md`

---

## Completion Report
**Completed by**:
**Completion date**:
**Final test result**:

### What was changed
### Issues discovered
### Follow-up tasks needed
### Lessons learned