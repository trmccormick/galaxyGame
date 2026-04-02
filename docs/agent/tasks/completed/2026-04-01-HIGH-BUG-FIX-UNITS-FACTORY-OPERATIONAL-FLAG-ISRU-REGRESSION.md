# TASK: Fix units factory operational flag — restore ISRUEvaluator count correctness
**Status**: ACTIVE
**Priority**: HIGH
**Type**: bug-fix
**Created**: 2026-04-01
**Last Updated**: 2026-04-01

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Single file fix, fully specified, no inference needed
**Supervision Level**: 🔴 Watched carefully

---

## Context
`ISRUEvaluator#inventory_isru_units` was previously fixed (commit `c6236543`)
to correctly count operational units. The fix is still in the evaluator.
However the underlying factory bug was never fixed — the factory sets
`test_operational: false` but `operational?` on `BaseUnit` checks
`operational_properties.status`, not `test_operational`. These two keys
are completely disconnected, so `operational?` ignores the factory flag
and returns `true` for all units.

This is a factory bug that affects any spec using `operational: true/false`
on the unit factory. Blast radius: 22 usages across specs, but only 3
outside ISRU specs — `base_unit_spec`, `resource_flow_simulator_spec`,
and one integration spec (do not touch).

**Do not touch:**
- `app/services/ai_manager/isru_evaluator.rb` — correct as-is
- `spec/services/ai_manager/isru_evaluator_spec.rb` — correct as-is
- Any integration spec

---

## Problem Statement
`BaseUnit#operational?` checks:
```ruby
def operational?
  return false unless operational_data.present? && operational_data.is_a?(Hash)
  status = operational_data.dig('operational_properties', 'status')
  return true if status.nil? # legacy units without status field
  status != 'offline' && status != 'disabled' && status != 'destroyed'
end
```

Factory sets:
```ruby
unit.operational_data = (unit.operational_data || {}).merge('test_operational' => false)
```

`operational_data.dig('operational_properties', 'status')` returns `nil`
for all factory-created units → legacy path → `operational?` returns `true`
for every unit regardless of the `operational:` flag passed to the factory.

**Current behavior**: `expected: 1, got: 2` — non-operational unit counted
**Expected behavior**: Only units with `operational: true` are counted

---

## Files Involved

### Primary File — you will edit
| File | Purpose | Change |
|------|---------|--------|
| `spec/factories/units/units.rb` | Unit factory | Fix after(:build) block to set `operational_properties.status` |

### Reference Files — read but do not edit
| File | Why You Need It |
|------|----------------|
| `app/models/units/base_unit.rb` | Confirms `operational?` checks `operational_properties.status` |
| `spec/services/ai_manager/isru_evaluator_spec.rb` | Confirms expected behavior |

---

## Implementation Steps

### Step 1 — Read the current factory after(:build) block
```bash
grep -n "operational\|after(:build)\|after(:create)" spec/factories/units/units.rb | head -30
```
Confirm the exact current code before touching anything.

### Step 2 — Produce Synthesis Report and STOP (see format below)

### Step 3 — Apply fix (after approval)
In `spec/factories/units/units.rb`, find the `after(:build)` block that
handles the `operational` evaluator flag. Change it from:

```ruby
if evaluator.operational == false
  unit.operational_data = (unit.operational_data || {}).merge('test_operational' => false)
elsif evaluator.operational || unit.operational_data.blank?
  unit.operational_data = (unit.operational_data || {}).merge('test_operational' => true)
end
```

To:

```ruby
if evaluator.operational == false
  unit.operational_data = (unit.operational_data || {}).merge(
    'operational_properties' => { 'status' => 'offline' }
  )
elsif evaluator.operational || unit.operational_data.blank?
  unit.operational_data = (unit.operational_data || {}).merge(
    'operational_properties' => { 'status' => 'operational' }
  )
end
```

### Step 4 — Verify the count fix in isolation
```bash
docker exec -it web bash -c "unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/isru_evaluator_spec.rb -e 'counts operational units by type' --format documentation 2>&1 | tail -20"
```
Expected: 1 example, 0 failures.

### Step 5 — Verify base_unit_spec (factory change blast radius)
```bash
docker exec -it web bash -c "unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/units/base_unit_spec.rb --format documentation 2>&1 | tail -20"
```
Report summary line. Flag any new failures immediately — do not proceed.

### Step 6 — Verify resource_flow_simulator_spec
```bash
docker exec -it web bash -c "unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/resource_flow_simulator_spec.rb --format documentation 2>&1 | tail -20"
```
Report summary line. Flag any new failures immediately — do not proceed.

### Step 7 — Run full isru_evaluator_spec — redirect to log
```bash
docker exec -it web bash -c "unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/isru_evaluator_spec.rb > /home/galaxy_game/log/isru_evaluator_$(date +%s).log 2>&1"
```
Then report:
```bash
docker exec -it web bash -c "tail -5 /home/galaxy_game/log/isru_evaluator_*.log | tail -10"
```
Report summary line only. Note runtime — expected to still be slow,
that is a separate issue.

---

## Synthesis Report Format
Produce this before applying ANY fix. STOP and wait for approval.

```
CURRENT FACTORY CODE
[paste exact current after(:build) block handling operational flag]

CONFIRMED
operational? checks: [operational_properties.status — confirmed yes/no]
factory sets: [exact key it currently sets]
Disconnect confirmed: [yes/no]

FIX
File: spec/factories/units/units.rb
Change: [exact lines to change]

BLAST RADIUS
base_unit_spec uses operational: [yes/no]
resource_flow_simulator_spec uses operational: [yes/no]

READY TO APPLY? — waiting for approval
```

---

## Docker Rules — mandatory
```bash
# Always unset DATABASE_URL
docker exec -it web bash -c "unset DATABASE_URL && RAILS_ENV=test bundle exec rspec ..."

# Never use docker-compose exec
# Git runs on HOST not inside container
```

---

## Acceptance Criteria
- [ ] Factory `after(:build)` sets `operational_properties.status` correctly
- [ ] `operational: false` → unit fails `operational?` check
- [ ] `operational: true` → unit passes `operational?` check
- [ ] `inventory_isru_units` count example: 1 example, 0 failures
- [ ] `base_unit_spec` — no new failures
- [ ] `resource_flow_simulator_spec` — no new failures
- [ ] Full `isru_evaluator_spec` run logged

---

## Stop Conditions — escalate immediately if:
- `base_unit_spec` shows new failures after factory change
- `resource_flow_simulator_spec` shows new failures after factory change
- The exact factory code doesn't match what's described above
- Any other spec unexpectedly breaks

---

## Commit Instructions
Run on HOST after confirmed 0 failures on target examples:
```bash
git add spec/factories/units/units.rb
git commit -m "fix: units factory — set operational_properties.status so operational? reads correctly (restores ISRUEvaluator count fix)"
git push
```

---

## Dependencies
**Blocked by**: none
**Blocks**: remaining isru_evaluator_spec failures (slow runtime separate issue)
**Related tasks**: original fix at commit c6236543

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
