# ARCHIVED: Fix Surface Map Tileset Integration

**Status:** Archived (2026-02-28)
**Reason:** Task references legacy FreeCiv/Civ4 tileset integration, which is now deprecated. GalaxyGame has pivoted to a JSON-based tileset system for all map and surface rendering. This task will not be completed in its current form.

## Original Overview
Implement functional Civilization-style strategic surface map view using FreeCiv tilesets with proper terrain-to-tile mapping and layer system.

## Archive Note
- FreeCiv/Civ4 asset pipelines and tilespec parsing are no longer supported.
- All new work uses the JSON-based tileset system (`galaxy_game_tileset.json`, `simple_tileset_loader.js`, `surface_view_optimized.js`).
- If needed, rewrite this task to align with the new system.
