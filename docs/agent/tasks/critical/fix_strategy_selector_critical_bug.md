# Fix Critical StrategySelector Bug

## Problem
StrategySelector implementation has a critical runtime bug that prevents AI mission scoring from working. The `analyze_mission_value_cost_risk` method is called but not defined in MissionScorer.rb, causing NoMethodError when AI attempts to evaluate missions.

## Current State
- **StrategySelector appears complete** but has critical functionality gap
- **Method called but undefined**: `analyze_mission_value_cost_risk` in MissionScorer.rb
- **Runtime errors imminent**: AI will crash when trying to score missions
- **Test suite affected**: 13/14 tests passing, 1 likely failing due to this missing method

## Required Changes

### Fix Missing Method
- Add `analyze_mission_value_cost_risk` method to MissionScorer.rb
- Implement mission value calculation logic
- Implement mission cost calculation logic
- Implement mission risk calculation logic
- Implement net mission score calculation logic

### Method Implementation
```ruby
def analyze_mission_value_cost_risk(mission, state)
  {
    value: calculate_mission_value(mission, state),
    cost: calculate_mission_cost(mission, state),
    risk: calculate_mission_risk(mission, state),
    net_score: calculate_net_mission_score(mission, state)
  }
end

private

def calculate_mission_value(mission, state)
  # Mission benefit/importance (0-10)
  base_value = mission.strategic_value || 5.0

  # Adjust based on state needs
  if mission.type == 'resource_acquisition' && state.resources_critical?
    base_value * 1.5
  elsif mission.type == 'expansion' && state.expansion_ready?
    base_value * 1.3
  else
    base_value
  end
end

def calculate_mission_cost(mission, state)
  # Resource/time cost (0-10, higher = more expensive)
  base_cost = mission.resource_cost || 3.0

  # Adjust based on capabilities
  if state.has_sufficient_resources?(mission)
    base_cost * 0.8
  else
    base_cost * 1.2
  end
end

def calculate_mission_risk(mission, state)
  # Risk/danger level (0-10, higher = riskier)
  base_risk = mission.risk_level || 2.0

  # Adjust based on settlement health
  if state.settlement_health < 0.5
    base_risk * 1.5  # More risky when weak
  else
    base_risk
  end
end

def calculate_net_mission_score(mission, state)
  value = calculate_mission_value(mission, state)
  cost = calculate_mission_cost(mission, state)
  risk = calculate_mission_risk(mission, state)

  # Net score: value - cost - risk
  value - (cost * 0.5) - (risk * 0.3)
end
```

## Success Criteria
- [ ] `analyze_mission_value_cost_risk` method exists and is callable
- [ ] Method returns proper hash with value, cost, risk, net_score keys
- [ ] All 14 StrategySelector tests pass (no runtime errors)
- [ ] AI can successfully score missions without crashing
- [ ] Mission evaluation works in Rails console testing

## Files to Create/Modify
- `galaxy_game/app/services/ai_manager/mission_scorer.rb` (modify - add missing method)

## Testing Requirements
- Run StrategySelector specs: `docker-compose -f docker-compose.dev.yml exec web bundle exec rspec spec/services/ai_manager/strategy_selector_spec.rb`
- Verify 14/14 tests pass
- Test in Rails console: Create mission, call analyze_mission_value_cost_risk
- Ensure no NoMethodError exceptions

## Dependencies
- **StrategySelector implementation complete** - bug in existing code
- **No RSpec conflicts** - can run during grinding</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/critical/fix_strategy_selector_critical_bug.md