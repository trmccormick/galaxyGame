# 2026-03-23-MEDIUM-ADD-ADMIN-CELESTIAL-BODY-SHOW-VIEW

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Medium priority feature for admin celestial body show view
**Supervision Level**: 🔴 Watched carefully

## Context
Admin simulation page View link redirects to public celestial body view instead of admin view with enhanced information and options.

## Problem Statement
View link uses celestial_body_path(body) → public /celestial_bodies/:id. No admin show action exists for celestial bodies. Admins miss administrative controls and detailed information.

**Expected**: View link in admin simulation goes to admin celestial body show page with comprehensive information and controls.

## Files Involved
### Primary Files — you will edit
| File | Purpose | Action |
|---|---|---|
| `galaxy_game/config/routes.rb` | Routes config | Add show route in admin namespace |
| `galaxy_game/app/controllers/admin/celestial_bodies_controller.rb` | Admin controller | Add show action |
| `galaxy_game/app/views/admin/celestial_bodies/show.html.erb` | Admin view | Create comprehensive show view |
| `galaxy_game/app/views/admin/simulation/index.html.erb` | Simulation view | Update View link to admin path |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `galaxy_game/app/views/admin/celestial_bodies/` | Other admin views for pattern |

## Implementation Steps
1. **Add show route**: Update routes.rb in admin namespace for celestial_bodies show
2. **Add show action**: Create show action in Admin::CelestialBodiesController with atmosphere, hydrosphere, geosphere, biosphere loading
3. **Create admin show view**: Build show.html.erb with comprehensive information, admin controls, system integration details, AI analysis options, terraforming status, settlement information
4. **Update simulation link**: Change View link in admin/simulation/index.html.erb to use admin_celestial_body_path

## Acceptance Criteria
- [ ] View link in admin simulation goes to admin celestial body show page
- [ ] Admin show page displays comprehensive information and controls
- [ ] No routing errors
- [ ] Consistent with other admin interfaces

## Stop Conditions
- Routing conflicts with existing admin routes
- Authorization issues with admin controller

## Commit Instructions
```bash
git add galaxy_game/config/routes.rb
git add galaxy_game/app/controllers/admin/celestial_bodies_controller.rb
git add galaxy_game/app/views/admin/celestial_bodies/show.html.erb
git add galaxy_game/app/views/admin/simulation/index.html.erb
git commit -m "feat: admin celestial body show view — add comprehensive admin view for celestial bodies"
```