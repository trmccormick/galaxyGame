# Galaxy Game: Planetary Map System

## Overview

The Galaxy Game planetary map system provides a SimEarth-style visualization of celestial bodies using FreeCiv tilesets and real elevation data. The system supports layered rendering with geological, hydrological, biological, and infrastructural overlays.

## Architecture

### Data Sources

#### FreeCiv SAV Files
- **Format**: Character-based terrain grids (a=arctic, d=desert, g=grassland, etc.)
- **Source**: FreeCiv scenario files or custom generated maps
- **Use Case**: Game-optimized terrain for strategy gameplay

#### Real Elevation Data
- **Sources**:
  - NASA SRTM/ETOPO (Earth topography)
  - NASA MOLA (Mars topography)
  - NASA LOLA (Luna topography)
  - NASA Magellan (Venus topography)
- **Format**: GeoTIFF or converted elevation arrays
- **Use Case**: Scientific accuracy for Sol system planets

### Layered Rendering System

#### Layer 0: Lithosphere (Geological Base)
- **Data**: terrain_type (FreeCiv classification)
- **Visual**: Base tiles from FreeCiv tilesets
- **Color Filters**:
  - Mars: Oxide red tint (#B7410E)
  - Venus: Sulfur yellow tint (#E3BB76)
  - Luna: Regolith gray tint (#A9A9A9)
  - Titan: Methane haze tint (#F8D664)

#### Layer 1: Hydrosphere (Water/Ice)
- **Data**: Liquid water, ice caps, methane lakes
- **Visual**: Blue/cyan overlays on base tiles
- **Dynamic**: Changes with terraforming progress

#### Layer 2: Biosphere (Life/Vegetation)
- **Data**: bio_density (0.0 to 1.0 scale)
- **Visual**: Green transparency overlays
- **Behavior**: Gradual expansion, not binary switches
- **Implementation**: Alpha channel overlays on base tiles

#### Layer 3: Infrastructure (Stations/Depots)
- **Data**: Station locations, depot networks, L1 links
- **Visual**: Industrial sprites overlaid on terrain
- **Logic**: Luna Pattern resource harvesting, Super-Mars asteroid stations

### Database Schema

```ruby
# CelestialBody.geosphere.terrain_map
{
  grid: [
    [
      {
        type: 'desert',           # FreeCiv terrain classification
        elevation: 234,           # Real elevation in meters
        bio_density: 0.3,         # Life coverage (0-1)
        infrastructure: nil       # Station/depot data
      }
    ]
  ],
  width: 200,
  height: 100,
  source: 'freeciv_import',     # or 'elevation_import'
  planet_type: 'mars',          # For rendering filters
  map_metadata: {
    resolution: '200x100',
    projection: 'equirectangular',
    source_data: 'NASA_MOLA_2026'
  }
}
```

## Services

### FreecivSavImportService
- **Purpose**: Parse FreeCiv .sav files into terrain grids
- **Input**: .sav file path
- **Output**: 2D terrain character array + biome counts
- **Location**: `app/services/import/freeciv_sav_import_service.rb`

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

### ElevationImportService (Planned)
- **Purpose**: Convert NASA elevation data to terrain grids
- **Input**: GeoTIFF files or elevation arrays
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

### Layer Controls (SimEarth-Style)
- **Implementation**: Complete color replacement system (not transparency overlays)
- **Behavior**: When enabled, layers replace base terrain colors for specific terrain types
- **State Management**: JavaScript Set tracks visible layers, triggers canvas re-rendering

**Available Layers:**
- **Water (Blue)**: Ocean, deep_sea → #0088FF (bright blue)
- **Biomes (Green)**: Forest, jungle, grasslands, plains, swamp → #00FF00 (bright green for vegetation/fertile land)
- **Features (Brown)**: Boreal (hills), mountains, rock → #8B4513 (saddle brown for geological features)
- **Temperature (White)**: Arctic, tundra → #FFFFFF (white for extreme cold climates)
- **Resources (Gold)**: Rock, desert (mineral-rich/arid terrain) → #FFD700 (gold for resource potential)

**Technical Details:**
- Layer visibility stored in `visibleLayers` Set
- `layerOverlays` object maps terrain types to layer colors
- `toggleLayer()` function manages state and UI updates
- `renderTerrainMap()` checks enabled layers before applying base colors

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

1. **Terrain Data Updates**: When importing new maps or modifying terrain, update the CelestialBody JSON with new terrain_map data
2. **Service Changes**: Document any changes to import/conversion services in this file
3. **UI Modifications**: Update layer control documentation when adding new toggles
4. **Asset Additions**: Document new tilesets or elevation datasets added to the system

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