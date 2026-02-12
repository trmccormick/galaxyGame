# Add Admin Show View for Celestial Bodies

## Problem Description
In the admin simulation page (`/admin/simulation`), the "View" link redirects to the public celestial body view instead of an admin view with enhanced information and options.

## Current Issue
- "View" link uses `celestial_body_path(body)` → public `/celestial_bodies/:id`
- No admin show action exists for celestial bodies
- Admins miss out on administrative controls and detailed information

## Required Changes

### 1. Add Show Route
Update `galaxy_game/config/routes.rb` in admin namespace:
```ruby
resources :celestial_bodies, only: [:index, :show] do
  member do
    get :monitor
    # ... other member routes
  end
end
```

### 2. Add Show Action to Controller
Add `show` action to `Admin::CelestialBodiesController`:
```ruby
def show
  @celestial_body = safe_find(CelestialBodies::CelestialBody, params[:id])
  @atmosphere = @celestial_body.atmosphere
  @hydrosphere = @celestial_body.hydrosphere
  @geosphere = @celestial_body.geosphere
  @biosphere = @celestial_body.biosphere
end
```

### 3. Create Admin Show View
Create `galaxy_game/app/views/admin/celestial_bodies/show.html.erb` with:
- Comprehensive celestial body information
- Admin controls (edit, monitor, surface view)
- System integration details
- AI analysis options
- Terraforming status
- Settlement information

### 4. Update Simulation View Link
Change the "View" link in `admin/simulation/index.html.erb`:
```erb
<%= link_to '👁️ Admin View', admin_celestial_body_path(body), style: '...' %>
```

## Implementation Notes
- Follow the pattern of other admin show views
- Include all public information plus admin-specific controls
- Maintain SimEarth aesthetic
- Ensure proper authorization checks

## Files to Modify
- `galaxy_game/config/routes.rb`
- `galaxy_game/app/controllers/admin/celestial_bodies_controller.rb`
- `galaxy_game/app/views/admin/celestial_bodies/show.html.erb` (new)
- `galaxy_game/app/views/admin/simulation/index.html.erb`

## Acceptance Criteria
- "View" link in admin simulation goes to admin celestial body show page
- Admin show page displays comprehensive information and controls
- No routing errors
- Consistent with other admin interfaces

## Priority
Medium - Improves admin navigation and information access

## Estimated Effort
2-3 hours (route + controller + view creation)