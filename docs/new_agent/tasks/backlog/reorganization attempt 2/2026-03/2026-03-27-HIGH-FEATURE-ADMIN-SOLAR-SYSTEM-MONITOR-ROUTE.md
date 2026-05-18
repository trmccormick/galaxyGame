# 2026-03-27-HIGH-FEATURE-ADMIN-SOLAR-SYSTEM-MONITOR-ROUTE

**Agent:** GPT-4.1 (0.33x)
**Priority:** HIGH
**Type:** FEATURE
**Status:** BACKLOG

## Context
Admin dashboard has "MONITOR" button for solar systems that links to /admin/solar_systems/:id/monitor, but this route does not exist, causing routing error.

## Problem
- Route missing in config/routes.rb
- Admin::SolarSystemsController has no monitor action
- No monitor.html.erb view exists for solar systems

## Files
- galaxy_game/config/routes.rb
- galaxy_game/app/controllers/admin/solar_systems_controller.rb
- galaxy_game/app/views/admin/solar_systems/monitor.html.erb (new)

## Steps
1. Add monitor route to admin namespace in routes.rb
2. Add monitor action to Admin::SolarSystemsController with solar system and celestial bodies loading
3. Create monitor view with system-wide monitoring interface similar to celestial body monitor
4. Verify dashboard link works correctly

## Acceptance Criteria
- Clicking "MONITOR" in admin dashboard opens solar system monitor page
- No routing errors
- Monitor page displays system information and controls
- Consistent with other admin monitor interfaces

## Stop Condition
- Routing errors when clicking MONITOR button

## Commit Instructions
```
git add galaxy_game/config/routes.rb galaxy_game/app/controllers/admin/solar_systems_controller.rb galaxy_game/app/views/admin/solar_systems/monitor.html.erb
git commit -m "feat: add monitor route and action for admin solar systems"
```