# TASK: GameDataGenerator — Create missing spec fixture file
**Status**: ACTIVE
**Priority**: MEDIUM
**Type**: bug-fix
**Created**: 2026-04-18
**Last Updated**: 2026-04-18

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x
**Why This Agent**: Create one fixture file, fully specified, no inference needed
**Supervision Level**: 🔴 Watched carefully

> ⚠️ 0x agent: read every section carefully before starting.
> Do not infer file paths or method names — they are provided explicitly below.

---

## Context

`Generators::GameDataGenerator` loads a JSON template file from disk to
generate item data. The spec tests this with a fixture file at
`spec/fixtures/sample_template.json` inside the container
(`/home/galaxy_game/spec/fixtures/sample_template.json`). This file does
not exist. The spec is otherwise correctly written.

---

## Problem Statement

**Error output:**
```
RuntimeError: Template file not found: /home/galaxy_game/spec/fixtures/sample_template.json
# ./app/services/generators/game_data_generator.rb:40 in load_template
# ./app/services/generators/game_data_generator.rb:20 in generate_item
```

**Current behavior**: Spec fails immediately — fixture file missing.
**Expected behavior**: Fixture file exists, spec runs and passes.

---

## Files Involved

### Primary Files — you will create this
| File | Purpose |
|---|---|
| `galaxy_game/spec/fixtures/sample_template.json` | Fixture file for GameDataGenerator spec |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `galaxy_game/app/services/generators/game_data_generator.rb` | See what fields it expects from the template |
| `galaxy_game/spec/services/generators/game_data_generator_spec.rb` | See what the spec does with the generated item |

### Migration
- [x] No migration needed

---

## Implementation Steps

### Step 1 — Read the generator to understand template structure
```bash
cat galaxy_game/app/services/generators/game_data_generator.rb
```

### Step 2 — Read the spec to understand what it expects
```bash
cat galaxy_game/spec/services/generators/game_data_generator_spec.rb
```

### Step 3 — Check if fixtures directory exists
```bash
ls galaxy_game/spec/fixtures/ 2>/dev/null || echo "directory missing"
```
If missing, create it — the fixture file needs to live there.

### Step 4 — Create the fixture file
Based on what the generator expects, create a minimal valid
`galaxy_game/spec/fixtures/sample_template.json`. The content must
satisfy whatever fields `load_template` reads and `generate_item` uses.

### Step 5 — Validate JSON
```bash
python3 -c "import json; json.load(open('galaxy_game/spec/fixtures/sample_template.json'))"
```
Expected: no output (valid JSON).

---

## Synthesis Report Format
Before creating any file, produce a report in this format and **stop**:

```
THE FAILURE
Spec: spec/services/generators/game_data_generator_spec.rb:22
Error: Template file not found: /home/galaxy_game/spec/fixtures/sample_template.json
Expected: Fixture exists, spec runs
Got: RuntimeError on missing file

ROOT CAUSE
Fixture file was never created. Generator loads template from disk.
Spec expects fixture at spec/fixtures/sample_template.json.

PROPOSED FIX
Create spec/fixtures/sample_template.json with fields: [list fields
from reading generator source]

RISK
Low — fixture file only used by this spec.

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence

1. **Isolation run:**
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/generators/game_data_generator_spec.rb 2>&1 | grep -E "example|failure" | tail -5'
```
Expected: `1 example, 0 failures`

2. **Related specs:**
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/generators/ 2>&1 | grep -E "example|failure" | tail -5'
```

---

## Acceptance Criteria
- [ ] `game_data_generator_spec.rb` — 0 failures
- [ ] Fixture file is valid JSON
- [ ] No regressions in generators specs

---

## Stop Conditions — escalate to user immediately if:
- Generator expects fields that require real database records
- Spec expects more than one fixture file
- Fix causes new failures

---

## Commit Instructions
```bash
git add galaxy_game/spec/fixtures/sample_template.json
git commit -m "fix: game_data_generator_spec — create missing sample_template.json fixture file"
git push
```

---

## Dependencies
**Blocked by**: nothing
**Blocks**: nothing

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
