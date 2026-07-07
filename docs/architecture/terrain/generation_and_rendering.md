# Terrain Generation & Rendering Architecture
**Location:** `docs/architecture/terrain/generation_and_rendering.md`  
**Source:** Extracted from `docs/GUARDRAILS.md` Section 7.5 (lines 133-286) during GUARDRAILS consolidation, 2026-07-03

---

### Core Principle: Data Source Hierarchy

**NASA GeoTIFF = Ground Truth** for Sol bodies with real data.
**FreeCiv/Civ4 = Training Data** for AI Manager pattern learning, NOT direct terrain sources.
**AI Manager = Generator** for bodies without NASA data, using learned patterns + physical conditions.

### Separation of Concerns
- **Generation Layer:** Produces pure elevation data only (height maps). No biome classification.
- **Rendering Layer:** Applies visualization based on elevation and body properties.
- **Data Storage:** `geosphere.terrain_map` contains `elevation` (2D numeric grid) and metadata.

### Sol System Terrain Sources

| Body | NASA Data | Grid Size | Status |
|------|-----------|-----------|--------|
| Earth | `earth_1800x900.asc.gz` | 180×90 | ✅ Available |
| Mars | `mars_1800x900.asc.gz` | 96×48 | ✅ Available |
| Luna | `luna_1800x900.asc.gz` | 50×25 | ✅ Available |
| Mercury | `mercury_1800x900.asc.gz` | 70×35 | ✅ Available |
| Titan | None | 74×37 | ❌ AI Manager generates |
| Venus | None | 172×86 | ❌ AI Manager generates |

### Grid Sizing & FreeCiv Tileset Compatibility

**Key Distinction:**
- **Grid Size** (e.g., 180×90) = number of tiles in the map
- **Tile Pixel Size** (e.g., 30×30, 64×64) = rendering size of each tile sprite
- FreeCiv tilesets work with ANY grid size - they tile sprites across the grid

**Grid Formula:** Diameter-based, maintains 2:1 aspect ratio for cylindrical wrap:
```ruby
scale_factor = body_diameter / 12742.0  # Earth as reference
width = (180 * scale_factor).round.clamp(40, 720)
height = (width / 2).round.clamp(20, 360)  # Enforce 2:1 aspect ratio
```

**Available Tilesets:**
| Tileset | Tile Size | Notes |
|---------|-----------|-------|
| Trident (original) | 30×30 | Classic FreeCiv |
| Trident (modified) | 64×64 | Current default |
| BigTrident | 60×60 | Double-size |
| Engels | 45×45 | Community |

### FreeCiv/Civ4 as Training Data (NOT Direct Sources)

**What FreeCiv/Civ4 Maps Provide:**
- Geographic feature names and relative positions (Olympus Mons, Hellas Basin, etc.)
- Biome placement patterns for AI Manager learning
- Terraforming target visualization (what COULD exist after terraforming)
- Settlement viability hints and resource distribution patterns
- Geological feature checklist for data completeness validation

**What FreeCiv/Civ4 Maps Do NOT Provide:**
- Accurate elevation data (PlotType 0-3 is NOT real topography)
- Current planetary state (both show post-terraforming scenarios)
- Correct grid dimensions (sizes don't match our diameter-based grids)

**IMPORTANT:** Converting FreeCiv terrain types to elevation produces unrealistic results
(uniform 279-322m range instead of -8km to +21km for Mars). Always use NASA GeoTIFF.

### Terrain Data Integrity
- **Grid Content:** Never store biome letters/symbols in `terrain_map['grid']`. Use normalized elevation values (0.0-1.0).
- **Elevation Variation:** Must show realistic height variation (Mars: -8km to +21km, Earth: -10km to +8km).
- **NASA Source Files:** Located at `data/geotiff/processed/*.asc.gz`

### Hydrosphere Layer
- **Label:** "Hydrosphere" not "Water" (supports non-H2O liquids)
- **Color by Composition:** H2O=blue, CH4/C2H6=orange, NH3=purple
- **Bathtub Logic:** Fill from lowest elevation based on coverage percentage
- **Source:** `hydrosphere.liquid_name` attribute determines display

### Body-Specific Rendering
- **Luna:** Grey gradient (regolith)
- **Mars:** Rust-red gradient (iron oxide)
- **Mercury:** Dark grey gradient (basalt)
- **Titan:** Orange-brown gradient (tholin deposits)
- **Earth:** Brown-green gradient (varied biomes)

### Architecture Correction [2026-02-05]
- **Root Cause:** Monitor was loading FreeCiv/Civ4 data directly and converting terrain types to elevation
- **Impact:** Unrealistic elevation range (279-322m instead of real topography)
- **Fix Required:** Load NASA GeoTIFF data directly, use FreeCiv/Civ4 only for AI Manager training
- **Hydrosphere Fix:** `primary_liquid` method must check `liquid_name` attribute first

### No Fog of War — CRITICAL RULE [2026-03-03]

This is a space game. Orbital surveys give us the full terrain before landing.
FOG OF WAR MUST NEVER BE IMPLEMENTED. If any agent suggests it, reject it.

Scouting is NOT map revelation. Scouting is physical presence:
- Scout unit on tile reveals: exact deposit yield, mineral composition,
  subsurface features (lava tubes, ice pockets), precise habitability score
- Before scouting: tile shows orbital data — terrain, biome, estimated resources
- After scouting: tile shows full confirmed detail including yield quality

### Worldhouse — Regional Biosphere [2026-03-03]

BIOMES ARE NOT A PLANET-LEVEL BOOLEAN. They are regional.

Global biosphere: Full terraforming. Biomes cover entire surface. (Earth, fully terraformed Mars)

Regional biosphere — Worldhouse:
  Biomes exist ONLY within an enclosed habitat region.
  Rest of planet is bare geological terrain.
  Example: Enclose Valles Marineris under transparent panels.
  Inside the enclosure: jungle, grassland, city tiles visible.
  Outside: bare rust Mars regolith.

In terrain_data.biomes grid:
  biomes[y][x] = 'jungle'   <- inside worldhouse
  biomes[y][x] = nil        <- outside worldhouse, bare Mars
  biomes[y][x] = 'regolith' <- explicitly bare geological surface

Surface view renders sparse biome grids correctly.
Worldhouse boundary/panel outline = Civilisation layer, not Biome layer.

Through the worldhouse panels (Civ4 view) you see:
  - Strategic unit/tile layer on top
  - Biome tiles visible inside enclosure boundary
  - SimCity (TerrainForge) layer below for construction detail

### Desert = Dry Not Hot [2026-03-03]

Desert means LOW PRECIPITATION. Not high temperature.
Cold deserts are scientifically valid and exist in our solar system.

  desert / hot_desert   ->  golden sandy tan      ->  desert.png
  cold_desert           ->  pale grey-brown        ->  colour fallback (no tile yet)
  polar_desert          ->  pale grey-white        ->  tundra.png approximation

Future asset needed: cold_desert.png

### Geological Features Are Not Biomes [2026-03-03]

These are geological surface features, NOT biomes.
Never put them in biome colour maps or tile mappings.
They fall through to elevation base colour.

  crater, regolith, maria, mare, volcanic, lava,
  mountains, hills, peaks, ocean, coast, deep_sea

### Physical Properties Drive Rendering — Name Checks Forbidden [2026-03-03]

Never check planet name to determine rendering.

  Rust/red tint         ->  crust_iron_oxide_percentage > 10%
  Biomes allowed        ->  celestial_body.biosphere.present?
  Airless grey          ->  atmosphere.pressure < 0.001 or no atmosphere
  Volcanic scheme       ->  surface_temperature > 700 AND geological_activity > 80
  Methane liquid        ->  hydrosphere.liquid_type includes CH4 or C2H6
