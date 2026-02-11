# AI-Powered Earth Map Generation System

## Overview

Galaxy Game now includes an advanced AI-powered system for generating Earth maps by analyzing and learning from FreeCiv and Civ4 terrain data. This system combines multiple map sources to create comprehensive, strategically rich planetary terrain with continuous learning capabilities.

## FreeCiv/Civ4 Integration Role

**Training and Reference Data Only:**
FreeCiv (.sav) and Civ4 (.Civ4WorldBuilderSave) maps serve as AI training assets and scenario inspiration:

- **Not Direct Terrain Sources**: Maps are not loaded as direct terrain for planets
- **AI Learning Data**: Used to train pattern recognition for biome placement and strategic features
- **Scenario Templates**: Provide terraforming target blueprints for Digital Twin testing
- **Pattern Extraction**: AI learns terrain distributions, resource patterns, and settlement strategies

**Digital Twin Integration:**
- Map analysis creates reusable scenario templates for SimEarth-style testing
- TerraSim validates physical viability of AI-extracted patterns
- Isolated testing environment prevents live game impact
- Continuous learning improves future terraforming scenario generation

## Key Components

### 1. EarthMapGenerator (`AIManager::EarthMapGenerator`)
**Location**: `app/services/ai_manager/earth_map_generator.rb`

The main service that orchestrates Earth map generation through AI analysis.

**Key Methods**:
- `generate_earth_map(sources:, planet_conditions:)` - Main generation method
- `analyze_imported_map(map_data, source_type, planet_context)` - Analyze individual maps for learning

### 2. Map Processors
**FreeCiv Processor**: `app/services/import/freeciv_map_processor.rb`
- Processes FreeCiv SAV files with biome-based terrain
- Generates elevation using constrained Perlin noise
- Extracts strategic markers from terrain patterns

**Civ4 Processor**: `app/services/import/civ4_map_processor.rb`
- Processes Civ4 WorldBuilder Save files with detailed elevation
- Extracts 70-80% accurate elevation from PlotType data
- Analyzes resource deposits, settlement sites, and strategic locations

### 3. Learning System
**Learning Data**: `data/ai_learning/earth_map_learning.json`
- Stores patterns learned from each map analysis
- Tracks generation success metrics
- Improves future map generation quality

## Usage Workflow

### 1. Prepare Map Files
Place FreeCiv `.sav` files in `data/maps/freeciv/` and Civ4 `.Civ4WorldBuilderSave` files in `data/maps/civ4/`.

### 2. Access AI Generation
1. Go to Admin → Celestial Bodies → Edit [Earth body]
2. Click "🚀 Generate Earth Map with AI" button
3. Select maps for analysis from the available list
4. Configure generation options
5. Click "Generate Earth Map with AI Analysis"

### 3. AI Analysis Process
The system will:
1. Process each selected map using appropriate processor
2. Extract strategic patterns (resources, settlements, terrain features)
3. Learn from successful patterns for future use
4. Combine multiple sources into unified Earth terrain
5. Apply AI optimizations based on learned data
6. Generate Galaxy Game JSON format

## Learning Data Structure

The AI learning system tracks:

```json
{
  "timestamp": "2026-01-28T12:00:00Z",
  "sources": [
    {
      "type": "freeciv",
      "file": "earth-180x90-v1-3"
    }
  ],
  "patterns_learned": {
    "terrain_distribution": {
      "ocean": 0.71,
      "grasslands": 0.12,
      "forest": 0.08
    },
    "resource_patterns": {
      "coastal_bias": 0.75,
      "river_valley_bonus": 0.60
    },
    "settlement_patterns": {
      "coastal_preference": 0.80,
      "river_access_bonus": 0.70
    }
  },
  "quality_metrics": {
    "terrain_realism": 0.85,
    "resource_balance": 0.78,
    "strategic_depth": 0.82
  }
}
```

## Digital Twin Integration

### SimEarth-Style Testing Environment

The Earth map generation system integrates with the Digital Twin Sandbox for SimEarth-inspired terraforming testing:

**Workflow:**
1. FreeCiv/Civ4 maps selected via admin interface (`select_maps_for_analysis`)
2. AI extracts patterns and creates scenario templates
3. Digital Twin creates isolated planetary copy
4. TerraSim applies terraforming interventions toward target state
5. Physics validation ensures realistic outcomes

**Intervention Types:**
- Atmospheric: `atmo_thickening`, `greenhouse_gases`, `ice_melting`
- Settlement: `establish_outpost`, `build_infrastructure`
- Life: `introduce_microbes`, `seed_ecosystem`

**Benefits:**
- Isolated testing without live game impact
- Physics-validated terraforming scenarios
- Continuous improvement through AI learning
- Reusable templates for multiple test scenarios

## Generated Earth Map Format

The system outputs Galaxy Game JSON with:

```json
{
  "metadata": {
    "name": "Earth",
    "source": "ai_generated_from_historical_maps",
    "ai_learning_applied": true
  },
  "planetary_conditions": { /* Earth conditions */ },
  "terrain_data": {
    "lithosphere": { /* Elevation and structure */ },
    "biomes": [ /* Terrain grid */ ],
    "hydrosphere": { /* Water systems */ },
    "biosphere": { /* Life distribution */ }
  },
  "strategic_markers": { /* Resources, settlements, etc. */ },
  "ai_insights": { /* Learning data and optimizations */ }
}
```

## Benefits

### For Players
- **Authentic Earth Terrain**: Realistic continental layout and geography
- **Strategic Depth**: Resources and settlements placed based on real strategic analysis
- **Easter Eggs**: Sci-fi references discovered during gameplay

### For AI Development
- **Continuous Learning**: Each generation improves future results
- **Pattern Recognition**: Learns optimal placement from expert map makers
- **Multi-Source Intelligence**: Combines different mapping approaches

### For Game Balance
- **Resource Distribution**: Balanced based on learned optimal patterns
- **Settlement Opportunities**: Strategically placed for engaging gameplay
- **Terraforming Potential**: Realistic barren state with clear terraforming goals

## Technical Architecture

### Data Flow
```
Map Files → Processors → AI Analysis → Pattern Learning →
Combined Generation → Optimization → Galaxy Game JSON → Database
```

### Learning Loop
```
Analyze Maps → Extract Patterns → Store Learning Data →
Apply Learning → Generate Maps → Measure Success →
Update Learning Data → Repeat
```

## Future Enhancements

### Phase 2: Multi-Planet Learning
- Extend learning system to other planets (Mars, Venus, etc.)
- Cross-planet pattern recognition
- Planetary adaptation algorithms

### Phase 3: Player-Generated Maps
- Allow players to contribute maps for AI learning
- Community-driven map database
- Player-created easter eggs

### Phase 4: Advanced AI Features
- Predictive terraforming outcomes
- Dynamic difficulty adjustment
- Personalized map generation based on player style

## Troubleshooting

### No Maps Found
- Ensure map files are in correct directories:
  - `data/maps/freeciv/` for `.sav` files
  - `data/maps/civ4/` for `.Civ4WorldBuilderSave` files

### Generation Fails
- Check Rails logs for detailed error messages
- Verify map file formats are valid
- Ensure sufficient disk space for processing

### Poor Quality Results
- Include more diverse map sources
- Check learning data accumulation
- Consider map file quality and detail level

## API Reference

### EarthMapGenerator Methods

#### `generate_earth_map(sources:, planet_conditions:)`
Generates complete Earth map from multiple sources.

**Parameters**:
- `sources`: Array of map source hashes with `:type` and `:file_path`
- `planet_conditions`: Hash of planetary conditions

**Returns**: Galaxy Game JSON map data

#### `analyze_imported_map(map_data, source_type, planet_context)`
Analyzes individual map for strategic patterns.

**Parameters**:
- `map_data`: Processed map data from processor
- `source_type`: `:freeciv` or `:civ4`
- `planet_context`: Planetary conditions hash

**Returns**: Analysis results with strategic insights

## Contributing

### Adding New Map Processors
1. Create processor class in `app/services/import/`
2. Implement `process(file_path)` method
3. Return standardized data structure
4. Add to EarthMapGenerator source handling

### Extending Learning System
1. Add new pattern categories to learning data
2. Implement analysis methods in processors
3. Update optimization algorithms
4. Test learning improvement over time

This system represents a significant advancement in procedural terrain generation, combining human expertise from Civ4/FreeCiv maps with AI learning to create rich, strategic, and authentic planetary environments.