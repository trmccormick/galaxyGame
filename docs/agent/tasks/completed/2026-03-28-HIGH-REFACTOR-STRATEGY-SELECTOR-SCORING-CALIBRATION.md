# TASK: StrategySelector & MissionScorer — Scoring Calibration and Architecture Review
**Status**: BACKLOG
**Priority**: HIGH
**Type**: refactor
**Created**: 2026-03-28
**Last Updated**: 2026-03-28

---

## Agent Assignment

**Assigned To**: Claude Sonnet 1x
**Why This Agent**: Requires architectural reasoning about scoring weight separation, strategic focus calibration, and integration between MissionScorer and StrategySelector — not a targeted bug fix
**Supervision Level**: 🟢 Autonomous OK — must stop at Synthesis Report before applying anything

---

## Context
The `StrategySelector` and `MissionScorer` form the core AI decision engine. `StrategySelector` generates mission options, scores them via `MissionScorer`, applies strategic multipliers, and selects the optimal action. Currently two spec failures expose a deeper architectural issue: mission-specific value scoring (driven by `mission_option` data) and state-based strategic scoring (driven by `state_analysis`) are conflated inside `MissionScorer`, causing counter-intuitive results where `:system_scouting` scores higher than `:settlement_expansion` even when `expansion_readiness: 0.9` and scouting opportunities are empty.

**Relevant Architecture Docs** — read before starting:
- `docs/architecture/services/ai_manager/strategy_selector.md` — intent, pipeline, tuning guidance
- `docs/architecture/services/ai_manager/mission_scorer.md` — scoring weights, factors, extension points
- `docs/architecture/services/ai_manager/priority_mapping.md` — 4-tier priority system
- `docs/architecture/services/ai_manager/AI_PRIORITY_SYSTEM.md` — tier hierarchy, critical always beats expansion
- `docs/architecture/services/ai_manager/planner.md` — No-Magic protocol context

> Do not create documentation during this task.
> Flag any gaps in your completion report instead.

---

## Problem Statement

Two failing specs expose scoring calibration issues:

**Failure 1** — `strategy_selector_spec.rb:238`
```
expected: :settlement_expansion
     got: :system_scouting
```
When `expansion_readiness: 0.9` and `scouting_opportunities: { high_value: [], strategic: [] }` (empty), `:system_scouting` scores **83.33** vs `:settlement_expansion` **54.71** (after 1.3x boost). Scouting should score near zero with no opportunities.

**Failure 2** — `strategy_selector_spec.rb:381`
```
expected: :resource_focus
     got: :balanced_approach
```
When `critical: ['energy']` with low resources, `determine_overall_strategic_focus` returns `:balanced_approach` instead of `:resource_focus`. Critical resources must always dominate per the 4-tier priority system.

**Current behavior**: Scoring conflates mission-specific value and state-based strategic scores, producing wrong winners.

**Expected behavior**: 
- Empty scouting opportunities → low scouting score regardless of mission data
- Critical resource needs → `:resource_focus` always wins over `:balanced_approach`
- High expansion readiness → `:settlement_expansion` beats `:system_scouting` with no opportunities

---

## Known Investigation History

This issue has been investigated across multiple sessions. Key findings:

**Root cause of Failure 1**: `calculate_scouting_score(state_analysis)` correctly returns ~0 for empty opportunities. But `calculate_value_analysis` for `:system_scouting` uses `mission_option[:systems]` independently, and through `calculate_net_benefit` → risk/success pipeline, produces a high score (~83) regardless of empty state opportunities. **Mission value and state strategic scores are not properly integrated.**

**Root cause of Failure 2**: `determine_optimal_focus` uses a threshold-based comparison (`adjusted_a > adjusted_b + 10`). When scores are within threshold, returns `:balanced_approach`. Critical resources check in `break_tie_with_state` only fires on ties in vote counts — but `determine_optimal_focus` never votes `:resource_focus` when scores are close, so the tie never happens.

**Partial fixes already applied** (do not revert):
- `focus_a`/`focus_b` magic labels replaced with canonical names (`focus_a:`, `focus_b:` keyword args)
- `determine_optimal_focus` now accepts `focus_a:` and `focus_b:` keyword args
- `analyze_resource_vs_building_tradeoffs` and `analyze_scouting_vs_building_tradeoffs` use canonical focus names
- `dependency_satisfaction` changed from binary (0/1) to proportional
- `abundant_opportunities` correctly gates on `critical_resources.empty?`

**Do not re-investigate these** — they are correct. Focus only on the two remaining failures.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `galaxy_game/app/services/ai_manager/mission_scorer.rb` | Core scoring logic | `calculate_scouting_score`, `calculate_value_analysis`, `determine_optimal_focus` |
| `galaxy_game/app/services/ai_manager/strategy_selector.rb` | Strategic decision engine | `score_mission_options`, `perform_strategic_tradeoff_analysis` |
| `galaxy_game/spec/services/ai_manager/strategy_selector_spec.rb` | Strategy selector specs | lines 238, 381 |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `galaxy_game/spec/services/ai_manager/mission_scorer_spec.rb` | Confirm no regressions in scorer specs |
| `docs/architecture/services/ai_manager/strategy_selector.md` | Intent and pipeline |
| `docs/architecture/services/ai_manager/mission_scorer.md` | Scoring weights and factors |
| `docs/architecture/services/ai_manager/priority_mapping.md` | 4-tier priority hierarchy |

---

## Implementation Steps

> Read ALL reference files and review known investigation history before touching any file.
> Produce Synthesis Report after research, before writing any code.

### Step 1 — Research phase (read only)
```bash
docker exec -it web bash -c 'sed -n "352,410p" galaxy_game/app/services/ai_manager/mission_scorer.rb'
docker exec -it web bash -c 'sed -n "529,560p" galaxy_game/app/services/ai_manager/mission_scorer.rb'
docker exec -it web bash -c 'sed -n "676,703p" galaxy_game/app/services/ai_manager/mission_scorer.rb'
docker exec -it web bash -c 'sed -n "785,825p" galaxy_game/app/services/ai_manager/mission_scorer.rb'
docker exec -it web bash -c 'sed -n "127,152p" galaxy_game/app/services/ai_manager/strategy_selector.rb'
docker exec -it web bash -c 'sed -n "336,395p" galaxy_game/app/services/ai_manager/strategy_selector.rb'
```

### Step 2 — Produce Synthesis Report and STOP

After research produce the report (format below) and wait for approval.

### Step 3 — Fix Failure 1: Scouting score ignores empty opportunities

The fix must ensure that when `state_analysis[:scouting_opportunities]` is empty, `:system_scouting` scores low regardless of `mission_option[:systems]`. 

**Approach**: In `calculate_value_analysis` for `:system_scouting`, weight the mission systems value against state-based scouting opportunity score:
```ruby
when :system_scouting
  systems = mission_option[:systems] || []
  state_scouting_score = calculate_scouting_score(state_analysis)
  # Only score mission systems if state supports scouting
  opportunity_factor = state_scouting_score > 0 ? 1.0 : 0.3
  total_value = systems.sum { |s| ... } * opportunity_factor
```

> This is a suggested direction — verify it doesn't break other scorer specs before applying.

### Step 4 — Fix Failure 2: Critical resources must dominate strategic focus

Critical resource needs must override `determine_optimal_focus` threshold logic. The fix in `analyze_resource_vs_scouting_tradeoffs` correctly gates on `critical_resources.empty?` — but `determine_optimal_focus` itself needs a critical resources override as a keyword arg:
```ruby
def determine_optimal_focus(score_a, score_b, opportunity_cost, risk_adjustment, long_term_value, focus_a: :resource_focus, focus_b: :scouting_focus, critical_resources: [])
  return focus_a if critical_resources.any? && focus_a == :resource_focus
  # ... rest of existing logic
end
```

And pass `critical_resources:` from the caller:
```ruby
recommended_focus = determine_optimal_focus(
  resource_score, scouting_score, ...,
  focus_a: :resource_focus, focus_b: :scouting_focus,
  critical_resources: critical_resources
)
```

### Step 5 — Remove debug puts

Ensure no `puts "SCORE_DEBUG..."` lines remain in `strategy_selector.rb` before committing.

---

## Synthesis Report Format
```
RESEARCH FINDINGS
calculate_value_analysis for scouting — current logic: [summary]
calculate_scouting_score — returns what for empty opportunities: [value]
determine_optimal_focus — current critical resources handling: [summary]
Score gap confirmed: scouting=[X] vs expansion=[Y] with empty opportunities

PROPOSED FIX — Failure 1
[exact code change with before/after]

PROPOSED FIX — Failure 2  
[exact code change with before/after]

REGRESSION RISK
[which existing scorer specs could be affected]

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence

1. **Target specs**:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec galaxy_game/spec/services/ai_manager/strategy_selector_spec.rb galaxy_game/spec/services/ai_manager/mission_scorer_spec.rb'
```

2. **Full AI manager specs**:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec galaxy_game/spec/services/ai_manager/'
```

3. **Full suite**:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

---

## Acceptance Criteria
- [ ] `:settlement_expansion` wins over `:system_scouting` when `expansion_readiness: 0.9` and scouting opportunities empty
- [ ] `:resource_focus` returned when `critical: ['energy']` even with abundant scouting opportunities
- [ ] All `mission_scorer_spec.rb` examples pass (no regressions)
- [ ] All `strategy_selector_spec.rb` examples pass
- [ ] No `puts` debug lines in production code
- [ ] Full suite run completed and logged

---

## Stop Conditions — escalate to user immediately if:
- Fix to Failure 1 causes regressions in other scorer specs
- Fix to Failure 2 breaks the existing critical resource prioritization tests
- Score gap between scouting and expansion is larger than expected and requires weight redesign
- Any architectural decision beyond what docs cover

---

## Commit Instructions
Use single quotes in zsh. Run git on host:
```bash
git add galaxy_game/app/services/ai_manager/mission_scorer.rb
git add galaxy_game/app/services/ai_manager/strategy_selector.rb
git add galaxy_game/spec/services/ai_manager/strategy_selector_spec.rb
git commit -m 'fix: mission_scorer/strategy_selector — scoring calibration, critical resource focus, scouting opportunity weighting'
git push
```

---

## Documentation
- [ ] Update `docs/architecture/services/ai_manager/mission_scorer.md` — document the opportunity_factor weighting logic
- [ ] Update `docs/architecture/services/ai_manager/strategy_selector.md` — document critical resource override in determine_optimal_focus

---

## Dependencies
**Blocked by**: none
**Blocks**: none
**Related tasks**: `2026-03-27-HIGH-REFACTOR-ESCALATION-SERVICE-NO-MAGIC-ROBOT-DEPLOYMENT.md`

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