# TASK: Fix strategy_selector score_mission_options sort order after readiness boost
**Status**: ACTIVE
**Priority**: HIGH
**Type**: bug-fix
**Created**: 2026-04-08
**Last Updated**: 2026-04-08

---

## Agent Assignment

**Assigned To**: GPT-4.1 0x
**Why This Agent**: Single file fix, root cause fully identified, no inference needed.
**Supervision Level**: 🔴 Watched carefully

---

## Context

`AIManager::StrategySelector` selects the best NPC action by scoring and
sorting mission options. `MissionScorer.prioritize_missions` sorts by
`[-priority_level, -score]` — priority level dominates. The 1.3 readiness
boost for `settlement_expansion` is applied after this sort in
`score_mission_options`, so it never affects the sort order. At high
expansion readiness the NPC should prioritize settlement expansion over
scouting — this is broken.

---

## Problem Statement

**Error**:
expected: :settlement_expansion
got: :system_scouting

**Current behavior**: `score_mission_options` applies 1.3 boost to
`settlement_expansion` score after `prioritize_missions` has already sorted
by priority level. Boost changes the score value but the array order is
already locked. `system_scouting` wins because it ranked higher in the
pre-boost sort.

**Expected behavior**: When `expansion_readiness >= 0.8`,
`settlement_expansion` sorts above `system_scouting` in the returned array.

**Root cause**: Post-sort boost. The fix is to re-sort by score after
applying the boost so the boosted scores determine final order.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `app/services/ai_manager/strategy_selector.rb` | Re-sort after boost | `score_mission_options` lines 127–148 |

### Do Not Touch
| File | Reason |
|---|---|
| `app/services/ai_manager/mission_scorer.rb` | Not broken — sort order there is correct for its own purpose |
| `spec/services/ai_manager/strategy_selector_spec.rb` | Spec is correct — do not change it |

---

## Implementation Steps

> Follow exactly in order. Do not infer.

### Step 1 — Read the current method
```bash
docker exec -it web bash -c 'sed -n "127,150p" app/services/ai_manager/strategy_selector.rb'
```
Confirm it matches what is shown in the Synthesis Report format below.

### Step 2 — Produce Synthesis Report and STOP
SYNTHESIS REPORT
CURRENT CODE
[paste exact current score_mission_options method]
PROPOSED CHANGE
After the map that applies boosts, add a sort_by { |o| -o[:score] }
so boosted scores determine final order.
Proposed code:
def score_mission_options(options, state_analysis)
prioritized_missions = @mission_scorer.prioritize_missions(options, state_analysis)
boosted = prioritized_missions.map do |mission_data|
original_mission = mission_data[:mission]
score = mission_data[:score]
if original_mission[:type] == :settlement_expansion &&
   state_analysis[:expansion_readiness].to_f >= 0.8
  score *= 1.3
  puts "SCORE_DEBUG: #{original_mission[:type]} boosted=#{score}"
end

original_mission.merge(
  score: score,
  analysis: mission_data[:analysis],
  priority_level: mission_data[:priority_level],
  sequencing_info: mission_data[:sequencing_info]
)
end
boosted.sort_by { |o| -o[:score] }
end
RISK
Re-sorting after boost changes the return order for all callers of
score_mission_options. Confirm no other caller depends on the
pre-boost priority_level sort order.
Run:
grep -n "score_mission_options" app/services/ai_manager/strategy_selector.rb
READY TO APPLY? — waiting for approval

### Step 3 — Apply fix (after approval only)

### Step 4 — Remove the debug puts
Remove this line as part of the fix:
```ruby
puts "SCORE_DEBUG: #{original_mission[:type]} boosted=#{score}"
```
It was temporary debug output — do not leave it in.

### Step 5 — Verify
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/strategy_selector_spec.rb'
```
Expected: 0 failures

### Step 6 — Check for regressions
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/'
```
Expected: no new failures

---

## Acceptance Criteria
- [ ] `strategy_selector_spec.rb:238` — 0 failures
- [ ] Full `strategy_selector_spec.rb` — 0 failures
- [ ] No new failures in `spec/services/ai_manager/`
- [ ] Debug `puts` removed
- [ ] Only `strategy_selector.rb` modified

---

## Stop Conditions
- `score_mission_options` is called from more than one place in the file
  and the re-sort breaks the other caller — stop and report
- Fix causes new failures outside `ai_manager/` — stop and report
- Root cause turns out to be inside `mission_scorer.rb` — stop and report,
  do not touch that file

---

## Commit Instructions
```bash
git add app/services/ai_manager/strategy_selector.rb
git commit -m "fix: strategy_selector re-sort after readiness boost so settlement_expansion wins at high readiness"
git push
```

---

## Dependencies
**Blocked by**: none
**Blocks**: none
**Related tasks**: 2026-04-07 StrategySelector nil-state_analysis fix (completed)