# TASK: Fix strategy_selector_spec:238 — settlement_expansion scoring regression
**Status**: ACTIVE
**Priority**: CRITICAL
**Type**: bug-fix
**Created**: 2026-04-08
**Last Updated**: 2026-04-08

## Agent Assignment
**Assigned To**: Claude Sonnet 1x
**Why**: Scoring math across scorer branches; align to design (high readiness → expand).
**Supervision Level**: 🟡 Standard

## Context
NPC AI favors scouting over expansion at readiness=0.9 due to scorer base/cost/modifiers. Design: high readiness prioritizes settlement_expansion. Prior GPT fix (re-sort) insufficient—scouting net score still higher.

**Docs**: docs/architecture/ai_manager/ (NPC strategy)

## Problem Statement
**Error**: expect(top_option[:type]).to eq(:settlement_expansion) got :system_scouting [spec:247]
**Current**: scorer base (scouting 35 * mods > expansion 50 * readiness_bonus), high expansion cost (145 vs 45).
**Expected**: expansion tops at readiness >=0.8.

**Key Code**:
- scorer calculate_base_score: scouting 35, expansion 50
- strategic_modifier: scouting *1.2 if readiness>0.7 (!); expansion *(readiness+0.5)
- costs: expansion 145, scouting 45

## Files Involved
Primary:
| File | Key |
|---|---|
| app/services/ai_manager/mission_scorer.rb | calculate_base_score/strategic_modifier/cost_analysis ~290-420 |
| app/services/ai_manager/strategy_selector.rb | score_mission_options ~127 (remove prior boost) |

## Implementation Steps
1. **Diagnostics** (run all):
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/strategy_selector_spec.rb:238 --format documentation | tail -30'
sed -n "290,420p" app/services/ai_manager/mission_scorer.rb # confirm provided snippet

text
2. **Synthesis Report** (STOP):
SCORES BREAKDOWN: [compute scouting vs expansion at 0.9 readiness]
ROOT: scouting strategic *1.2 overrides expansion bonus; costs amplify.
FIX PROPOSAL: A) Boost expansion base to 60; B) Invert scouting mod at high readiness; C) Reduce expansion cost at high readiness/capability.
RECOMMEND: B — no-scout mod when readiness>=0.8 (design-aligned).
RISK: Other missions.
READY?

text
3. **Apply**: Implement approved (prefer scorer-only).
4. **Cleanup**: Remove selector boost/puts.
5. **Test**: isolation → ai_manager/ → full log.

## Acceptance Criteria
- spec:238 green
- No ai_manager/ regressions
- expansion tops scouting at 0.9

## Stop Conditions
- Breaks resource_acquisition/etc. → escalate
- Needs design override → human

## Commit
git commit -m "fix: mission_scorer strategic mod favors expansion at high readiness"

## Dependencies
Blocks: processing_service_spec