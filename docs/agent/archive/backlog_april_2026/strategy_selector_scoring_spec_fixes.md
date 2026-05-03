# StrategySelector Scoring Spec Fixes

## Overview
Fix scoring logic in StrategySelector to properly weight expansion_readiness and critical resource needs, ensuring correct prioritization of settlement expansion over system scouting and proper strategic focus determination.

## Issues Identified
1. **Expansion Readiness Weighting**: When `expansion_readiness >= 0.9`, `:settlement_expansion` should score higher than `:system_scouting`, but MissionScorer returns incorrect ordering.

2. **Strategic Focus for Critical Resources**: When critical resource needs exist, `strategic_focus` should return `:resource_focus` instead of `:balanced_approach`.

## Root Cause
`@mission_scorer.prioritize_missions` does not correctly weight `expansion_readiness` or critical resource needs. **MissionScorer architecture must not be modified without review.**

## Solution Approach
Implement score adjustments in `StrategySelector#score_mission_options` and enhance `StrategySelector#determine_overall_strategic_focus` to apply correct weighting based on state analysis.

## Files to Modify
- `app/services/ai_manager/strategy_selector.rb`

## Phases

### Phase 1: Analyze Current Scoring Logic
- Review `score_mission_options` method and how it integrates MissionScorer results
- Examine `determine_overall_strategic_focus` and trade-off analysis
- Identify exact points where score adjustments are needed
- Document current behavior vs expected behavior

### Phase 2: Implement Score Adjustments for Mission Options
- Modify `score_mission_options` to apply manual score boosts:
  - For `:settlement_expansion` options: if `state_analysis[:expansion_readiness] >= 0.8`, multiply score by 1.5
  - For `:resource_acquisition` with `priority: :critical`: multiply score by 1.4
- Ensure adjustments are applied after MissionScorer results but before strategic adjustments

### Phase 3: Fix Strategic Focus Determination
- Enhance `determine_overall_strategic_focus` to override MissionScorer recommendations when:
  - Critical resources exist → force `:resource_focus`
  - `expansion_readiness >= 0.9` and no critical resources → prefer `:building_focus`
- Add state_analysis parameter to the method if needed

### Phase 4: Test and Validate Fixes
- Run `strategy_selector_spec.rb` to verify both failing scenarios now pass
- Run full AI Manager test suite to ensure no regressions
- Verify scoring logic produces expected prioritization

### Phase 5: Documentation Update
- Update method comments to reflect new weighting logic
- Add inline comments explaining score adjustment rationale

## Success Criteria
- `strategy_selector_spec.rb` passes all tests
- Expansion readiness 0.9 correctly prioritizes settlement expansion over system scouting
- Critical resource needs correctly set strategic focus to `:resource_focus`
- No regressions in other AI Manager functionality
- MissionScorer architecture remains untouched

## Testing Instructions
```bash
# Run specific spec
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/strategy_selector_spec.rb'

# Run full AI Manager suite
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/ai_manager/'

# Check for any related failures
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/ | grep -i strategy'
```

## Risk Assessment
- **Low Risk**: Changes are localized to StrategySelector scoring logic
- **MissionScorer Protection**: Explicitly avoiding changes to MissionScorer as requested
- **Backward Compatibility**: Adjustments are additive, not replacing existing logic

## Dependencies
- None (MissionScorer architecture review would be separate task if needed)

## Estimated Effort
- Analysis: 30 minutes
- Implementation: 1-2 hours
- Testing: 30 minutes
- Documentation: 15 minutes

## Priority
High - Blocking proper AI decision making in settlement expansion scenarios.</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/backlog/strategy_selector_scoring_spec_fixes.md