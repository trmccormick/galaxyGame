# TASK: WormholeExpansionService — Add arrives_at to Logistics::Contract Creation
**Status**: BACKLOG
**Priority**: HIGH
**Type**: bug-fix
**Created**: 2026-04-23
**Last Updated**: 2026-04-23

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Single service file, two call sites, fully specified fix.
**Supervision Level**: 🔴 Watched carefully

---

## Context

Task 4b added `arrives_at` as a required field on `Logistics::Contract` with a
presence validation. `WormholeExpansionService` creates `Logistics::Contract`
records directly at lines ~34 and ~50 without setting `arrives_at` — causing
validation failures.

---

## Problem Statement

**Error:**
```
ActiveRecord::RecordInvalid: Validation failed: Arrives at can't be blank
```

At:
- `wormhole_expansion_service.rb:34` — `create_gate_construction_contract`
- `wormhole_expansion_service.rb:50` — `create_rescue_contract`

**Root cause**: Both methods create `Logistics::Contract` without `arrives_at`.

---

## Files Involved

### Primary — edit only this file
`galaxy_game/app/services/wormhole_expansion_service.rb`

### Do Not Touch
- Spec file — specs are correct, service is wrong

---

## Implementation Steps

### Step 1 — Read the service file around both call sites
```bash
sed -n '25,60p' galaxy_game/app/services/wormhole_expansion_service.rb
```
Paste output in Synthesis Report.

### Step 2 — Add arrives_at to both Logistics::Contract.create! calls

For `create_gate_construction_contract` (line ~34):
```ruby
Logistics::Contract.create!(
  ...existing attributes...,
  arrives_at: 3.days.from_now  # Gate construction transit estimate
)
```

For `create_rescue_contract` (line ~50):
```ruby
Logistics::Contract.create!(
  ...existing attributes...,
  arrives_at: 3.days.from_now   # Rescue mission transit estimate
)
```

⚠️ Use reasonable transit times that fit the context:
- Gate construction — long lead time, 30 days is reasonable
- Rescue contract — urgent, 7 days or less

If the service has a way to calculate transit time — use it.
If not — use the constants above as defaults.

### Step 3 — Verify fix
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test \
  bundle exec rspec spec/services/wormhole_expansion_service_spec.rb \
  2>&1 | tail -10'
```
Expected: 0 failures.

---

## Status Update (2026-05-28)
- **arrives_at is now present at both Logistics::Contract.create! call sites in wormhole_expansion_service.rb.**
- **Transit times are set to 3.days.from_now for both gate construction and rescue contracts.**
- The original task requested 30 days for gate construction and 7 days for rescue; these values are not used in the current code.
- The core bug (missing arrives_at) is fixed. Only the timing values differ from the original intent.
- No further action required unless the 30/7 day values are still desired.

---

## Synthesis Report Format
```
CALL SITE 1 — create_gate_construction_contract line ~34:
[paste the Logistics::Contract.create! block]
arrives_at present: YES/NO

CALL SITE 2 — create_rescue_contract line ~50:
[paste the Logistics::Contract.create! block]
arrives_at present: YES/NO

PROPOSED FIX:
Line [N] — add arrives_at: [value]
Line [N] — add arrives_at: [value]

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test \
  bundle exec rspec spec/services/wormhole_expansion_service_spec.rb \
  2>&1 | tail -5'
```
Expected: `5 examples, 0 failures`

---

## Acceptance Criteria
- [ ] Both `Logistics::Contract.create!` calls include `arrives_at`
- [ ] Wormhole expansion service spec: 0 failures
- [ ] No regressions

---

## Stop Conditions
- Service has a transit time calculation method — use it, don't hardcode
- Any new failures introduced — stop immediately

---

## Commit Instructions
```bash
git add galaxy_game/app/services/wormhole_expansion_service.rb
git commit -m "fix: wormhole_expansion_service — add arrives_at to Logistics::Contract creation"
```

---

## Dependencies
**Blocked by**: Nothing — independent fix
**Parallel safe**: Yes — does not overlap with other active tasks
**Note**: Same root cause as logistics factory fix — Task 4b validation
added arrives_at requirement but not all call sites were updated.
