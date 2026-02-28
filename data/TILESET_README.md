# GalaxyGame Tileset Sprite Sheet Instructions

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
