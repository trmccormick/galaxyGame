# Add AI Manager Priority Controls to Admin Simulation Page

## Problem
The admin simulation page lacks controls for adjusting AI manager priorities during testing phases. Currently, AI priorities are hardcoded in the system, but admins should be able to tune simulation parameters by adjusting how the AI prioritizes different aspects of colony management.

## Current State
- AI priority system exists with hardcoded values in `AiPrioritySystem`:
  - **Critical**: life_support (1000), atmospheric_maintenance (900), debt_repayment (800)
  - **Operational**: resource_procurement (500), construction (300), expansion (100)
- **Constants should be moved to `game_constants.rb`** for easier tuning
- No admin interface to adjust these priorities during testing
- TIME CONTROLS and TESTING TOOLS exist but don't include AI priority tuning

## Context from User
"Most likely Admins should be able to adjust priorities for the AI manager concerning different 'Simulation Parameters' During testing it's more about tuning the simulation during testing phases."

## Required Changes
1. **Move hardcoded constants** from `AiPrioritySystem` to `game_constants.rb` as `GameConstants::AI_PRIORITIES`
2. **Update AI system** to reference constants instead of hardcoded values
3. **Add "🤖 AI MANAGER CONTROLS" section** to `/admin/simulation/index.html.erb`
4. **Create adjustable sliders/inputs** for each priority category
5. **Connect to existing AI priority system** for real-time adjustments
6. **Integrate with TIME CONTROLS** for testing different priority configurations

## Implementation Plan
- **Move constants** from `AiPrioritySystem` to `GameConstants::AI_PRIORITIES` for easy tuning
- **UI Components**: Sliders or number inputs for each priority category in admin simulation page
- **JavaScript**: Update priority values in real-time during testing sessions
- **Backend**: Modify AI priority system to accept dynamic values (future enhancement)
- **Integration**: Connect with TIME CONTROLS for testing different priority configurations
- **Direct editing**: Admins can modify values directly in `game_constants.rb` after constants are moved

## Immediate Benefits
- **Easy testing**: Modify priority values directly in constants file
- **Version control**: Priority changes tracked in git
- **Documentation**: Clear default values with comments
- **Future UI**: Constants structure ready for dynamic admin controls

## Priority Categories to Control
**Critical Priorities:**
- Life Support (default: 1000)
- Atmospheric Maintenance (default: 900)
- Debt Repayment (default: 800)

**Operational Priorities:**
- Resource Procurement (default: 500)
- Construction (default: 300)
- Expansion (default: 100)

## Use Cases
- **Testing phases**: Tune AI behavior for different simulation scenarios
- **Balance testing**: Adjust priorities to see how AI responds to various conditions
- **Debugging**: Modify priorities to isolate specific AI behaviors
- **Scenario planning**: Test different priority configurations for colony strategies

## Dependencies
- Existing AI priority system (`AiPrioritySystem`)
- Admin simulation page structure
- JavaScript for real-time updates

## Priority
Medium - Valuable testing tool for AI behavior tuning</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/active/add_ai_manager_priority_controls.md