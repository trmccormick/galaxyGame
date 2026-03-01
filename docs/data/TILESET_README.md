# GalaxyGame Tileset Sprite Sheet Instructions

## Monitor View Layer Data Requirements

# Tileset System Pivot: FreeCiv → JSON-Based Tiles

**2026 Update:** GalaxyGame has pivoted away from FreeCiv tilespec parsing and legacy asset pipelines. All map rendering now uses a unified JSON-based tileset system for surface and monitor views.

### JSON Tileset Format Example

All new tilesets are defined in JSON. Example:

```json
{
  "name": "galaxy_game_base_terrain",
  "description": "Default base terrain tileset for GalaxyGame surface and monitor views.",
  "tile_size": 32,
  "sheets": {
    "base": {
      "file": "base_terrain.png",
      "tiles": {
        "ocean": { "x": 0, "y": 0 },
        "plains": { "x": 32, "y": 0 },
        "desert": { "x": 64, "y": 0 },
        "forest": { "x": 96, "y": 0 },
        "mountains": { "x": 128, "y": 0 },
        "tundra": { "x": 160, "y": 0 },
        "grasslands": { "x": 192, "y": 0 },
        "swamp": { "x": 224, "y": 0 },
        "jungle": { "x": 256, "y": 0 }
      }
    }
  }
}
```

See `data/galaxy_game_tileset.json` for the current template. Sprite sheets must match the tile size and layout defined in the JSON.

**Migration Status:**
- Loader logic (`simple_tileset_loader.js`) and rendering code are ready for JSON tilesets.
- Default backup colors are used until new sprite sheets are created and applied.
- Next: Create and integrate new sprite sheets for each terrain type.

### New Map Layer Data Requirements

- **Terrain:** Height map (2D elevation grid, width, height). No biomes or features unless biosphere is present.
- **Hydrosphere:** Bathtub fill logic, guided by hydrosphere mass and coverage percentage. Only for worlds with liquid coverage.
- **Biomes:** Only present for Earth or worlds with biosphere. Omitted for bare/airless worlds.
- **Features:** Major geological features only (craters, mountains, etc.), conditionally included for clarity.
- **Temp:** Surface temperature grid or average value.
- **Resources:** Resource placement from real data, AI generation, or artistic maps. Only if relevant.
- **Civilization:** Settlements, technology, or artificial structures. Only if present.

**Best Practice:**
- Backend must filter and send only the data needed for each layer, based on planet properties.
- Frontend (monitor.js, surface_view_optimized.js) checks for layer presence and only renders if data is available and relevant.
- Biomes and features are conditionally included, never defaulted.

**Tileset System:**
- All tilesets are defined in JSON (see `galaxy_game_tileset.json`).
- Sprite sheets are referenced directly; no .spec or tilespec parsing.
- Loader logic is handled by `simple_tileset_loader.js`.
- Rendering is optimized via viewport culling in `surface_view_optimized.js`.

**Migration Notes:**
- Legacy FreeCiv tilespec and .spec files are deprecated.
- All new worlds and surface views use the JSON tileset system for performance, maintainability, and extensibility.

This ensures the monitor view is efficient, accurate, and scientifically robust, avoiding unnecessary or misleading data for each world.

## Sprite Sheet Requirements
- Filename: `base_terrain.png`
- Location: Place in `data/` or the designated tileset asset directory
- Format: PNG, 32x32 pixel tiles (default)
- Layout: Each terrain type (ocean, plains, desert, forest, mountains, tundra, grasslands, swamp, jungle) should be a separate tile, arranged horizontally (see JSON config for x/y positions)
- Colors: Use clear, visually distinct colors for each terrain type
- Transparency: Supported (for overlays/features)

## Integration Steps
1. Create or export the sprite sheet image as `base_terrain.png`.
2. Place the image in the correct directory.
3. Update the JSON tileset config if you add new terrain types or change tile size/layout.
4. Reload the surface/monitor view to verify correct rendering.

## Expansion
- To add new terrain types, update both the sprite sheet and the JSON config.
- For variants (e.g., seasonal, artistic), create additional sheets and reference them in the JSON.

## Variant Naming & Multi-Sheet Integration
- For seasonal or artistic variants, use descriptive filenames (e.g., `base_terrain_winter.png`, `base_terrain_artistic.png`).
- Reference each sheet in the JSON config under the `sheets` section.
- Example JSON config for variants:

```json
{
  "name": "galaxy_game_base_terrain",
  "tile_size": 32,
  "sheets": {
    "base": {
      "file": "base_terrain.png",
      "tiles": { "ocean": { "x": 0, "y": 0 }, ... }
    },
    "winter": {
      "file": "base_terrain_winter.png",
      "tiles": { "ocean": { "x": 0, "y": 0 }, ... }
    },
    "artistic": {
      "file": "base_terrain_artistic.png",
      "tiles": { "ocean": { "x": 0, "y": 0 }, ... }
    }
  }
}
```

- Update loader logic to select the appropriate sheet based on user or world settings.
- Document any new terrain types or variants in this README for team reference.

## Tileset Update Checklist
- [ ] Create new terrain tile(s) in your sprite sheet (PNG)
- [ ] Add new terrain type(s) to the JSON config under the appropriate sheet
- [ ] For variants, create and name new sheets/files, then reference in JSON
- [ ] Reload the surface/monitor view and verify correct rendering
- [ ] Update this README with new terrain types/variants
- [ ] Run all relevant tests (JS rendering, RSpec if backend changes)
- [ ] Commit changes atomically (asset + config + docs)
- [ ] Push to remote and update status documentation

## Project Status & Task Management
- After completing any tileset update, always:
  - Update `docs/CURRENT_STATUS.md` with a summary of changes and next steps
  - Move completed task files to `/docs/agent/tasks/completed/` if applicable
  - Follow atomic commit and push protocol for all changes

## Testing & Validation
- Always reload the map view after asset/config changes to confirm correct tile rendering
- If adding backend logic, run RSpec tests in Docker as per project protocol
- Document any issues or fixes in CURRENT_STATUS.md

---

**Last updated:** 2026-02-28
