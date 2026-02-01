# FreeCiv Integration Guide

## Overview

Galaxy Game integrates FreeCiv tilesets and map formats to provide professional-quality planetary visualization without requiring custom graphics development. This leverages 25+ years of FreeCiv's tile art development.

## FreeCiv Assets

### Tilesets Used
- **Trident**: Classic FreeCiv tileset (2D isometric view)
- **Amplio**: Higher resolution modern tileset
- **Isotrident**: Isometric 3D-style tileset (optional)

### File Structure
```
public/tilesets/
├── trident/
│   ├── trident.tilespec    # Tileset configuration
│   ├── terrain1.png        # Main terrain spritesheet
│   ├── terrain1.spec       # Tile coordinate definitions
│   ├── terrain2.png        # Additional terrain tiles
│   ├── cities.png          # City/infrastructure sprites
│   ├── units.png           # Unit sprites (optional)
│   └── README              # License and attribution
└── amplio/
    └── ... (similar structure)
```

### License Compliance
- **License**: GNU General Public License v2+
- **Attribution Required**: Must credit FreeCiv project
- **Distribution**: GPL requires source availability (already satisfied by GitHub)

## SAV File Format

### Structure
FreeCiv .sav files contain terrain data as character grids:

```
t0000="a a a : : : d d d g g g"
t0001="a a : : : d d d d g g g"
...
```

### Terrain Character Mapping
| Character | Terrain Type | Galaxy Game Usage |
|-----------|-------------|-------------------|
| a | arctic | Ice/snow (Europa, polar regions) |
| d | desert | Arid terrain (Mars, Venus) |
| p | plains | Open terrain (Luna regolith) |
| g | grassland | Fertile areas (post-terraforming) |
| f | forest | Wooded regions (Earth-like) |
| j | jungle | Dense vegetation (Venus post-terraforming) |
| h | hills | Elevated terrain |
| m | mountains | High peaks (Olympus Mons) |
| s | swamp | Wet areas (Titan methane lakes) |
| o | ocean | Water bodies (Earth, Europa) |
| - | deep_sea | Deep trenches (Earth oceans) |

## Services

### FreecivSavImportService
**Location**: `app/services/import/freeciv_sav_import_service.rb`

**Purpose**: Parse FreeCiv .sav files into Galaxy Game terrain grids

**Key Methods**:
- `import(file_path)`: Main import method
- `parse_terrain_row(row_string)`: Convert character row to terrain array
- `count_biomes(grid)`: Analyze terrain composition

**Output Format**:
```ruby
{
  grid: [['arctic', 'ocean', 'desert'], ...],
  width: 100,
  height: 80,
  biome_counts: { arctic: 25, ocean: 45, desert: 30 }
}
```

### FreecivToGalaxyConverter
**Location**: `app/services/import/freeciv_to_galaxy_converter.rb`

**Purpose**: Convert terrain data to planetary characteristics

**Key Methods**:
- `convert_to_planetary_body(terrain_data, options)`: Main conversion
- `estimate_atmosphere(terrain_composition)`: Calculate atmospheric pressure
- `estimate_temperature(biome_ratios)`: Derive surface temperature
- `generate_hydrosphere_data(terrain_grid)`: Create water/ice data

**Enhancements Over Java Version**:
- More sophisticated biome analysis
- Better planetary parameter estimation
- JSONB storage for flexible data

### FreecivTilesetService
**Location**: `app/services/tileset/freeciv_tileset_service.rb`

**Purpose**: Load and manage tileset assets for rendering

**Key Methods**:
- `load_tileset(name)`: Load tileset configuration
- `get_terrain_tile(terrain_type)`: Get tile image data
- `available_tilesets`: List installed tilesets

**Tileset Loading**:
1. Parse .tilespec file for configuration
2. Load PNG spritesheets
3. Parse .spec files for tile coordinates
4. Cache tile data for rendering

## UI Integration

### Canvas Rendering
**Location**: `app/views/admin/celestial_bodies/monitor.html.erb`

**Rendering Pipeline**:
1. Load terrain_map from CelestialBody.geosphere
2. Initialize TilesetLoader with appropriate tileset
3. Apply planet-specific color filters
4. Draw tiles on HTML5 canvas

### Layer System
- **Base Layer**: FreeCiv terrain tiles
- **Filter Layer**: Planet-specific color adjustments
- **Overlay Layers**: Biosphere, infrastructure, resources

## Planet-Specific Adaptations

### Mars (Red Planet Theme)
- **Base Terrain**: Desert tiles with red oxide tint
- **Special Features**: Dust storms, polar ice caps
- **Color Filter**: `hue-rotate(-20deg) saturate(1.2)`

### Venus (Yellow Haze Theme)
- **Base Terrain**: Plains tiles with sulfur tint
- **Special Features**: Volcanic plains, high pressure
- **Color Filter**: `hue-rotate(45deg) brightness(1.1)`

### Luna (Gray Regolith Theme)
- **Base Terrain**: Plains tiles desaturated
- **Special Features**: Craters, highlands
- **Color Filter**: `grayscale(100%) contrast(1.2)`

### Titan (Orange Methane Theme)
- **Base Terrain**: Swamp tiles with haze tint
- **Special Features**: Methane lakes, nitrogen atmosphere
- **Color Filter**: `hue-rotate(35deg) brightness(1.2)`

## Controller Integration

### Admin::CelestialBodiesController
**Location**: `app/controllers/admin/celestial_bodies_controller.rb`

**New Actions**:
- `import_freeciv`: Handle SAV file uploads
- `process_freeciv_import`: Process uploaded files

**Routes**:
```ruby
# config/routes.rb
namespace :admin do
  resources :celestial_bodies do
    collection do
      get 'import_freeciv'
      post 'process_freeciv_import'
    end
  end
end
```

## Testing

### Unit Tests
- [ ] SAV file parsing accuracy
- [ ] Terrain character mapping
- [ ] Biome counting algorithms
- [ ] Tileset loading and caching

### Integration Tests
- [ ] Full import pipeline (upload → parse → convert → store)
- [ ] Canvas rendering with tiles
- [ ] Planet-specific color filters
- [ ] Layer toggle functionality

## Performance Considerations

### Asset Loading
- Tilesets are loaded asynchronously
- PNG spritesheets cached in memory
- Lazy loading for unused tilesets

### Rendering Optimization
- Canvas-based rendering (fast for 2D)
- Tile culling for large maps
- Efficient layer compositing

### Memory Usage
- Typical tileset: 2-5MB
- Terrain grid: < 1MB for 200x100 grid
- Total footprint: < 10MB for full system

## Troubleshooting

### Black Canvas Issues
1. **Tilesets not copied**: Check `public/tilesets/` exists
2. **JavaScript errors**: Check browser console for TilesetLoader errors
3. **No terrain data**: Verify CelestialBody has terrain_map data
4. **Canvas dimensions**: Ensure canvas width/height set correctly

### Import Failures
1. **Invalid SAV format**: Check file starts with terrain lines
2. **Missing tileset**: Ensure tileset files exist in public/
3. **Database errors**: Check JSONB column exists in geospheres

## Future Enhancements

- **Dynamic Tilesets**: Runtime tileset switching
- **Custom Tiles**: User-generated planet themes
- **Animation**: Terrain change animations
- **Multi-resolution**: LOD system for large maps

## References

- [FreeCiv Project](https://www.freeciv.org)
- [FreeCiv Tileset Documentation](https://www.freeciv.org/wiki/Tilesets)
- [Original Java Implementation Notes](docs/developer/claude_notes.md)</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/developer/FREECIV_INTEGRATION.md