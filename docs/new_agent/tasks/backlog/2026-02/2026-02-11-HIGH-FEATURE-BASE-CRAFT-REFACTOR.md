# BaseCraft Model Refactor for Modularity

## Context
BaseCraft model is overly complex and lacks modularity for new craft types and upgrades. Current implementation has too many concerns mixed together.

## Problem
- BaseCraft includes many modules directly (HasModules, HasRigs, EnergyManagement, etc.)
- No upgrade method for craft enhancement
- Lacks extensibility for new craft types
- Complex inheritance hierarchy makes maintenance difficult

## Solution
Refactor BaseCraft to use composition over inheritance, extract upgrade functionality, and improve modularity.

## Files to Modify
- `app/models/craft/base_craft.rb` - Refactor for modularity
- `spec/models/craft/base_craft_spec.rb` - Update tests for new structure

## Implementation Steps
1. Extract craft capabilities into separate concern modules
2. Implement upgrade system with upgrade method
3. Create craft type registry for extensibility
4. Refactor associations to use more modular approach
5. Add upgrade validation and cost calculation
6. Test that Craft::BaseCraft responds to :upgrade method

## Acceptance Criteria
- Craft::BaseCraft.respond_to?(:upgrade) returns true
- Modular structure with separated concerns
- Upgrade functionality implemented
- RSpec tests pass for upgrade method
- Improved maintainability and extensibility

## Agent Assignment
0.33x - Model refactoring and craft systems specialist

## Priority
HIGH

## Stop Condition
BaseCraft refactored with upgrade method and tests passing

## Commit Message
refactor: modularize BaseCraft model with upgrade functionality</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/new_agent/tasks/backlog/2026-02/2026-02-11-HIGH-FEATURE-BASE-CRAFT-MODEL-REFACTOR.md