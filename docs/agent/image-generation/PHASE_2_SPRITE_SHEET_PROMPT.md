# Sprite Sheet Generation Prompt for Phase 2 Regional View

## AI Sprite Sheet Generation Request

**Project:** Galaxy Game - Phase 2 Regional View Terrain Sprites

**Output Required:** galaxy_surface.png - 288x32 pixel sprite atlas (9 terrain types × 32px sprites)

**Style Reference:** Civilization 4 terrain tiles - clean, recognizable, game-appropriate

**Terrain Types Required (left to right):**

1. **Ocean** (x: 0-31) - Deep blue water with subtle wave patterns
2. **Plains** (x: 32-63) - Golden yellow grassland with subtle texture
3. **Desert** (x: 64-95) - Sandy beige with dune-like ripples
4. **Forest** (x: 96-127) - Dense green forest with tree silhouettes
5. **Mountains** (x: 128-159) - Rugged gray peaks with snow caps
6. **Tundra** (x: 160-191) - Frozen white/blue with ice patterns
7. **Grasslands** (x: 192-223) - Lush green with grass texture
8. **Swamp** (x: 224-255) - Murky green/brown with reed details
9. **Jungle** (x: 256-287) - Vibrant green with dense vegetation

**Technical Specifications:**
- **Dimensions:** 288×32 pixels (9×32px tiles in a row)
- **Format:** PNG with transparency support
- **Color Palette:** Game-appropriate, not photorealistic
- **Style:** Pixel art / sprite art suitable for 100m/pixel regional view
- **Consistency:** All tiles should have similar visual weight and detail level

**Usage Context:**
- Will be mapped from NASA biome data to create regional terrain view
- Used in 16K canvas (16384×8192) at 100m/pixel resolution
- Should work well when tiled and zoomed

**Additional Notes:**
- Each 32×32 tile represents ~100m×100m of terrain
- Design for readability at various zoom levels
- Include subtle texture but avoid overly detailed elements that won't scale well