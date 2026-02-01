# Automatic Terrain Generation for Galaxy Game
# Integration Guide and Usage

## Overview

The automatic terrain generation system integrates AI-learned patterns from Civ4/FreeCiv maps with realistic planetary properties to create procedurally generated terrain for new star systems. This ensures that seeded worlds have playable, realistic terrain without manual intervention.

## Key Components

### 1. AutomaticTerrainGenerator (`app/services/star_sim/automatic_terrain_generator.rb`)
Main service that orchestrates terrain generation for celestial bodies.

**Features:**
- Analyzes planetary properties (radius, mass, temperature, atmosphere)
- Generates base terrain using NASA data and radius-based scaling
- Applies AI-learned resource placement patterns
- Special handling for Earth-like planets
- Quality assessment and metadata storage

### 2. TerrainQualityAssessor (`app/services/terrain_analysis/terrain_quality_assessor.rb`)
Evaluates generated terrain for realism, playability, diversity, and balance.

**Quality Metrics:**
- **Realism**: How well terrain matches planetary properties
- **Playability**: Suitability for gameplay (resource distribution, accessibility)
- **Diversity**: Variety in elevation, biomes, and resources
- **Balance**: Fair distribution of opportunities and resources

### 3. SystemBuilderService Integration
Modified to automatically generate terrain during world creation.

**Integration Points:**
- Terrain generation called after celestial body creation
- Only generates for appropriate body types (terrestrial planets, major moons)
- Includes error handling and logging

## Usage

### Automatic Integration
Terrain is generated automatically when seeding new systems:

```ruby
# When building a system, terrain is generated automatically
builder = StarSim::SystemBuilderService.new(name: 'sol-complete')
builder.build!  # Terrain generated for all eligible planets
```

### Manual Terrain Generation
Generate terrain for existing planets:

```ruby
planet = CelestialBodies::CelestialBody.find_by(name: 'Mars')
generator = StarSim::AutomaticTerrainGenerator.new
terrain = generator.generate_terrain_for_body(planet)
```

### Quality Assessment
Evaluate terrain quality:

```ruby
assessor = TerrainAnalysis::TerrainQualityAssessor.new
planet_properties = { radius: planet.radius, surface_temperature: planet.surface_temperature }
scores = assessor.assess_terrain_quality(terrain_data, planet_properties)

puts "Overall quality: #{(scores[:overall] * 100).round(1)}%"
```

## Planet Property Analysis

The system analyzes these planetary properties to determine terrain parameters:

### Terrain Complexity
- **Size factor**: Larger planets get more complex terrain
- **Geological activity**: Volcanic planets get higher complexity
- **Atmospheric effects**: Thicker atmospheres increase weathering/erosion

### Biome Density
- **Earth**: Always 1.0 (full biome density)
- **Temperature**: Habitable range (273-373K) increases density
- **Water**: Higher water coverage increases biome potential
- **Atmosphere**: Reasonable pressure range (0.1-10 bar) helps
- **Magnetic field**: Protection increases habitability

### Elevation Scale
- **Formula**: `log10(radius_km) * (6.0 / density)`
- **Larger planets**: More varied elevation
- **Less dense planets**: More dramatic topography

## AI Learning Integration

### Resource Placement Rules
Learned from Civ4/FreeCiv maps:
- **Ore deposits**: Hills/mountains, elevation 0.6-0.95
- **Rare metals**: Mountains/peaks, elevation 0.8-1.0
- **Volatiles**: Plains/grassland, elevation 0.3-0.7
- **Geothermal**: Volcanic areas, high elevation
- **Solar farms**: Deserts/plains, moderate elevation

### Strategic Markers
Planet-specific markers:
- **Earth**: Coastal cities, agricultural heartlands, mountain passes
- **Mars**: Volcanic cones, lava tubes, mining outposts
- **Moon**: Lunar maria settlements, highland observatories

## Story Arc Alignment

### Act 1: Learning Phase
- AI learns from imported Civ4/FreeCiv maps
- Earth gets special full-biome treatment
- Resource positioning patterns established

### Act 2+: Application Phase
- New systems get automatic terrain generation
- AI applies learned patterns to procedural terrain
- Quality assessment ensures playable results

## Quality Assurance

### Validation Tests
Run the integration test:
```bash
ruby test_terrain_integration_minimal.rb
```

### Quality Thresholds
Generated terrain should meet:
- **Overall quality**: > 60%
- **Realism**: > 50%
- **Playability**: > 50%
- **Diversity**: > 40%
- **Balance**: > 50%

### Monitoring
Check terrain metadata in geosphere:
```ruby
planet.geosphere.terrain_metadata['quality_assessment']
```

## Future Enhancements

### 1. Advanced Learning
- Machine learning models for pattern recognition
- Dynamic rule adaptation based on gameplay feedback

### 2. Multi-Biome Systems
- Continental vs oceanic biome distribution
- Climate zone modeling
- Seasonal variation simulation

### 3. Performance Optimization
- Terrain generation caching
- Parallel processing for large systems
- LOD (Level of Detail) terrain generation

### 4. Expanded Data Sources
- Integration with more NASA datasets
- Real astronomical survey data
- Procedural generation fallbacks

## Troubleshooting

### Common Issues

1. **No terrain generated**
   - Check if planet type is supported
   - Verify geosphere exists
   - Check logs for generation errors

2. **Poor quality scores**
   - Review planetary properties
   - Check for missing atmosphere/hydrosphere data
   - Validate elevation/biome data ranges

3. **Performance issues**
   - Large planets may take longer
   - Consider caching generated terrain
   - Check for memory constraints

### Debug Mode
Enable debug logging in SystemBuilderService:
```ruby
builder = StarSim::SystemBuilderService.new(name: 'test-system', debug_mode: true)
```

## File Structure

```
galaxy_game/
├── app/services/
│   ├── star_sim/
│   │   └── automatic_terrain_generator.rb
│   └── terrain_analysis/
│       └── terrain_quality_assessor.rb
├── test_terrain_integration_minimal.rb
└── app/services/star_sim/system_builder_service.rb (modified)
```

This integration ensures that every seeded world has realistic, playable terrain that enhances the galaxy exploration experience while maintaining the AI learning narrative.