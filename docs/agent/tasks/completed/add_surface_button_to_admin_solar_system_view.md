# Add Surface Button to Admin Solar System View

## Problem
The admin solar system show view (/admin/solar_systems/:id) displays celestial body 
cards with action buttons but is missing a Surface button despite the functionality 
existing at /admin/celestial_bodies/:id/surface.

## Current State
- Route exists: GET /admin/celestial_bodies/:id/surface
- Controller action exists: Admin::CelestialBodiesController#surface  
- View exists: app/views/admin/celestial_bodies/surface.html.erb
- UI shows "View Details" and "Monitor" buttons only

## Required Change
ONE change only. In app/views/admin/solar_systems/show.html.erb around line 240,
find the body-actions div. Add this block between "View Details" and "Monitor":

  <% if body.geosphere&.terrain_map.present? %>
    <button class="action-btn"
            onclick="window.location.href='/admin/celestial_bodies/<%= body.id %>/surface'">
      🗺️ Surface
    </button>
  <% end %>

The conditional is required — bodies without terrain data (gas giants, asteroids)
must not show the button as it would lead to a broken view.

## Button Order After Change
1. View Details
2. 🗺️ Surface  ← new, conditional on terrain data present
3. Monitor

## Verification
Run after change:
  grep -n "Surface\|terrain_map\|body-actions" app/views/admin/solar_systems/show.html.erb

Expected: Surface appears once, inside a terrain_map.present? guard.

## Testing
- Earth, Mars, Luna → Surface button visible
- Gas giants, asteroids → Surface button NOT visible
- Clicking button → navigates to /admin/celestial_bodies/:id/surface correctly

## Do Not
- Do not change any other buttons or layout
- Do not reformat the file
- Do not add Surface to any other view

## Priority: Medium
## Time Estimate: 10 minutes
## Assigned to: Gemini 3 Flash
```

---

## Handoff command
```
[BACKLOG] Add Surface button to admin solar system view.

FILE: app/views/admin/solar_systems/show.html.erb
LOCATION: Around line 240, inside the body-actions div

Add this ERB block between the "View Details" and "Monitor" buttons:

  <% if body.geosphere&.terrain_map.present? %>
    <button class="action-btn"
            onclick="window.location.href='/admin/celestial_bodies/<%= body.id %>/surface'">
      Surface
    </button>
  <% end %>

The terrain_map.present? guard is required — do not omit it.
Do not change anything else in the file.

Verify with:
  grep -n "Surface\|terrain_map\|body-actions" app/views/admin/solar_systems/show.html.erb

Expected: Surface button once, inside the guard. Done.