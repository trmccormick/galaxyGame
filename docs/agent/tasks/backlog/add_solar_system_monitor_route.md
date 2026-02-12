# Add Monitor Route and Action for Admin Solar Systems

## Problem Description
The admin dashboard has a "MONITOR" button for solar systems that links to `/admin/solar_systems/:id/monitor`, but this route does not exist, causing a routing error.

## Current State
- Route: Missing in `config/routes.rb`
- Controller: `Admin::SolarSystemsController` has no `monitor` action
- View: No `monitor.html.erb` exists for solar systems

## Required Changes

### 1. Add Route
Update `galaxy_game/config/routes.rb` in the admin namespace:
```ruby
resources :solar_systems, only: [:index, :show] do
  member do
    get :monitor
  end
end
```

### 2. Add Controller Action
Add `monitor` action to `Admin::SolarSystemsController`:
```ruby
def monitor
  @solar_system = safe_find(SolarSystem, params[:id], includes: [:galaxy, :stars, :celestial_bodies])
  @celestial_bodies = safe_query(@solar_system.celestial_bodies.includes(:atmosphere).order(:name)) if @solar_system
end
```

### 3. Create Monitor View
Create `galaxy_game/app/views/admin/solar_systems/monitor.html.erb` with system-wide monitoring interface, similar to celestial body monitor but for the entire solar system.

### 4. Update Dashboard Link
The dashboard link is already correct: `/admin/solar_systems/<%= system.id %>/monitor`

## Implementation Notes
- Follow the pattern used for celestial bodies monitor
- Include real-time data injection for JavaScript monitoring
- Display system overview, body statuses, and monitoring controls
- Maintain SimEarth aesthetic consistency

## Acceptance Criteria
- Clicking "MONITOR" in admin dashboard opens solar system monitor page
- No routing errors
- Monitor page displays system information and controls
- Consistent with other admin monitor interfaces

## Priority
High - Fixes broken navigation in admin dashboard

## Estimated Effort
2-3 hours (route + controller + view creation)