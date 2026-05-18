# 2026-03-26-MEDIUM-FEATURE-AI-MANAGER-PRIORITY-CONTROLS

**Agent:** GPT-4.1 (0.33x)
**Priority:** MEDIUM
**Type:** FEATURE
**Status:** BACKLOG

## Context
Admin simulation page lacks controls for adjusting AI manager priorities during testing phases. AI priorities are currently hardcoded but admins need to tune simulation parameters.

## Problem
- AI priorities hardcoded in AiPrioritySystem instead of configurable constants
- No admin interface to adjust priorities during testing
- TIME CONTROLS and TESTING TOOLS don't include AI priority tuning

## Files
- AiPrioritySystem (source of hardcoded values)
- galaxy_game/config/game_constants.rb
- galaxy_game/app/views/admin/simulation/index.html.erb
- JavaScript for real-time updates

## Steps
1. Move hardcoded constants from AiPrioritySystem to GameConstants::AI_PRIORITIES in game_constants.rb
2. Update AI system to reference constants instead of hardcoded values
3. Add "🤖 AI MANAGER CONTROLS" section to admin simulation page
4. Create adjustable sliders/inputs for each priority category (Critical: life_support 1000, atmospheric_maintenance 900, debt_repayment 800; Operational: resource_procurement 500, construction 300, expansion 100)
5. Connect to existing AI priority system for real-time adjustments
6. Integrate with TIME CONTROLS for testing different priority configurations

## Acceptance Criteria
- AI priorities moved to configurable constants in game_constants.rb
- Admin simulation page has AI MANAGER CONTROLS section with adjustable inputs
- Priority changes tracked in version control
- Constants structure ready for future dynamic controls

## Stop Condition
- AI priorities remain hardcoded in AiPrioritySystem

## Commit Instructions
```
git add galaxy_game/config/game_constants.rb galaxy_game/app/views/admin/simulation/index.html.erb
git commit -m "feat: add AI manager priority controls to admin simulation page"
```