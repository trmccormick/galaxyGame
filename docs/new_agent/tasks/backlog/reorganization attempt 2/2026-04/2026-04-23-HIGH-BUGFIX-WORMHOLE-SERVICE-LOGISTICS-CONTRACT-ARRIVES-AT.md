# 2026-04-23-HIGH-BUGFIX-WORMHOLE-SERVICE-LOGISTICS-CONTRACT-ARRIVES-AT

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0x — High priority bug fix for single service file with two call sites
**Supervision Level**: 🔴 Watched carefully

## Context
Task 4b added arrives_at as required field on Logistics::Contract with presence validation. WormholeExpansionService creates Logistics::Contract records without setting arrives_at — causing validation failures.

## Problem Statement
ActiveRecord::RecordInvalid: Validation failed: Arrives at can't be blank at wormhole_expansion_service.rb:34 and :50 in create_gate_construction_contract and create_rescue_contract methods.

**Expected**: Both Logistics::Contract.create! calls include arrives_at with reasonable transit times.

## Files Involved
### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `galaxy_game/app/services/wormhole_expansion_service.rb` | Expansion service | Add arrives_at to both contract creation calls |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `spec/services/wormhole_expansion_service_spec.rb` | Verify fix doesn't break specs |

## Implementation Steps
1. **Read service file**: Examine both call sites around lines 34 and 50
2. **Add arrives_at**: create_gate_construction_contract gets arrives_at: 30.days.from_now
3. **Add arrives_at**: create_rescue_contract gets arrives_at: 7.days.from_now
4. **Verify fix**: Run wormhole expansion service spec — expect 0 failures

## Acceptance Criteria
- [ ] Both Logistics::Contract.create! calls include arrives_at
- [ ] Wormhole expansion service spec: 0 failures
- [ ] No regressions

## Stop Conditions
- Service has transit time calculation method — use it instead of hardcoding
- New failures introduced — stop immediately

## Commit Instructions
```bash
git add galaxy_game/app/services/wormhole_expansion_service.rb
git commit -m "fix: wormhole_expansion_service — add arrives_at to Logistics::Contract creation"
```