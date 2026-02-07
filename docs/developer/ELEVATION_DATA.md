# Elevation Data Integration

## Overview

Galaxy Game uses **NASA GeoTIFF data as the primary source** for Sol system terrain elevation. FreeCiv and Civ4 map data serve as **training data for the AI Manager** to learn biome placement patterns, geographic feature locations, and settlement viability—but are NOT used directly for elevation.

## Architecture Correction [2026-02-05]

### Previous (Incorrect) Approach
- Converting FreeCiv terrain characters to elevation values
- Converting Civ4 PlotType (0-3) to elevation
- **Problem:** Produces unrealistic uniform elevation (279-322m range)

### Current (Correct) Approach
- **NASA GeoTIFF** = Ground truth elevation for Sol bodies
- **FreeCiv/Civ4** = Training data only (biome patterns, feature names, settlement hints)
- **AI Manager** = Generates terrain for bodies without NASA data

## Data Sources

### NASA GeoTIFF (Primary Elevation Source)
**Location:** `data/geotiff/processed/`

| File | Body | Resolution | Elevation Range |
|------|------|------------|-----------------|
| `earth_1800x900.asc.gz` | Earth | 1800×900 | -10,994m to +8,848m |
| `mars_1800x900.asc.gz` | Mars | 1800×900 | -8,200m to +21,229m |
| `luna_1800x900.asc.gz` | Luna | 1800×900 | -9,000m to +10,786m |
| `mercury_1800x900.asc.gz` | Mercury | 1800×900 | -5,380m to +4,480m |

### FreeCiv Maps (Training Data Only)
**Location:** `data/maps/freeciv/`

| File | Body | Grid | Use |
|------|------|------|-----|
| `earth-180x90-v1-3.sav` | Earth | 180×90 | Biome patterns, continent shapes |
| `mars-terraformed-133x64-v2.0.sav` | Mars | 133×64 | Terraforming targets, future state |

**FreeCiv Terrain Character Mapping (for pattern learning):**
| Char | Terrain | AI Manager Learning |
|------|---------|---------------------|
| `a` | Arctic | Polar region patterns |
| `d` | Desert | Arid zone distribution |
| `g` | Grassland | Habitable zone patterns |
| `p` | Plains | Lowland placement |
| `h` | Hills | Elevated terrain patterns |
| `m` | Mountains | Peak placement |
| `:` | Deep Ocean | Basin filling patterns |
| ` ` | Ocean | Water body shapes |

### Civ4 Maps (Training Data Only)
**Location:** `data/maps/civ4/`

| File | Body | Grid | Use |
|------|------|------|-----|
| `Earth.Civ4WorldBuilderSave` | Earth | 124×68 | Feature labels, resources |
| `MARS1.22b.Civ4WorldBuilderSave` | Mars | 80×57 | Feature labels (30), resources |

**Civ4 PlotType (NOT for elevation):**
- PlotType 0-3 are gameplay classifications, NOT topographic data
- Use for: land/water separation patterns, hill/flat distribution

## Implementation

#### Ocean/Sea Classification
| Elevation Range | Terrain Type | Description |
|----------------|-------------|-------------|
| 0.0-0.2 | deep_sea | Ocean trenches, deep basins |
| 0.2-0.4 | ocean | Continental shelves, coastal waters |

#### Land Classification
| Elevation Range | Terrain Type | Description |
|----------------|-------------|-------------|
| 0.4-0.6 | plains | Coastal plains, lowlands |
| 0.6-0.7 | grassland | Rolling hills, prairies |
| 0.7-0.8 | hills | Elevated terrain |
| 0.8-0.9 | mountains | Mountain ranges |
| 0.9-1.0 | high_mountains | Major peaks, extreme elevations |

### Planet-Specific Adjustments

#### Earth (FreeCiv + Civ4 Hybrid)
- **Source**: earth-180x90-v1-3.sav (FreeCiv) + Civ4 elevation extraction
- **Resolution**: 180x90 grid
- **Method**: Civ4 PlotType extraction for scientific accuracy
- **Features**: Realistic continental shapes, ocean basins, mountain ranges

#### Mars (FreeCiv Generation)
- **Source**: mars-terraformed-133x64-v2.0.sav (FreeCiv)
- **Resolution**: 133x64 grid
- **Method**: Biome-constrained random generation
- **Features**: Terraformed regions, polar ice caps, volcanic features

## UI Visualization

### Monitor View Integration
**Location**: `app/views/admin/celestial_bodies/monitor.html.erb`

**Key Features**:
- **Canvas Rendering**: JavaScript-based terrain visualization
- **Elevation Coloring**: Height-based color gradients (blue→green→brown→white)
- **Layer Overlays**: Terrain, biomes, and elevation data display
- **Interactive Controls**: Zoom, pan, layer toggling

### Elevation Data Access
```javascript
// Corrected implementation in monitor.html.erb
function calculateElevation(x, y) {
  const elevation = terrainMap.elevation[y][x];  // Already 0-1 normalized
  return elevation;  // No re-normalization needed
}
```

### Color Mapping
```javascript
function getElevationColor(elevation) {
  if (elevation < 0.4) return '#1e3a8a';      // Deep blue (ocean)
  if (elevation < 0.6) return '#16a34a';      // Green (plains)
  if (elevation < 0.8) return '#ca8a04';      // Yellow-brown (hills)
  if (elevation < 0.9) return '#9a3412';      // Brown (mountains)
  return '#f8fafc';                           // White (peaks)
}
```

## Performance Considerations

### Processing Performance
- **Map Loading**: 2-5 seconds for typical FreeCiv files
- **Elevation Generation**: <1 second for 200x100 grids
- **Storage**: JSONB compression reduces size by 60-80%

### Rendering Performance
- **Canvas Drawing**: 60fps with 200x100 resolution
- **Memory Usage**: <50MB for elevation/terrain/biomes data
- **Progressive Rendering**: Grid-based drawing prevents UI blocking

## Testing and Validation

### Service Tests
- [x] MapLayerService processes Civ4 and FreeCiv maps correctly
- [x] Elevation data stored in proper JSONB structure
- [x] Normalization produces 0-1 range values

### Integration Tests
- [x] process_initial_maps.rb executes successfully
- [x] Monitor view renders elevation data without errors
- [x] Canvas displays correct color gradients

### Data Validation
- [x] Elevation arrays are 2D float arrays (0-1 range)
- [x] Terrain/biomes arrays match elevation dimensions
- [x] Quality and method metadata recorded

## Future Enhancements

### Additional Locations
- **Luna**: FreeCiv crater field generation with elevation
- **Venus**: Volcanic terrain with Civ4-style elevation
- **Titan**: Methane lakes with organic terrain types

### Advanced Features
- **Slope Analysis**: Terrain difficulty based on elevation gradients
- **Resource Distribution**: Elevation-based mineral placement
- **Weather Simulation**: Elevation effects on atmospheric patterns

### Real NASA Data Integration
- **ETOPO1/SRTM**: Earth high-resolution elevation
- **MOLA**: Mars laser altimetry data
- **LOLA**: Lunar elevation datasets
- **Magellan**: Venus radar topography

## Documentation Updates

**Recent Changes (2026-01-28)**:
- Implemented MapLayerService for combined Civ4/FreeCiv processing
- Fixed monitor.html.erb elevation data access (removed incorrect normalization)
- Created process_initial_maps.rb for batch processing
- Successfully processed Earth and Mars maps with elevation data
- Updated data structure to use normalized 0-1 elevation values

## References

- [FreeCiv Map Format](https://www.freeciv.org/)
- [Civ4 Save File Structure](https://forums.civfanatics.com/)
- [NASA Planetary Data System](https://pds.nasa.gov)
| -8000m to -200m | deep_sea | Abyssal plains |
| -200m to 0m | ocean | Continental shelves, coastal waters |

#### Land Classification
| Elevation Range | Terrain Type | Description |
|----------------|-------------|-------------|
| 0m to 200m | plains | Coastal plains, lowlands |
| 200m to 500m | grassland | Rolling hills, prairies |
| 500m to 1000m | hills | Elevated terrain |
| 1000m to 2000m | mountains | Mountain ranges |
| 2000m to 5000m | high_mountains | Major peaks (Everest, Olympus Mons) |
| > 5000m | peaks | Extreme elevations |

### Planet-Specific Adjustments

#### Mars Elevation Ranges
- **Hellas Basin**: -8,200m (deep_sea equivalent)
- **Olympus Mons**: +21,229m (peaks)
- **Mean Elevation**: -2,000m (adjusted baseline)
- **Special**: Vastus Borealis (northern lowlands)

#### Lunar Elevation Ranges
- **Mare Basins**: -1,000m to -5,000m (ocean equivalent)
- **Highlands**: +5,000m to +10,000m (high_mountains)
- **South Pole-Aitken Basin**: -7,000m (deep_sea)

#### Venus Elevation Ranges
- **Mean Elevation**: ~0m (adjusted baseline)
- **Maxima**: +11,000m (mountains)
- **Minima**: -2,000m (basins)

## ElevationImportService (Planned)

### Service Architecture
**Location**: `app/services/import/elevation_import_service.rb`

**Key Methods**:
- `import_from_geotiff(file_path, options)`: Main import method
- `resample_elevation(data, target_width, target_height)`: Downsample to game resolution
- `classify_terrain(elevation_grid)`: Convert elevations to terrain types
- `generate_metadata(elevation_data)`: Create map metadata

### Input Processing

#### GeoTIFF Handling
```ruby
# Planned implementation
def read_geotiff(file_path)
  # Use GDAL or ImageMagick to extract elevation data
  # Convert to 2D float array
  # Handle coordinate system transformations
end
```

#### Resolution Scaling
```ruby
def resample_elevation(elevation_data, target_width, target_height)
  # Bilinear interpolation for smooth scaling
  # Maintain elevation accuracy
  # Preserve major features (mountains, valleys)
end
```

### Output Format
```ruby
{
  grid: [
    [
      {
        type: 'mountains',
        elevation: 2157,        # Real elevation in meters
        latitude: 37.7749,      # Optional: for advanced features
        longitude: -122.4194
      }
    ]
  ],
  width: 200,
  height: 100,
  source: 'elevation_import',
  planet_type: 'earth',
  elevation_stats: {
    min_elevation: -11034,    # Mariana Trench
    max_elevation: 8848,      # Everest
    mean_elevation: 0,
    resolution: '30_arc_seconds'
  },
  map_metadata: {
    source_dataset: 'SRTM_30m',
    projection: 'WGS84',
    datum: 'EGM96',
    processing_date: '2026-01-23'
  }
}
```

## Integration with FreeCiv System

### Hybrid Approach
1. **Elevation Data**: Provides scientific accuracy
2. **FreeCiv Tiles**: Provides visual consistency
3. **Combined Rendering**: Real topography with game art

### Terrain Type Mapping
| Elevation Classification | FreeCiv Terrain | Visual Style |
|------------------------|----------------|-------------|
| deep_sea | deep_sea | Dark blue tiles |
| ocean | ocean | Medium blue tiles |
| plains | plains | Tan/green tiles |
| grassland | grassland | Green tiles |
| hills | hills | Brown/green tiles |
| mountains | mountains | Gray/brown tiles |
| high_mountains | mountains | Dark gray tiles |

## UI Visualization

### Height-Based Rendering
- **Color Gradients**: Blue (low) → Green → Brown → White (high)
- **Contour Lines**: Optional elevation contours
- **Shading**: Hill shading for 3D effect

### Layer Integration
- **Base Layer**: FreeCiv tiles colored by elevation
- **Overlay**: Real elevation data for tooltips
- **Filters**: Planet-specific color adjustments

## Performance Considerations

### Data Processing
- **File Sizes**: GeoTIFF files can be 100MB-2GB
- **Processing Time**: 1-5 minutes for full planet conversion
- **Memory Usage**: 500MB-2GB during processing

### Storage Optimization
- **Compression**: Store as compressed JSONB
- **Resolution**: 200x100 grid (20,000 data points)
- **Indexing**: GIN indexes on JSONB for fast queries

### Rendering Performance
- **Pre-computed**: Elevation-to-color mapping cached
- **Progressive Loading**: Load map quadrants on demand
- **LOD System**: Lower resolution for zoomed-out views

## Testing and Validation

### Data Accuracy Tests
- [ ] Elevation ranges match known planetary data
- [ ] Major features preserved (Olympus Mons, Everest)
- [ ] Coordinate system transformations correct

### Terrain Classification Tests
- [ ] Thresholds produce expected biome distributions
- [ ] Edge cases handled (sea level, extreme elevations)
- [ ] Planet-specific adjustments work correctly

### Integration Tests
- [ ] Elevation data loads into terrain_map
- [ ] Canvas renders with correct colors
- [ ] Tooltips show accurate elevation data

## Future Enhancements

### Advanced Features
- **Slope Analysis**: Terrain difficulty based on steepness
- **Aspect Calculation**: Sun exposure for solar power
- **Visibility Analysis**: Line-of-sight calculations
- **Erosion Simulation**: Dynamic terrain changes

### Additional Datasets
- **Titan**: Cassini radar topography
- **Europa**: Galileo altimetry
- **Ganymede**: Future mission data
- **Mercury**: MESSENGER laser altimetry

## Documentation Mandate

**All elevation data imports must be documented:**

1. **Source Attribution**: Record dataset name, version, date
2. **Processing Parameters**: Document resolution, thresholds used
3. **Accuracy Validation**: Note any adjustments made for gameplay
4. **Metadata Updates**: Keep elevation_stats current

## References

- [NASA Planetary Data System](https://pds.nasa.gov)
- [USGS Earth Explorer](https://earthexplorer.usgs.gov)
- [SRTM Data](https://www.usgs.gov/centers/eros/science/usgs-eros-archive-digital-elevation-shuttle-radar-topography-mission-srtm)
- [MOLA Science](https://www.nasa.gov/mission_pages/mgs/science/mola.html)</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/developer/ELEVATION_DATA.md