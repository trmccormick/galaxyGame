# Redirect Admin Simulation to Digital Twin Sandbox

## Problem Description
The current `/admin/simulation` page provides manual TerraSim controls that are misaligned with admin needs. Individual body simulation should be handled as background tasks, while admin simulation controls should focus on testing and projections through the Digital Twin system.

## Current Issues
- Manual "Run Simulation" buttons for individual bodies
- Namespacing error: `Admin::CelestialBodies::CelestialBody` uninitialized
- Misleading interface - admins expect system-level simulation control
- Redundant with Digital Twin functionality

## Proposed Solution: Option 2 - Redirect to Digital Twin Sandbox

### 1. Remove Manual Simulation Controls
- Remove individual "Run Simulation" buttons from admin simulation page
- Remove `run` and `run_all` actions from `Admin::SimulationController`
- Keep system status display and monitoring

### 2. Redirect Admin Simulation to Digital Twins
- Change admin dashboard link from `/admin/simulation` to `/admin/digital_twins`
- Update navigation button text from "Simulation Control" to "Digital Twin Sandbox"
- Remove or repurpose the admin simulation controller/view

### 3. Update Digital Twin Interface
- Ensure Digital Twin sandbox provides comprehensive simulation testing
- Include system-wide simulation capabilities
- Add projection testing tools (SimEarth-style but limited scope)

### 4. Background TerraSim Integration
- Confirm TerraSim runs as scheduled background jobs
- Remove manual triggers from admin interface
- Ensure automatic world updates during terraforming events

## Implementation Steps

### Phase 1: Remove Manual Controls
- Delete `run` and `run_all` actions from `Admin::SimulationController`
- Remove "Run Simulation" buttons from `admin/simulation/index.html.erb`
- Update view to show system status only

### Phase 2: Redirect Navigation
- Update admin dashboard link: `window.location.href='/admin/digital_twins'`
- Change button text to "🧬 Digital Twin Sandbox"
- Update any documentation references

### Phase 3: Enhance Digital Twins
- Add system-wide simulation controls to digital twin interface
- Implement projection testing capabilities
- Ensure isolated simulation environment

### Phase 4: Background Processing
- Verify TerraSim background job scheduling
- Remove manual simulation triggers
- Add monitoring for automatic updates

## Files to Modify
- `galaxy_game/app/controllers/admin/simulation_controller.rb` (remove run/run_all actions)
- `galaxy_game/app/views/admin/simulation/index.html.erb` (remove buttons, update interface)
- `galaxy_game/app/views/admin/dashboard/index.html.erb` (update navigation link)
- `galaxy_game/app/controllers/admin/digital_twins_controller.rb` (enhance if needed)
- `galaxy_game/app/views/admin/digital_twins/` (enhance interface)

## Acceptance Criteria
- Admin simulation page shows system status without manual controls
- Navigation redirects to digital twin sandbox
- Digital twins provide comprehensive simulation testing
- TerraSim runs automatically as background tasks
- No manual simulation triggers in admin interface

## Benefits
- Clear separation: background updates vs. testing/projections
- Better user experience for admins
- Consistent with Digital Twin purpose
- Removes error-prone manual controls

## Priority
Medium - Improves admin UX and removes broken functionality

## Estimated Effort
3-4 hours (controller updates + view changes + navigation updates)