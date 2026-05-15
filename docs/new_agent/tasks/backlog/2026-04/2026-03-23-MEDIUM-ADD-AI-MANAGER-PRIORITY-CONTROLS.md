# 2026-03-23-MEDIUM-ADD-AI-MANAGER-PRIORITY-CONTROLS

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Medium priority feature for AI manager priority controls
**Supervision Level**: 🔴 Watched carefully

## Context
Admin simulation page lacks controls for adjusting AI manager priorities during testing phases. AI priorities are hardcoded but admins should tune simulation parameters.

## Problem Statement
AI priority system exists with hardcoded values in AiPrioritySystem. No admin interface to adjust priorities during testing. TIME CONTROLS and TESTING TOOLS exist but don't include AI priority tuning.

**Expected**: AI MANAGER CONTROLS section in admin simulation page with adjustable sliders/inputs for priority categories.

## Files Involved
### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `galaxy_game/config/game_constants.rb` | Constants file | Move AI priorities from AiPrioritySystem to constants |
| `galaxy_game/app/models/ai_priority_system.rb` | AI system | Update to reference constants instead of hardcoded values |
| `galaxy_game/app/views/admin/simulation/index.html.erb` | Simulation view | Add AI MANAGER CONTROLS section with sliders/inputs |
| `galaxy_game/app/javascript/admin/simulation.js` | Simulation JS | Add JavaScript for real-time priority adjustments |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `galaxy_game/app/views/admin/simulation/index.html.erb` | Existing TIME CONTROLS section for pattern |

## Implementation Steps
1. **Move constants**: Move hardcoded values from AiPrioritySystem to GameConstants::AI_PRIORITIES
2. **Update AI system**: Modify to reference constants instead of hardcoded values
3. **Add UI section**: Create 🤖 AI MANAGER CONTROLS section in admin simulation page
4. **Create controls**: Add adjustable sliders/inputs for each priority category
5. **Connect system**: Integrate with existing AI priority system for real-time adjustments
6. **Integrate with time controls**: Connect with TIME CONTROLS for testing different configurations

## Acceptance Criteria
- [ ] AI priorities moved to game_constants.rb as GameConstants::AI_PRIORITIES
- [ ] AI system references constants instead of hardcoded values
- [ ] AI MANAGER CONTROLS section added to admin simulation page
- [ ] Adjustable controls for Critical and Operational priority categories
- [ ] Real-time adjustment capability during testing sessions

## Stop Conditions
- Constants move breaks existing AI priority system
- UI integration conflicts with existing admin simulation page structure

## Commit Instructions
```bash
git add galaxy_game/config/game_constants.rb
git add galaxy_game/app/models/ai_priority_system.rb
git add galaxy_game/app/views/admin/simulation/index.html.erb
git add galaxy_game/app/javascript/admin/simulation.js
git commit -m "feat: AI manager priority controls — add adjustable controls to admin simulation page"
```