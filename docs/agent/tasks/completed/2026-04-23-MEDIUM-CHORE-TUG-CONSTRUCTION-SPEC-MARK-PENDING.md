# TASK: Mark Tug Construction Integration Specs as Pending
**Status**: COMPLETED
**Priority**: MEDIUM
**Type**: bug-fix
**Created**: 2026-04-23
**Last Updated**: 2026-05-01 (reviewed — already done, task file not moved)

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Single file edit — mark 4 specs as xit with explanatory comments.
**Supervision Level**: 🔴 Watched carefully

---

## Context

The tug construction integration spec requires:
- `asteroid_relocation_tug_bp.json` blueprint — does not exist
- `l1_tug_construction_profile_v1.json` mission profile — does not exist
- `:station` factory trait on `base_settlement` — does not exist
- `OrbitalShipyardService.create_shipyard_project` class method — wrong signature

These are aspirational specs written ahead of implementation. Correct fix is to
park them as pending until the tug design task is complete. Do NOT attempt to
fix the underlying issues in this task.

---

## Files Involved

### Primary — edit only this file
`galaxy_game/spec/integration/tug_construction_integration_spec.rb`

---

## Implementation Steps

### Step 1 — Read the spec
```bash
cat galaxy_game/spec/integration/tug_construction_integration_spec.rb | head -20
```
Confirm the 4 failing example lines: 10, 64, 103, 141.

### Step 2 — Mark all 4 examples as xit

Change each `it '...'` to `xit '...'` and add a comment above each:

```ruby
# PENDING: Requires asteroid_relocation_tug_bp.json blueprint,
# l1_tug_construction_profile_v1.json mission profile,
# :station factory trait, and OrbitalShipyardService class method fix.
# See task: 2026-04-23-MEDIUM-ARCHITECTURE-TUG-CONSTRUCTION-DESIGN.md
xit 'successfully constructs asteroid relocation tugs from mission to deployment' do
```

Apply the same comment and `xit` to all 4 examples.

### Step 3 — Verify
```bash
grep -n "^\s*xit\|^\s*it " \
  galaxy_game/spec/integration/tug_construction_integration_spec.rb
```
All 4 examples should show as `xit`.

---

## Testing Sequence
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/integration/tug_construction_integration_spec.rb 2>&1 | tail -5'
```
Expected: `0 failures, 4 pending`

---

## Acceptance Criteria
- [ ] All 4 examples marked `xit`
- [ ] Comment references the design task file
- [ ] Spec runs with 0 failures, 4 pending
- [ ] No other files touched

---

## Stop Conditions
- Any file other than the spec is touched — stop
- Spec produces failures instead of pending — stop, report

---

## Commit Instructions
```bash
git add galaxy_game/spec/integration/tug_construction_integration_spec.rb
git commit -m "chore: mark tug_construction_integration_spec pending — awaiting blueprint, mission profile, and service design"
```

---

## Dependencies
**Blocked by**: Nothing
**Blocks**: Nothing
**Follow-up**: 2026-04-23-MEDIUM-ARCHITECTURE-TUG-CONSTRUCTION-DESIGN.md

> ⚠️ MOVE THIS FILE to `docs/agent/tasks/completed/` — work is done.
