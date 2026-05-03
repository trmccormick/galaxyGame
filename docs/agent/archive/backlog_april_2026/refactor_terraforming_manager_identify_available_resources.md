# Backlog Task: Refactor TerraformingManager#identify_available_resources

## Problem
TerraformingManager#identify_available_resources is hardcoded to specific planet names (@worlds[:venus], @worlds[:titan], @worlds[:saturn]), breaking if world names change or new systems are added. This violates the data-driven AI vision and SOL-as-training-ground principle.

## Goals
- Make resource identification data-driven based on celestial body atmospheric composition
- Use gas percentages and body type (gas_giant, terrestrial, ice_giant) to determine available resources
- Remove hardcoded planet name references
- Enable AI decisions based on actual data, not planet names

## Steps
1. Analyze current hardcoded logic in TerraformingManager#identify_available_resources
2. Query celestial body atmospheric composition dynamically
3. Implement gas percentage thresholds for resource availability
4. Map body types to expected resource profiles
5. Update method to use data-driven approach
6. Test with different celestial body configurations

## Acceptance Criteria
- No hardcoded planet names in resource identification logic
- Method works with any celestial body configuration
- AI decisions based on atmospheric data, not planet names
- Maintains existing functionality while enabling scalability

## Technical Details
**File**: app/services/ai_manager/terraforming_manager.rb lines 315-322

**Current Code**:
```ruby
# Hardcoded planet names - breaks on system expansion
@worlds[:venus]  # specific planet
@worlds[:titan]  # specific planet
@worlds[:saturn] # specific planet
```

**Target Implementation**:
```ruby
# Data-driven approach
celestial_bodies.each do |body|
  case body.type
  when :gas_giant
    # Check for helium, hydrogen, methane based on composition
  when :terrestrial
    # Check for oxygen, nitrogen, carbon_dioxide
  when :ice_giant
    # Check for water, ammonia, methane
  end
end
```

---

Created: 2026-03-08
Priority: LOW (Technical debt cleanup)
Estimated Effort: 2-4 hours
Dependencies: Manufacturing pipeline stability
Agent Assignment: Claude Sonnet (architecture reasoning) or GPT-4.1 (implementation)</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/backlog/refactor_terraforming_manager_identify_available_resources.md