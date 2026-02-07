# Galaxy Game: Planetary Map System

## Overview

The Galaxy Game planetary map system provides a SimEarth-style visualization of celestial bodies using FreeCiv tilesets and NASA elevation data. The system supports layered rendering with geological, hydrological, biological, and infrastructural overlays.

## Architecture

### Data Source Hierarchy [Updated 2026-02-05]

```
┌─────────────────────────────────────────────────────────────────┐
│                    TERRAIN DATA SOURCES                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  PRIMARY (Ground Truth):                                         │
│  └─ NASA GeoTIFF data at data/geotiff/processed/*.asc.gz        │
│     - earth_1800x900.asc.gz                                      │
│     - mars_1800x900.asc.gz                                       │
│     - luna_1800x900.asc.gz                                       │
│     - mercury_1800x900.asc.gz                                    │
│                                                                  │
│  TRAINING DATA (AI Manager Learning):                            │
│  └─ FreeCiv/Civ4 maps at data/maps/                             │
│     - Biome placement patterns                                   │
│     - Geographic feature names & positions                       │
│     - Settlement location hints                                  │
│     - NOT for elevation (produces unrealistic 279-322m range)   │
│                                                                  │
│  GENERATED (Bodies Without NASA Data):                           │
│  └─ AI Manager uses learned patterns + physical conditions       │
│     - Titan, Europa, Venus, etc.                                │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Layered Rendering System

#### Layer 0: Lithosphere (Terrain Base)
- **Data Source**: NASA GeoTIFF elevation (downsampled to grid)
- **Visual**: Height-based color gradient
- **Body-Specific Colors**:
  - Luna: Grey gradient (#4a4a4a → #d0d0d0)
  - Mars: Rust gradient (#654321 → #cd853f)
  - Mercury: Dark grey (#3a3a3a → #a9a9a9)
  - Titan: Orange-brown (#8B4513 → #DEB887)
  - Earth: Brown-green (#006400 → #ffffff)

#### Layer 1: Hydrosphere (Liquid/Ice)
- **Data Source**: hydrosphere.water_coverage + elevation (bathtub logic)
- **Label**: "Hydrosphere" not "Water" (supports non-H2O)
- **Color by Composition**:
  - H2O: Blue (#0077be)
  - CH4/C2H6 (Titan): Orange (#ff6600)
  - NH3: Purple (#9370db)
- **Dynamic**: Changes with terraforming progress

#### Layer 2: Biosphere (Life/Vegetation)
- **Data**: bio_density (0.0 to 1.0 scale)
- **Visual**: Green transparency overlays
- **Behavior**: Gradual expansion, not binary switches
- **Note**: Only for habitable zone worlds

#### Layer 3: Infrastructure (Stations/Depots)
- **Data**: Station locations, depot networks, L1 links
- **Visual**: Industrial sprites overlaid on terrain
- **Logic**: Luna Pattern resource harvesting, Super-Mars asteroid stations

### Grid Sizing & FreeCiv Tileset Compatibility

#### Key Concepts

**Grid Dimensions vs Tile Pixel Size:**
- **Grid Size** (e.g., 180×90) = number of tiles in the map (width × height)
- **Tile Pixel Size** (e.g., 30×30, 45×45, 64×64) = how big each tile is rendered in pixels
- FreeCiv tilesets work with ANY grid size - they just repeat sprites across the grid

**FreeCiv Constraints:**
1. **Aspect Ratio**: 2:1 (width:height) for proper cylindrical wrap (WRAPX topology)
2. **Minimum Playable**: ~40×20 for meaningful gameplay
3. **Tile Pixel Size**: Must match chosen tileset specification

#### Available Tilesets

| Tileset | Tile Size (px) | Style | Notes |
|---------|---------------|-------|-------|
| Trident (original) | 30×30 | Classic | Original FreeCiv look |
| Trident (modified) | 64×64 | Classic | Our current version |
| BigTrident | 60×60 | Classic | Double-size Trident |
| Engels | 45×45 | Stylized | Community tileset |
| Amplio | 96×96 | Detailed | High-res isometric |

#### Grid Size Formula

```ruby
# Formula: Earth 180×90 as reference, maintains 2:1 aspect ratio
scale_factor = body_diameter / 12742.0  # Earth diameter in km
width = (180 * scale_factor).round.clamp(40, 720)
height = (width / 2).round.clamp(20, 360)  # Enforce 2:1 ratio
```

| Body | Diameter (km) | Grid Size | FreeCiv Map Reference |
|------|---------------|-----------|----------------------|
| Earth | 12,742 | 180×90 | earth-180x90-v1-3.sav ✓ |
| Mars | 6,779 | 96×48 | mars-133x64-v2.0.sav (terraformed) |
| Luna | 3,474 | 50×25 | - |
| Titan | 5,150 | 74×37 | - |
| Mercury | 4,879 | 70×35 | - |

**Note:** FreeCiv Mars (133×64) is a terraformed future state map, not sized by diameter. Our sizing reflects current actual body surface area proportionally.

#### Canvas Size Calculation

```javascript
// Total canvas size = grid × tile pixel size
const canvasWidth = gridWidth * tileSizePixels;   // e.g., 180 × 64 = 11,520px
const canvasHeight = gridHeight * tileSizePixels; // e.g., 90 × 64 = 5,760px
```

For standard Trident (64×64):
- Earth 180×90: 11,520 × 5,760 pixels
- Mars 96×48: 6,144 × 3,072 pixels
- Luna 50×25: 3,200 × 1,600 pixels

### Database Schema

```ruby
# CelestialBody.geosphere.terrain_map
{
  elevation: [[0.2, 0.3, 0.1], ...],  # 2D float array (normalized 0-1)
  generation_metadata: {
    nasa_source: "mars_1800x900.asc.gz",
    generated_at: "2026-02-05T10:30:00Z",
    method: "nasa_geotiff"  # or "ai_manager_generated"
  },
  width: 96,
  height: 48
}
```

## Services

### MapLayerService
- **Purpose**: Unified interface for processing Civ4 and FreeCiv maps into elevation/terrain/biome layers
- **Input**: .sav file path, processing method (civ4 or freeciv)
- **Output**: Normalized elevation grid (0-1), terrain types, biome data stored in JSONB
- **Location**: `app/services/map_layer_service.rb`
- **Methods**:
  - `process_civ4_map(file_path)`: Extract elevation from Civ4 PlotType data
  - `process_freeciv_map(file_path)`: Generate biome-constrained elevation
  - `store_in_geosphere(geosphere, elevation, terrain, biomes, quality, method)`: Save to database

### FreecivSavImportService
- **Purpose**: Parse FreeCiv .sav files into terrain grids
- **Input**: .sav file path
- **Output**: 2D terrain character array + biome counts
- **Location**: `app/services/import/freeciv_sav_import_service.rb`

### Civ4WbsImportService
- **Purpose**: Parse Civ4 .sav files for PlotType elevation data
- **Input**: .sav file path
- **Output**: 2D PlotType grid (0-3 elevation levels)
- **Location**: `app/services/import/civ4_wbs_import_service.rb`

### FreecivElevationGenerator
- **Purpose**: Generate elevation data constrained by FreeCiv biome types
- **Input**: Biome grid from FreeCiv import
- **Output**: 2D elevation array (0-1 normalized) within biome-appropriate ranges
- **Location**: `app/services/import/freeciv_elevation_generator.rb`

### Civ4ElevationExtractor
- **Purpose**: Extract elevation from Civ4 PlotType data (70-80% accuracy)
- **Input**: PlotType grid from Civ4 import
- **Output**: 2D elevation array (0-1 normalized) from discrete PlotType levels
- **Location**: `app/services/import/civ4_elevation_extractor.rb`

### FreecivToGalaxyConverter
- **Purpose**: Convert terrain data to planetary characteristics
- **Input**: Terrain grid from import service
- **Output**: Atmosphere, hydrosphere, temperature estimates
- **Location**: `app/services/import/freeciv_to_galaxy_converter.rb`

### FreecivTilesetService
- **Purpose**: Load and manage FreeCiv tileset assets
- **Input**: Tileset name (trident, amplio)
- **Output**: Tile image data and coordinates
- **Location**: `app/services/tileset/freeciv_tileset_service.rb`

### ElevationImportService (Future - NASA Data)
- **Purpose**: Convert NASA elevation data to terrain grids
- **Input**: GeoTIFF files or elevation arrays from SRTM/MOLA/LOLA/Magellan
- **Output**: Terrain classification based on elevation thresholds
- **Location**: `app/services/import/elevation_import_service.rb`

## UI Components

### Admin Monitor Canvas
- **Location**: `app/views/admin/celestial_bodies/monitor.html.erb`
- **Features**:
  - Tile-based rendering with FreeCiv sprites
  - Layer toggles (terrain, biosphere, infrastructure)
  - Interactive tooltips showing tile data
  - Zoom controls and grid overlays

### Layer Controls (SimEarth-Style with Elevation)
- **Terrain Layer**: Elevation-based gray scale base layer (always active)
  - Provides elevation context for all terrains
  - Cannot be turned off - serves as foundation for other layers
- **Overlay Layers**: Color overlays on elevation base
  - Water, biomes, features, temperature, resources overlay their specific colors
  - Only terrains matching active layers show overlay colors
  - Non-matching terrains keep elevation gray scale
  - Multiple layers can be combined for complex analysis

**Available Layers:**
- **Terrain (Gray Scale Base)**: Elevation-based visualization - darker = lower elevation, lighter = higher elevation
  - Always visible foundation layer
  - Other layers paint over this elevation base
- **Water (Blue Overlay)**: Ocean (#0088FF), deep_sea (#004488) → Blue highlights on elevation
- **Biomes (Green/Yellow Overlay)**: Forest/jungle (#00FF00/#00DD00), grasslands/plains (#88FF88/#AAFFAA), swamp (#66AA66), boreal (#448844), arctic (#FFFFFF), desert (climate-based: warm #FFDD44 yellow, cold #FFEEBB beige) → Green spectrum for vegetation, yellow/beige for arid, white for cryosphere
- **Features (Brown/Gray Overlay)**: Rock (#696969) → Geological highlights on elevation
- **Temperature (Red/Blue Overlay)**: Desert (#FF6600 red-orange hot), rock (#0088FF blue cold) → SimEarth-style temperature indicators
- **Rainfall (Blue/Yellow Overlay)**: Jungle/swamp (#0066FF/#0044FF dark blue high rainfall), forest/boreal (#4488FF/#88AAFF medium blue moderate), desert (#FFFF00 yellow low rainfall) → Precipitation levels
- **Resources (Gold Overlay)**: Rock/desert (#FFD700/#DAA520) → Mineral highlights on elevation

**Technical Details:**
- Layer visibility stored in `visibleLayers` Set (terrain always included)
- `layerOverlays` object maps terrain types to overlay colors
- `toggleLayer()` manages overlay state (terrain cannot be toggled)
- `renderTerrainMap()` applies elevation base, then overlays matching layer colors

### Tileset Assets
- **Location**: `public/tilesets/`
- **Structure**:
  ```
  public/tilesets/
  ├── trident/
  │   ├── trident.tilespec
  │   ├── terrain1.png
  │   ├── terrain1.spec
  │   └── ...
  └── amplio/
      ├── amplio.tilespec
      ├── terrain1.png
      └── ...
  ```

## Implementation Phases

### Phase 1: Basic FreeCiv Rendering
**Goal**: Fix black canvas, show tiles
**Status**: In Progress
**Tasks**:
- [ ] Copy tilesets to `public/tilesets/`
- [ ] Add terrain_map JSONB column to geospheres
- [ ] Import sample Earth/Mars SAV data
- [ ] Update monitor.html.erb to render tiles
- [ ] Test canvas displays terrain

### Phase 2: Real Elevation Integration
**Goal**: Add scientific data for Sol system
**Status**: Planned
**Tasks**:
- [ ] Create ElevationImportService
- [ ] Download NASA elevation datasets
- [ ] Convert elevation to terrain classifications
- [ ] Add planet-specific color filters
- [ ] Store elevation metadata

### Phase 3: Biosphere Layering
**Goal**: Dynamic vegetation expansion
**Status**: Planned
**Tasks**:
- [ ] Add bio_density to terrain_map schema
- [ ] Implement biosphere overlay rendering
- [ ] Create life expansion algorithms
- [ ] Add biosphere layer toggle

### Phase 4: Infrastructure System
**Goal**: Stations, depots, logistics
**Status**: Planned
**Tasks**:
- [ ] Add infrastructure data to terrain_map
- [ ] Implement Luna Pattern depot placement
- [ ] Add Super-Mars asteroid station logic
- [ ] Connect to AI manager logistics

## Terrain Classifications

### FreeCiv Mappings
| Character | Terrain Type | Description |
|-----------|-------------|-------------|
| a | arctic | Ice/snow covered |
| d | desert | Arid, sandy terrain |
| p | plains | Grassland, open terrain |
| g | grassland | Fertile grassland |
| f | forest | Wooded areas |
| j | jungle | Dense tropical vegetation |
| h | hills | Elevated terrain |
| m | mountains | High mountain peaks |
| s | swamp | Wet, marshy areas |
| o | ocean | Salt water bodies |
| - | deep_sea | Deep ocean trenches |

### Elevation Thresholds (Real Data)
| Elevation Range | Terrain Classification |
|----------------|------------------------|
| < -200m | deep_sea |
| -200m to 0m | ocean |
| 0m to 200m | plains |
| 200m to 500m | grassland |
| 500m to 1000m | hills |
| 1000m to 2000m | mountains |
| > 2000m | high_mountains |

## Color Filters by Planet

### Mars (Oxide Red Theme)
- Base tiles: Red-tinted desert variations
- Rock formations: Dark red/brown
- Polar ice: White with red dust overlay
- CSS Filter: `hue-rotate(-20deg) saturate(1.2)`

### Venus (Sulfur Yellow Theme)
- Base tiles: Yellow-tinted plains/desert
- Volcanic features: Orange-red highlights
- Atmospheric haze: Semi-transparent yellow overlay
- CSS Filter: `hue-rotate(45deg) brightness(1.1)`

### Luna (Regolith Gray Theme)
- Base tiles: Grayscale desert/plains
- Crater features: Dark gray shadows
- Highlands: Light gray elevations
- CSS Filter: `grayscale(100%) contrast(1.2)`

### Titan (Methane Haze Theme)
- Base tiles: Yellow-tinted swamp/plains
- Lake features: Dark amber liquid overlays
- Atmospheric scattering: Soft blur effects
- CSS Filter: `hue-rotate(35deg) brightness(1.2) blur(0.5px)`

## Documentation Mandate

**All map system changes must update documentation:**

1. **Terrain Data Storage**: Terrain maps are stored in `geosphere.terrain_map` JSONB field. The controller automatically creates a geosphere if one doesn't exist during terrain import to ensure data persistence.
2. **Terrain Data Updates**: When importing new maps or modifying terrain, update the CelestialBody's geosphere with new terrain_map data
3. **Service Changes**: Document any changes to import/conversion services in this file
4. **UI Modifications**: Update layer control documentation when adding new toggles
5. **Asset Additions**: Document new tilesets or elevation datasets added to the system

## Testing Requirements

### Unit Tests
- [ ] FreecivSavImportService parses .sav files correctly
- [ ] FreecivToGalaxyConverter generates valid planetary data
- [ ] FreecivTilesetService loads tileset assets
- [ ] Terrain classification algorithms work for elevation data

### Integration Tests
- [ ] Full import pipeline (SAV → terrain_map → rendering)
- [ ] Canvas rendering displays correct tiles
- [ ] Layer toggles show/hide appropriate elements
- [ ] Color filters apply correctly by planet type

### Performance Tests
- [ ] Large terrain grids (200x100) render within 100ms
- [ ] Tileset loading doesn't block UI
- [ ] Memory usage stays under 50MB for typical maps

## Dependencies

- **FreeCiv Tilesets**: GPL v2+ licensed, stored in `public/tilesets/`
- **NASA Elevation Data**: Public domain, converted via ElevationImportService
- **Canvas API**: HTML5 canvas for tile rendering
- **JSONB Storage**: PostgreSQL JSONB for flexible terrain data

## Future Enhancements

- **3D Rendering**: WebGL implementation for orbital views
- **Animation**: Terraforming progress animations
- **Multiplayer**: Shared map state synchronization
- **Custom Tilesets**: User-generated planet themes
- **Real-time Updates**: Live terraforming visualization

## References

- [FreeCiv Project](https://www.freeciv.org)
- [NASA Planetary Data](https://pds.nasa.gov)
- [SimEarth (1990) Gameplay](https://en.wikipedia.org/wiki/SimEarth)
- [Original Java Implementation](docs/developer/claude_notes.md)</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/developer/MAP_SYSTEM.md