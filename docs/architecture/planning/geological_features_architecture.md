# Geological Features System — Design Intent & History
**Date**: March 4, 2026
**Status**: Partially implemented — core models exist, AI integration deferred

## Origin
The geological features project started by pulling real data from Wikipedia for 
Mars and Luna — specifically scraping/importing:
- **Craters** — named craters with location, size, and characteristics
- **Lava Tubes** — known lava tube systems suitable for habitation

## Strategic Purpose
Features are not just map decoration — they are **strategic settlement assets**:

### Lava Tubes
- Primary initial settlement location for Luna and Mars
- Natural radiation shielding, thermal stability, structural integrity
- AI Manager evaluates lava tubes as first foothold candidates
- Settlement can encompass multiple connected lava tube sections
- `LavaTube` model already has: conversion_suitability, suitability_rating, 
  estimated_cost_multiplier, can_pressurize?, natural_shielding, thermal_stability

### Craters
- Large craters can be enclosed with a dome (crater dome settlement)
- Existing `CraterDomeConstructionService` handles this pattern
- Smaller craters useful for resource extraction, not habitation
- AI Manager should prefer lava tubes over craters for initial settlement

## Settlement Model Evolution
Originally features were individual settlement sites. The model evolved to:
- A settlement can **include multiple lava tubes** as part of its footprint
- The lava tube IS the settlement container, not just a nearby feature
- This pattern applies to all Sol system bodies with known lava tube data

## Sol System vs Generated Worlds

### Sol System Bodies (real data)
- Luna: Wikipedia lava tube and crater data imported
- Mars: Wikipedia crater and lava tube data imported  
- Other Sol bodies: import as data becomes available
- Data lives in `CelestialBodies::Features::` models with real coordinates

### Generated/Exoplanet Worlds (future work)
- No real data available — features must be **procedurally generated**
- Need procedural generator for lava tubes, craters, canyons based on:
  - Planet type (rocky, volcanic, ancient, etc.)
  - Geological age and activity level
  - Size and gravity
- This is **future work** — not yet implemented
- TerraSim is the likely integration point for procedural feature generation

## Surface Map — Tile-Based Gameplay (IMPORTANT)
The surface view is a **Civ4-style tile map**, not just a visual display. Geological 
features are tile-level gameplay data — they occupy specific tiles on the map and 
drive player and AI decisions.

### Features as Tiles
- **Lava Tube** — occupies a region of tiles on the surface map
  - Heavy lift launcher lands on adjacent tile
  - Settlement construction converts the lava tube tiles
  - Connected tube sections extend the settlement footprint
- **Crater** — occupies a circular region of tiles
  - Dome construction encloses the crater tile region
  - Rim tiles are construction sites for dome anchors
  - Interior tiles become pressurized settlement space
- **Cave, Canyon, Valley** — occupy tile regions with strategic value
  - Resource extraction, shelter, natural infrastructure

### Controller Assignment Required
The surface action MUST assign `@geological_features` for the tile map renderer.
The spec expectation is CORRECT and should NOT be removed.

Correct implementation pattern (mirror the planetary action):
```ruby
# In Admin::CelestialBodiesController#surface
@geological_features = Lookup::PlanetaryGeologicalFeatureLookupService
  .new(@celestial_body).fetch_features rescue []
```

### ⚠️ Do Not Remove Surface Spec Expectation
The `assigns(:geological_features)` expectation in 
`spec/controllers/admin/celestial_bodies_controller_spec.rb` for the 
surface action is CORRECT. It was nearly removed in error. The fix is 
to implement the controller assignment, not remove the spec.

### Monitor vs Surface — Key Distinction
- **Monitor view** — sphere status overview, no tile map, features NOT needed
- **Surface view** — Civ4-style tile map, features ARE needed as tile data
- Specs for monitor: remove @geological_features expectation (done ✅)
- Specs for surface: implement @geological_features assignment in controller


- Attempted plotting all features as markers on monitor map
- Luna experiment: too many craters = map covered in yellow dots, unusable
- Future approach: selective labeling of significant/named features only
- Toggle-able layer, filtered by feature priority/strategic_value fields
- See: geological_features_monitor_intent.md for display design intent

## AI Manager Integration Intent
AI Manager should use features for:
1. **Settlement site selection** — prefer lava tubes for initial foothold
2. **Expansion planning** — identify connected tube systems for growth
3. **Dome construction** — evaluate craters for dome enclosure viability
4. **Resource assessment** — caves and valleys for mining operations
5. **Risk assessment** — avoid unstable geological features

## Related Files
- `app/models/celestial_bodies/features/` — all feature models
  - `lava_tube.rb` — primary settlement container
  - `crater.rb` — dome enclosure candidate
  - `cave.rb`, `canyon.rb`, `valley.rb`, `skylight.rb` — secondary features
  - `base_feature.rb` — shared behavior
- `app/services/lookup/planetary_geological_feature_lookup_service.rb`
- `app/services/crater_dome_construction_service.rb`
- `app/controllers/admin/celestial_bodies_controller.rb` — planetary action example

## Next Steps When Prioritized
1. Connect AI Manager settlement site selection to lava tube features
2. Build procedural feature generator for generated worlds (TerraSim integration)
3. Implement selective feature labeling on monitor map
4. Add feature-based settlement expansion logic
