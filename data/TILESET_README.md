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

---

**Last updated:** 2026-02-28
