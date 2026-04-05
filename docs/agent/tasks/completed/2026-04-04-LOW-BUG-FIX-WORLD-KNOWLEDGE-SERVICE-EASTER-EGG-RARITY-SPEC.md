# TASK: Fix WorldKnowledgeService Easter Egg Rarity — Non-Deterministic Spec
**Status**: BACKLOG
**Priority**: LOW
**Type**: bug-fix
**Created**: 2026-04-04
**Last Updated**: 2026-04-04

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x
**Why This Agent**: Isolated single-spec fix, fully specified, no inference needed.
**Supervision Level**: 🔴 Watched carefully

---

## Context

`WorldKnowledgeService#generate_system_easter_egg` reads easter egg JSON files
from `app/data/easter_eggs/` and matches them against trigger conditions including
a `rarity` float value. The matching logic applies a probability roll against
rarity, which means low-rarity easter eggs will only match ~N% of the time.

`b_joran_system.json` (the DS9 wormhole easter egg) has `rarity: 0.005` — a
0.5% match chance. The spec testing wormhole behavior calls
`generate_system_easter_egg(has_wormhole: true)` and expects a Hash back, but
the rarity roll fails 99.5% of the time, returning nil.

The rarity mechanic is **correct game behavior** — do not change the service or
the JSON. The spec needs to control randomness so it tests the matching logic,
not the probability roll.

There are two wormhole easter eggs in the data:
- `b_joran_system.json` — rarity: 0.005
- `sovereign_class_debris.json` — rarity: 0.07

Both will fail the rarity roll most of the time in test context.

---

## Problem Statement

**Error output:**
```
Failure/Error: expect(result).to be_a(Hash)
  expected nil to be a kind of Hash
# ./spec/services/ai_manager/world_knowledge_service_spec.rb:11
```

**Current behavior**: `generate_system_easter_egg(true)` returns nil because the
rarity roll rejects the match.

**Expected behavior**: When `has_wormhole` is true and a matching easter egg
exists in the data, the method returns a Hash with easter egg data.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose |
|---|---|
| `spec/services/ai_manager/world_knowledge_service_spec.rb` | Fix the spec to stub rarity roll |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/services/ai_manager/world_knowledge_service.rb` | Find the exact rarity check — line ~928 `find_matching_easter_egg` |
| `data/json-data/easter_eggs/b_joran_system.json` | Wormhole easter egg being tested |

---

## Implementation Steps

### Step 1 — Find the rarity check
```bash
grep -n "rarity\|rand" galaxy_game/app/services/ai_manager/world_knowledge_service.rb
```

Identify the exact line where `rand` is called against the rarity value.
It will look something like: `rand < triggers['rarity']` or similar.

### Step 2 — Confirm the spec context
```bash
cat galaxy_game/spec/services/ai_manager/world_knowledge_service_spec.rb
```

Understand the full spec structure before editing.

### Step 3 — Produce Synthesis Report and STOP

### Step 4 — Add rarity stub to the failing example

In the spec, before calling `generate_system_easter_egg`, stub the random
check so the rarity roll always passes:

```ruby
# If the rarity check uses rand directly:
allow(service).to receive(:rand).and_return(0.001)

# Or if it uses Kernel.rand:
allow(Kernel).to receive(:rand).and_return(0.001)
```

The stub value `0.001` is below all rarity values in the data (lowest is 0.003),
so any easter egg will match.

Do NOT stub at the class level or in a before(:all) — scope it to the specific
example only to avoid affecting other tests.

### Step 5 — Verify
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/world_knowledge_service_spec.rb 2>&1 | grep "examples,"'
```

Expected: `4 examples, 0 failures`

---

## Synthesis Report Format

```
THE FAILURE
Spec: world_knowledge_service_spec.rb:9
Error: expected nil to be a kind of Hash
Cause: rarity roll (rand < 0.005) fails 99.5% of the time in test context

RARITY CHECK LOCATION
File: world_knowledge_service.rb line [N]
Code: [exact line]

PROPOSED FIX
Add to failing example: [exact stub line]
Scope: example-level only, not shared context

RISK
None — rarity is only relevant to probability in production.
Stubbing rand in this spec does not affect other specs.

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence

1. Isolation: `spec/services/ai_manager/world_knowledge_service_spec.rb`
2. Full ai_manager suite to confirm no regressions:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/ 2>&1 | grep "examples,"'
```

---

## Acceptance Criteria
- [ ] `world_knowledge_service_spec.rb` — 4 examples, 0 failures
- [ ] No regressions in ai_manager suite
- [ ] Service code unchanged
- [ ] JSON data unchanged
- [ ] Rarity stub scoped to failing example only

---

## Stop Conditions — escalate immediately if:
- The rarity check is not a simple `rand` call — report the actual mechanism
- Stubbing `rand` causes failures in other examples in the same file
- The method uses a custom probability service — report before proceeding

---

## Commit Instructions
```bash
git add galaxy_game/spec/services/ai_manager/world_knowledge_service_spec.rb
git commit -m "fix: world_knowledge_service_spec — stub rarity roll for deterministic wormhole easter egg test"
git push
```

---

## Dependencies
**Blocked by**: none
**Blocks**: nothing
**Related tasks**: none

---

## Completion Report
*Filled in by implementing agent after completion*

**Completed by**:
**Completion date**:
**Final test result**:

### What was changed
### Issues discovered
### Follow-up tasks needed
