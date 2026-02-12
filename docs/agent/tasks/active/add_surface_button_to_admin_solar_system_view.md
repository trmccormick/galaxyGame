# Add Surface Button to Admin Solar System View

## Problem
The admin solar system show view (`/admin/solar_systems/:id`) displays celestial body cards with action buttons, but is missing a "Surface" button despite the functionality existing at `/admin/celestial_bodies/:id/surface`.

## Current State
- Route exists: `GET /admin/celestial_bodies/:id/surface`
- Controller action exists: `Admin::CelestialBodiesController#surface`
- View exists: `app/views/admin/celestial_bodies/surface.html.erb`
- UI only shows "View Details" and "Monitor" buttons

## Required Changes
1. Add "Surface" button to the `body-actions` div in `/admin/solar_systems/show.html.erb`
2. Button should link to `/admin/celestial_bodies/<%= body.id %>/surface`
3. Style should match existing action buttons (`.action-btn` class)
4. Position should be consistent with other buttons

## Implementation Details
- Location: `galaxy_game/app/views/admin/solar_systems/show.html.erb` around line 240
- Add button between "View Details" and "Monitor" or after "Monitor"
- Use same onclick pattern: `onclick="window.location.href='/admin/celestial_bodies/<%= body.id %>/surface'"`

## Testing
- Verify button appears on admin solar system pages
- Verify clicking button navigates to surface view
- Verify surface view loads correctly with tileset data

## Priority
Medium - Missing navigation to existing feature affects admin usability</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/active/add_surface_button_to_admin_solar_system_view.md