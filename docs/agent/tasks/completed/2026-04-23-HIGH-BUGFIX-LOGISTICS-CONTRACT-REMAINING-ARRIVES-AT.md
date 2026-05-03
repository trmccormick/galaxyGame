# TASK: Add arrives_at to Remaining Logistics::Contract Call Sites
**Status**: BACKLOG
**Priority**: HIGH
**Type**: bug-fix
**Created**: 2026-04-23
**Last Updated**: 2026-04-23

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Two files, one call site each, fully specified fix.
**Supervision Level**: 🔴 Watched carefully

---

## Context

Task 4b added `arrives_at` as a required field on `Logistics::Contract`.
A grep confirmed 10 total `Logistics::Contract.create!` call sites across 6 files.
This task covers the two remaining files not yet fixed:

- `safety_net_logistics_job.rb` — line 35
- `ai_manager/decision_tree.rb` — line 366

The other 4 files are handled in separate tasks.

---

## Files Involved

### Primary — edit only these
| File | Line |
|---|---|
| `galaxy_game/app/jobs/safety_net_logistics_job.rb` | ~35 |
| `galaxy_game/app/services/ai_manager/decision_tree.rb` | ~366 |

---

## Implementation Steps

### Step 1 — Read both call sites in context
```bash
sed -n '25,50p' galaxy_game/app/jobs/safety_net_logistics_job.rb
sed -n '356,380p' galaxy_game/app/services/ai_manager/decision_tree.rb
```
Paste both in Synthesis Report.

### Step 2 — Determine appropriate arrives_at for each

**safety_net_logistics_job.rb** — this is a safety net / emergency logistics job.
Use a short transit time: `arrives_at: 24.hours.from_now`

**ai_manager/decision_tree.rb** — AI Manager is making a logistics decision.
Check if the surrounding code has a transit time calculation. If yes — use it.
If no — use `arrives_at: 3.days.from_now` as a reasonable default.

### Step 3 — Add arrives_at to each call site

```ruby
# Add to each Logistics::Contract.create! block
arrives_at: [appropriate_value]
```

### Step 4 — Verify no spec failures introduced
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test \
  bundle exec rspec spec/jobs/ spec/services/ai_manager/ \
  2>&1 | tail -10'
```

---

## Synthesis Report Format
```
safety_net_logistics_job.rb line 35:
[paste the create! block]
Context: [what kind of logistics is this?]
Proposed arrives_at: [value and reasoning]

ai_manager/decision_tree.rb line 366:
[paste the create! block]
Context: [what kind of logistics decision?]
Transit calculation present: YES/NO
Proposed arrives_at: [value and reasoning]

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test \
  bundle exec rspec spec/jobs/ \
  2>&1 | tail -5'

docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test \
  bundle exec rspec spec/services/ai_manager/ \
  2>&1 | tail -5'
```

---

## Acceptance Criteria
- [ ] Both call sites include `arrives_at`
- [ ] No new spec failures
- [ ] No regressions

---

## Stop Conditions
- Call site context suggests a specific transit time calculation exists — use it
- Any new failures — stop immediately

---

## Commit Instructions
```bash
git add galaxy_game/app/jobs/safety_net_logistics_job.rb \
        galaxy_game/app/services/ai_manager/decision_tree.rb
git commit -m "fix: add arrives_at to Logistics::Contract creation in safety_net_logistics_job and decision_tree"
```

---

## Dependencies
**Blocked by**: Nothing
**Parallel safe**: Yes
**Related**: wormhole_expansion_service fix (same root cause)
