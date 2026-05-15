# TASK: GameDataGenerator — Missing Fixture File
**Status**: COMPLETED
**Priority**: LOW
**Type**: bug-fix
**Created**: 2026-05-12
**Last Updated**: 2026-05-14

---

## Agent Assignment
**Assigned To**: GPT-4.1 (0x)
**Why This Agent**: Create a missing file — fully mechanical, zero inference needed
**Supervision Level**: 🔴 Watched carefully

---

## Context
`Generators::GameDataGenerator` loads a template file to generate game data.
The spec expects a fixture file at `spec/fixtures/sample_template.json` that
does not exist. Fix is to create the missing fixture — not change the generator.

---

## Problem Statement
**Error:**
```
RuntimeError: Template file not found: /home/galaxy_game/spec/fixtures/sample_template.json
Errno::ENOENT: No such file or directory @ rb_sysopen
app/services/generators/game_data_generator.rb:36
spec/services/generators/game_data_generator_spec.rb:24
```
**Current behavior**: Generator raises because fixture file missing
**Expected behavior**: Generator loads template and produces valid JSON item

---

## Files Involved

### Primary Files
| File | Purpose |
|---|---|
| `spec/fixtures/sample_template.json` | Does not exist — must be created |

### Reference Files
| File | Why |
|---|---|
| `app/services/generators/game_data_generator.rb` | Understand template format expected |
| `spec/services/generators/game_data_generator_spec.rb` | Understand what the spec expects |

---

## Implementation Steps

### Step 1 — Read the spec and generator
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && cat spec/services/generators/game_data_generator_spec.rb | head -35'
```
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && cat app/services/generators/game_data_generator.rb'
```

### Step 2 — Check if fixtures directory exists
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && ls spec/fixtures/ 2>&1'
```

### Step 3 — Produce Synthesis Report and STOP
```
SYNTHESIS REPORT
Template structure expected: [describe fields]
spec/fixtures/ directory exists: [YES/NO]
Minimum valid JSON structure: [show the JSON]
Risk: none — creating new file only
```
Wait for approval before creating anything.

### Step 4 — Create the fixture file
Create `spec/fixtures/sample_template.json` with minimum valid structure
that satisfies the generator's template loading logic.

### Step 5 — Verify
```bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/generators/game_data_generator_spec.rb:22 2>&1 | tail -10'
```
Expected: 0 failures

### Step 6 — Commit from host
```bash
git add spec/fixtures/sample_template.json
git commit -m "fix: game_data_generator_spec — add missing sample_template.json fixture"
git push
```

---

## Acceptance Criteria
- [ ] `spec/fixtures/sample_template.json` exists with valid structure
- [ ] Spec line 22 passes
- [ ] Generator code untouched

## Stop Conditions
- Template format is unclear after reading generator — stop and report
- spec/fixtures/ directory doesn't exist — create it first, then flag

## Completion Report
**Completed by**:
**Completion date**:
**Final test result**:
### What was changed
### Issues discovered
### Follow-up tasks needed
