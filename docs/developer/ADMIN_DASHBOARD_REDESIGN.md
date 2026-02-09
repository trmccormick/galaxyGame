# Admin Dashboard Redesign Planning Document

## Overview
This document outlines the phased redesign of the Galaxy Game admin dashboard to support multi-galaxy navigation while prioritizing quick access to the Sol system. The redesign transforms the current flat celestial body list into a hierarchical galaxy → system → body structure, maintaining the SimEarth aesthetic and integrating existing admin views.

## Current State Analysis
- **Dashboard**: Flat list of celestial bodies with inline CSS (458 lines)
- **Galaxies**: Dedicated `/admin/galaxies` section with index/show views
- **Navigation Gap**: Dashboard doesn't link to galaxies or other admin sections
- **Sol Priority**: Sol system exists but not prominently featured for admin monitoring

## Design Goals
1. **Multi-Galaxy Support**: Dashboard as galaxy command center with system navigation
2. **Sol Quick Access**: Default to Milky Way, highlight Sol for core system monitoring
3. **Hierarchical Navigation**: Admin → Galaxy → System → Body with breadcrumbs
4. **Integration**: Tie in existing views (galaxies, solar_systems, celestial_bodies)
5. **Scalability**: Support hundreds of systems across multiple galaxies
6. **Maintain Aesthetics**: Keep SimEarth green terminal theme

## Phased Implementation Plan

### Phase 1: Planning & Documentation (Current)
- [x] Create this planning document
- [x] Review existing admin views and navigation
- [x] Define success criteria and acceptance tests
- [ ] Update ADMIN_SYSTEM.md with dashboard changes

### Phase 2: Controller Foundation (Next)
- [ ] Update `Admin::DashboardController#index`
  - Add galaxy selection logic
  - Default to Milky Way galaxy
  - Load systems for selected galaxy
  - Prioritize Sol system in ordering
- [ ] Add galaxy parameter handling
- [ ] Update stats calculation for galaxy-scoping
- [ ] Add Sol quick-access logic

### Phase 3: View Structure (After Controller)
- [ ] Extract inline CSS to `app/assets/stylesheets/admin/dashboard.css`
- [ ] Create galaxy cards section
- [ ] Add galaxy selector dropdown
- [ ] Implement system cards with Sol highlighting
- [ ] Add quick access panel for core systems

### Phase 4: Navigation Integration (After View)
- [ ] Add breadcrumbs component (`app/views/shared/_admin_breadcrumbs.html.erb`)
- [ ] Update galaxy cards to link to `/admin/galaxies/:id`
- [ ] Update system cards to link to `/admin/solar_systems/:id`
- [ ] Add navigation links to other admin sections

### Phase 5: Testing & Validation (After Each Phase)
- [ ] RSpec tests for controller changes
- [ ] Integration tests for view rendering
- [ ] Manual testing of navigation flow
- [ ] Performance testing with multiple galaxies

## Technical Specifications

### Controller Changes
```ruby
class Admin::DashboardController < ApplicationController
  def index
    @galaxies = Galaxy.includes(:solar_systems).order(:name)
    @selected_galaxy = params[:galaxy_id] ? 
      Galaxy.find(params[:galaxy_id]) : 
      Galaxy.find_by(name: 'Milky Way') || @galaxies.first
    
    @star_systems = @selected_galaxy.solar_systems
      .includes(:celestial_bodies)
      .order(Arel.sql("CASE WHEN name = 'Sol' THEN 0 ELSE 1 END, name"))
    
    @sol_system = @selected_galaxy.solar_systems.find_by(name: 'Sol') if @selected_galaxy.name == 'Milky Way'
    @galaxy_stats = calculate_galaxy_stats(@selected_galaxy)
    @system_alerts = get_recent_alerts(@selected_galaxy)
    @ai_status = { ... } # existing
    @recent_activity = ActivityLog.order(created_at: :desc).limit(10)
  end
end
```

### View Structure
```erb
<!-- Galaxy Selector -->
<div class="galaxy-selector">
  <select id="galaxy-select">
    <% @galaxies.each do |galaxy| %>
      <option value="<%= galaxy.id %>" <%= 'selected' if galaxy == @selected_galaxy %>>
        <%= galaxy.name %>
      </option>
    <% end %>
  </select>
</div>

<!-- Quick Access Panel -->
<div class="quick-access-panel">
  <% if @sol_system %>
    <a href="/admin/solar_systems/<%= @sol_system.id %>" class="quick-access-link sol-highlight">
      🌞 Monitor Sol System
    </a>
  <% end %>
  <a href="/admin/galaxies">🌌 Galaxy Overview</a>
  <a href="/admin/ai_manager/missions">🤖 AI Missions</a>
</div>

<!-- Galaxy Stats -->
<div class="galaxy-stats">
  <h3><%= @selected_galaxy.name %> Statistics</h3>
  <!-- stats display -->
</div>

<!-- System Cards Grid -->
<div class="systems-grid">
  <% @star_systems.each do |system| %>
    <div class="system-card <%= 'sol-highlight' if system.name == 'Sol' %>">
      <!-- system card content -->
    </div>
  <% end %>
</div>
```

### CSS Structure (`admin/dashboard.css`)
```css
/* Galaxy Selector */
.galaxy-selector {
  margin-bottom: 20px;
}

/* Quick Access Panel */
.quick-access-panel {
  display: flex;
  gap: 15px;
  margin-bottom: 20px;
}

.quick-access-link {
  padding: 10px 15px;
  background: #1a1a1a;
  border: 1px solid #0f0;
  color: #0f0;
  text-decoration: none;
  border-radius: 5px;
}

.sol-highlight {
  border-color: #ffd700 !important;
  background: rgba(255, 215, 0, 0.1) !important;
}

/* Systems Grid */
.systems-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
  gap: 20px;
}

/* Existing styles from inline CSS */
```

## Success Criteria
- [ ] Dashboard loads with Milky Way selected by default
- [ ] Sol system appears first and highlighted in system cards
- [ ] Galaxy selector allows switching between galaxies
- [ ] Quick access panel provides links to key admin sections
- [ ] System cards link to existing `/admin/solar_systems/:id` views
- [ ] Galaxy cards link to existing `/admin/galaxies/:id` views
- [ ] Breadcrumbs show Admin → Galaxy → System navigation
- [ ] All existing dashboard functionality preserved
- [ ] No inline CSS remaining in view
- [ ] RSpec tests pass for all changes
- [ ] Performance acceptable with 100+ systems

## Risk Assessment
- **Low Risk**: Controller changes are additive, don't break existing logic
- **Low Risk**: View changes maintain existing structure while adding features
- **Medium Risk**: CSS extraction requires careful migration of 132 lines
- **Low Risk**: Galaxy defaulting ensures backward compatibility

## Dependencies
- Existing Galaxy and StarSystem models
- Existing admin views (`/admin/galaxies`, `/admin/solar_systems`)
- SimEarth CSS theme consistency
- Docker container for testing

## Timeline Estimate
- Phase 1: 1 hour (documentation)
- Phase 2: 2 hours (controller)
- Phase 3: 3 hours (view + CSS)
- Phase 4: 2 hours (navigation)
- Phase 5: 2 hours (testing)
- **Total**: 10 hours

## Verification Steps
After each phase:
1. Run full RSpec suite in container
2. Manual navigation testing
3. Check browser console for errors
4. Verify CSS loads correctly
5. Test galaxy switching functionality
6. Confirm Sol highlighting works

## Rollback Plan
- Git branches for each phase
- Database changes minimal (read-only operations)
- CSS can be reverted to inline if needed
- Controller changes can be commented out

## Future Enhancements (Post-MVP)
- Real-time alerts system
- Dashboard customization per admin user
- Advanced filtering and search
- Performance optimization for 1000+ systems
- Mobile responsiveness
- WebSocket live updates</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/developer/ADMIN_DASHBOARD_REDESIGN.md