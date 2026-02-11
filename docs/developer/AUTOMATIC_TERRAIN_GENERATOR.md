# Automatic Terrain Generator

## Overview

The `StarSim::AutomaticTerrainGenerator` is a service responsible for generating procedural terrain data for celestial bodies in the Galaxy Game. It integrates AI-learned terrain patterns with planetary properties to create realistic, playable terrain maps.

## Terrain Data Sources

### Sol System (Our Solar System) - NASA Data Priority

For Sol worlds (Earth, Mars, Venus, Mercury, Luna/Moon), the system prioritizes real NASA data:

**Primary Sources (Ground Truth):**
- **NASA GeoTIFF Elevation Data**: Real topographic data from NASA missions
- Direct loading of GeoTIFF files for accurate planetary topography
- No procedural generation - uses astronomical data

**Secondary Sources (Training/Reference):**
- **FreeCiv/Civ4 Maps**: Used as training data for AI pattern learning
- **Not Direct Terrain Sources**: Maps are not loaded as planet terrain
- **Scenario Templates**: Provide terraforming target blueprints for Digital Twin testing

**Sol World Processing Hierarchy:**
1. **NASA GeoTIFF** (Ground Truth - current planetary state)
2. **Civ4 Maps** (Elevation + land shape, adjusted for hydrosphere)
3. **FreeCiv Maps** (Biome patterns, generate elevation with physics)
4. **AI Generation** (Fallback when no data available)

### Local Bubble Expansion (Other Star Systems) - Generated Data

For star systems outside our solar system, the system generates playable terrain data:

**Procedural Generation:**
- **AI-Learned Patterns**: Uses FreeCiv/Civ4 training data for realistic landmass shapes
- **Physics-Based Scaling**: Planet size and composition determine terrain complexity
- **Playable Systems**: Generates complete, balanced terrain for gameplay

**Data Sources:**
- **Pattern Learning**: FreeCiv/Civ4 maps provide training for biome placement
- **Procedural Algorithms**: Multi-body terrain generation with physics constraints
- **Fallback Generation**: AI creates terrain when specific data unavailable

### FreeCiv/Civ4 Integration

FreeCiv (.sav) and Civ4 (.Civ4WorldBuilderSave) maps are **training/reference data only**:

- **Not Direct Terrain Sources**: Maps are not loaded as direct terrain for planets
- **AI Training Assets**: Used to train AI pattern recognition for biome placement and strategic features
- **Scenario Inspiration**: Provide terraforming target templates for Digital Twin testing
- **Pattern Extraction**: AI learns terrain patterns, settlement locations, and strategic features

### Digital Twin Integration

Terrain generation supports SimEarth-style testing through Digital Twin Sandbox:

- Isolated "what-if" scenarios without affecting live game
- FreeCiv/Civ4 patterns applied as terraforming targets
- TerraSim validates physical viability of AI-suggested terrain

## Architecture

### Service Dependencies

- **AIManager::PlanetaryMapGenerator**: Core terrain generation engine that handles procedural map creation and resource positioning
- **TerrainAnalysis::TerrainQualityAssessor**: Evaluates terrain quality using statistical analysis of elevation, biomes, and strategic markers

### Key Components

1. **Lazy Loading Pattern**: Services are loaded on-demand to prevent autoload issues
2. **Terrain Data Transformation**: Converts raw AI-generated terrain into standardized format
3. **Quality Assessment**: Validates terrain realism, playability, diversity, and balance
4. **Earth-Specific Processing**: Special handling for highly habitable planets

## Data Format

The generator produces terrain data in the following format:

```ruby
{
  grid: Array,           # 1D array of biome letters (d, f, g, o, p)
  elevation: Array,      # Elevation values with random variation
  biomes: Hash,          # Biome counts { 'desert' => count, ... }
  resource_grid: Array,  # 2D array of resource placements
  strategic_markers: Array, # Strategic locations with x,y coordinates
  resource_counts: Hash     # Resource type counts
}
```

## Strategic Markers

Strategic markers are generated as objects with the following structure:

```ruby
{
  x: Integer,        # X coordinate on the grid
  y: Integer,        # Y coordinate on the grid
  type: String,      # 'landing_site', 'resource_rich', or 'strategic'
  value: Integer     # Strategic value (1-10)
}
```

## Quality Assessment

Terrain quality is assessed using multiple criteria:

- **Diversity Score**: Statistical analysis of elevation variance
- **Balance Score**: Distribution analysis of strategic markers
- **Realism Score**: Comparison with planetary properties
- **Playability Score**: Resource distribution and accessibility

## Planet Classification

### Earth-like Planets

Planets are classified as Earth-like based on:
- Surface temperature between 273-373K
- Water coverage > 50%
- Atmospheric pressure between 0.5-2.0 atm

Earth receives special biome treatment for enhanced habitability.

### Generation Criteria

Terrain is generated for:
- Terrestrial planets
- Major moons
- Planets without existing terrain

Gas giants are excluded from terrain generation.

## Implementation Details

### Lazy Loading

```ruby
def planetary_map_generator
  @planetary_map_generator ||= AIManager::PlanetaryMapGenerator.new
end
```

### Elevation Data Generation

Elevation values include random variation to prevent NaN errors in statistical calculations:

```ruby
def generate_elevation_data(biome_grid)
  biome_grid.map do |biome|
    base_elevation = elevation_map[biome] || 0
    base_elevation + rand(-50..50)  # Add variation
  end
end
```

### Resource Grid

Resources are placed probabilistically based on biome types:
- Deserts/Grasslands: 15% chance of minerals
- Forests: 5% chance
- Other biomes: 8% chance

## Testing

The service is thoroughly tested with RSpec, including:
- Terrain generation for new planets
- Resource placement validation
- Strategic marker positioning
- Earth-specific processing
- Planet property analysis
- Quality assessment integration

All tests pass in Docker container environment.

## Integration Points

- **SystemBuilderService**: Calls terrain generation during system creation
- **Geosphere Model**: Stores generated terrain data
- **TerrainAnalysis Services**: Consumes terrain data for quality assessment

## Future Enhancements

- NASA DEM data integration for Earth-like planets
- Enhanced biome variety based on planetary composition
- Dynamic resource distribution algorithms
- Multi-resolution terrain generation</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/developer/AUTOMATIC_TERRAIN_GENERATOR.md