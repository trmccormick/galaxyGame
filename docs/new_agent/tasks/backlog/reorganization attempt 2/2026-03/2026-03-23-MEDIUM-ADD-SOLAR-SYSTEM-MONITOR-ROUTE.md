# 2026-03-23-MEDIUM-ADD-SOLAR-SYSTEM-MONITOR-ROUTE

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Medium priority feature for solar system monitor route
**Supervision Level**: 🔴 Watched carefully

## Context
Admin dashboard has MONITOR button for solar systems that links to /admin/solar_systems/:id/monitor, but this route does not exist, causing routing error.

## Problem Statement
Route missing in config/routes.rb. Admin::SolarSystemsController has no monitor action. No monitor.html.erb exists for solar systems.

**Expected**: Clicking MONITOR in admin dashboard opens solar system monitor page with system-wide monitoring interface.

## Files Involved
### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `galaxy_game/config/routes.rb` | Routes config | Add monitor route in admin solar_systems namespace |
| `galaxy_game/app/controllers/admin/solar_systems_controller.rb` | Admin controller | Add monitor action with solar system and celestial bodies loading |
| `galaxy_game/app/views/admin/solar_systems/monitor.html.erb` | Admin view | Create system-wide monitoring interface |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `galaxy_game/app/views/admin/celestial_bodies/monitor.html.erb` | Pattern for monitor views |

## Implementation Steps
1. **Add route**: Update routes.rb in admin namespace for solar_systems monitor
2. **Add controller action**: Create monitor action in Admin::SolarSystemsController with solar system and celestial bodies loading
3. **Create monitor view**: Build monitor.html.erb with system overview, body statuses, monitoring controls
4. **Verify dashboard link**: Confirm dashboard link is already correct

## Acceptance Criteria
- [ ] Clicking MONITOR in admin dashboard opens solar system monitor page
- [ ] No routing errors
- [ ] Monitor page displays system information and controls
- [ ] Consistent with other admin monitor interfaces

## Stop Conditions
- Routing conflicts with existing admin routes
- Controller action conflicts with existing solar systems controller

## Commit Instructions
```bash
git add galaxy_game/config/routes.rb
git add galaxy_game/app/controllers/admin/solar_systems_controller.rb
git add galaxy_game/app/views/admin/solar_systems/monitor.html.erb
git commit -m "feat: solar system monitor route — add monitor route and action for admin solar systems"
```