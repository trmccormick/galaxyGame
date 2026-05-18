# 2026-03-24-MEDIUM-FEATURE-ADMIN-CELESTIAL-BODY-SHOW-VIEW

**Agent:** GPT-4.1 (0.33x)
**Priority:** MEDIUM
**Type:** FEATURE
**Status:** BACKLOG

## Context
Admin simulation page "View" link redirects to public celestial body view instead of admin view with enhanced information and controls.

## Problem
- "View" link uses celestial_body_path(body) → public /celestial_bodies/:id
- No admin show action exists for celestial bodies
- Admins miss administrative controls and detailed information

## Files
- galaxy_game/config/routes.rb
- galaxy_game/app/controllers/admin/celestial_bodies_controller.rb
- galaxy_game/app/views/admin/celestial_bodies/show.html.erb (new)
- galaxy_game/app/views/admin/simulation/index.html.erb

## Steps
1. Add show route to admin namespace in routes.rb
2. Add show action to Admin::CelestialBodiesController with comprehensive data loading
3. Create admin show view with celestial body information, admin controls, system integration details, AI analysis options, terraforming status, settlement information
4. Update simulation view link to use admin_celestial_body_path

## Acceptance Criteria
- "View" link in admin simulation goes to admin celestial body show page
- Admin show page displays comprehensive information and controls
- No routing errors
- Consistent with other admin interfaces

## Stop Condition
- Routing errors when clicking admin view link

## Commit Instructions
```
git add galaxy_game/config/routes.rb galaxy_game/app/controllers/admin/celestial_bodies_controller.rb galaxy_game/app/views/admin/celestial_bodies/show.html.erb galaxy_game/app/views/admin/simulation/index.html.erb
git commit -m "feat: add admin show view for celestial bodies"
```