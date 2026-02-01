# Layered Planetary Rendering System

## Overview

Galaxy Game implements a sophisticated layered rendering system inspired by SimEarth, where planetary surfaces evolve through geological, hydrological, biological, and infrastructural changes. Unlike binary terrain switches, this system uses gradual overlays and transparency for realistic terraforming visualization.

## Layer Architecture

### Layer 0: Lithosphere (Geological Foundation)
**Purpose**: Base geological terrain
**Data Source**: terrain_map.grid[].type
**Visual**: FreeCiv tiles with planet-specific filters
**Persistence**: Permanent geological features

**Characteristics**:
- Desert, plains, mountains, ocean tiles
- Planet-specific color tints (Mars red, Venus yellow)
- Elevation-based shading
- Geological features (craters, volcanoes)

### Layer 1: Hydrosphere (Water Systems)
**Purpose**: Liquid water, ice, and atmospheric moisture
**Data Source**: Calculated from terrain composition and temperature
**Visual**: Blue/cyan transparency overlays
**Dynamics**: Changes with terraforming and climate

**Components**:
- Ocean coverage
- Ice caps and glaciers
- River systems (procedural)
- Atmospheric water vapor

### Layer 2: Biosphere (Life and Vegetation)
**Purpose**: Biological colonization and ecosystem development
**Data Source**: bio_density values (0.0 to 1.0)
**Visual**: Green vegetation overlays with alpha transparency
**Dynamics**: Gradual expansion based on terraforming progress

**Implementation**:
```ruby
# Terrain map structure with biosphere data
{
  grid: [
    [
      {
        type: 'desert',
        elevation: 234,
        bio_density: 0.3,        # 30% vegetation coverage
        infrastructure: nil
      }
    ]
  ]
}
```

### Layer 3: Infrastructure (Stations and Logistics)
**Purpose**: Human/artificial structures and transportation
**Data Source**: AI Manager decisions and player actions
**Visual**: Industrial sprites and connection lines
**Dynamics**: Added/removed based on mission success

**Components**:
- Surface stations and depots
- L1 orbital depots (Luna Pattern)
- Transportation routes
- Resource extraction sites

## Biosphere Expansion System

### Growth Mechanics
Unlike binary switches, biosphere expansion is gradual:

**Low Density (0.0 - 0.2)**:
- Microbial colonization
- Visual: Light green tint, sparse vegetation sprites
- Effects: Minor atmospheric oxygen increase

**Medium Density (0.2 - 0.6)**:
- Grassland/prairie development
- Visual: Green overlay with 40-60% opacity
- Effects: Significant oxygen production, soil stabilization

**High Density (0.6 - 0.9)**:
- Forest/jungle ecosystems
- Visual: Dense green overlay, full vegetation sprites
- Effects: Complete atmospheric transformation

**Maximum Density (0.9 - 1.0)**:
- Mature, self-sustaining ecosystems
- Visual: Full FreeCiv forest/jungle tiles replace base terrain
- Effects: Planetary habitability achieved

### Expansion Algorithms

#### Radial Growth Model
```ruby
def expand_biosphere_from_seed(seed_location, radius, growth_rate)
  # Start from terraforming seed point
  # Expand in concentric circles
  # Growth rate affected by:
  # - Local temperature
  # - Soil quality (derived from terrain type)
  # - Water availability
  # - Atmospheric pressure
end
```

#### Terrain Affinity
Different terrain types support different maximum bio_density:

| Terrain Type | Max Bio Density | Growth Rate | Notes |
|-------------|----------------|-------------|-------|
| desert | 0.7 | slow | Requires significant water input |
| plains | 0.9 | medium | Ideal for agriculture |
| grassland | 0.95 | fast | Natural grassland expansion |
| hills | 0.8 | medium | Good drainage, moderate growth |
| mountains | 0.3 | slow | Harsh conditions, limited growth |
| arctic | 0.2 | very_slow | Extreme cold limits expansion |

### Visual Rendering

#### Transparency-Based Overlay
```javascript
function renderBiosphereLayer(terrainGrid, canvas) {
  terrainGrid.forEach((row, y) => {
    row.forEach((cell, x) => {
      const bioDensity = cell.bio_density;
      if (bioDensity > 0) {
        // Draw vegetation overlay with alpha
        const alpha = Math.min(bioDensity * 0.8, 0.8); // Max 80% opacity
        ctx.globalAlpha = alpha;

        // Choose vegetation sprite based on density
        const vegetationSprite = getVegetationSprite(bioDensity);
        ctx.drawImage(vegetationSprite, x * TILE_SIZE, y * TILE_SIZE);

        ctx.globalAlpha = 1.0; // Reset
      }
    });
  });
}
```

#### Sprite Selection Logic
```javascript
function getVegetationSprite(bioDensity) {
  if (bioDensity < 0.3) return grassSprite;        // Sparse grass
  if (bioDensity < 0.6) return grasslandSprite;   // Prairie
  if (bioDensity < 0.9) return forestSprite;      // Woodland
  return jungleSprite;                            // Dense jungle
}
```

## Infrastructure Layer

### Station Types
- **Surface Depot**: Resource collection and processing
- **Orbital Depot**: L1 point logistics hub (Luna Pattern)
- **Asteroid Station**: Super-Mars floating factories
- **Transportation Hub**: Interconnected logistics network

### Placement Logic
```ruby
def place_infrastructure(type, location, requirements)
  case type
  when :surface_depot
    # Requires: flat terrain, resource deposits, accessibility
    validate_surface_conditions(location)
  when :orbital_depot
    # Requires: stable L1 orbit, transportation routes
    validate_orbital_mechanics(location)
  when :asteroid_station
    # Requires: suitable asteroid, Super-Mars configuration
    validate_asteroid_suitability(location)
  end
end
```

### Visual Representation
- **Sprites**: Industrial buildings on surface tiles
- **Connections**: Semi-transparent lines showing logistics routes
- **Status Indicators**: Color-coded for operational status
- **Animation**: Construction progress, resource flow

## Rendering Pipeline

### Layer Compositing Order
1. **Base Terrain** (Layer 0): Geological foundation
2. **Hydrosphere** (Layer 1): Water/ice overlays
3. **Biosphere** (Layer 2): Vegetation with transparency
4. **Infrastructure** (Layer 3): Stations and routes
5. **UI Overlays**: Grid lines, tooltips, selections

### Performance Optimization
- **Dirty Rectangle Rendering**: Only re-render changed areas
- **Layer Caching**: Cache composite layers when unchanged
- **LOD System**: Lower detail at zoom-out levels
- **Progressive Loading**: Load layers on demand

## UI Controls

### Layer Toggles
- **Terrain**: Show/hide geological base layer
- **Hydrosphere**: Show/hide water systems
- **Biosphere**: Show/hide vegetation (with density slider)
- **Infrastructure**: Show/hide stations and routes
- **Elevation**: Height-based color overlay

### Interactive Features
- **Terraforming Tools**: Paint biosphere expansion
- **Station Placement**: Click to place infrastructure
- **Route Planning**: Draw transportation connections
- **Time Controls**: Speed up/slow down terraforming

## Data Management

### Terrain Map Schema Evolution
```ruby
# Version 1: Basic terrain
{ type: 'desert', elevation: 234 }

# Version 2: Add biosphere
{ type: 'desert', elevation: 234, bio_density: 0.3 }

# Version 3: Add infrastructure
{
  type: 'desert',
  elevation: 234,
  bio_density: 0.3,
  infrastructure: {
    type: 'surface_depot',
    status: 'operational',
    resources: ['iron', 'silicon']
  }
}
```

### Migration Strategy
- **Backward Compatibility**: Handle missing fields gracefully
- **Progressive Enhancement**: Add layers without breaking existing data
- **Version Tracking**: Include schema version in terrain_map

## Integration with Game Systems

### AI Manager Connection
- **Terraforming Decisions**: AI analyzes terrain for optimal biosphere expansion
- **Station Placement**: AI identifies strategic infrastructure locations
- **Resource Optimization**: AI manages logistics between surface and orbital depots

### Economic System Integration
- **Resource Values**: Biosphere density affects local resource yields
- **Transportation Costs**: Infrastructure reduces logistics penalties
- **Market Dynamics**: Planetary habitability influences trade values

### Mission Planning
- **Landing Sites**: Infrastructure determines available mission targets
- **Resource Availability**: Biosphere level affects mission profitability
- **Risk Assessment**: Terrain difficulty and infrastructure status

## Testing Requirements

### Visual Tests
- [ ] Layer compositing renders correctly
- [ ] Transparency overlays work properly
- [ ] Color filters apply without artifacts
- [ ] Performance stays under 60fps

### Logic Tests
- [ ] Biosphere expansion algorithms work
- [ ] Infrastructure placement validates correctly
- [ ] Layer data saves/loads properly
- [ ] UI toggles update rendering

### Integration Tests
- [ ] AI Manager affects biosphere growth
- [ ] Economic system responds to infrastructure
- [ ] Mission planner uses terrain data

## Future Enhancements

### Advanced Features
- **Weather Systems**: Dynamic cloud and precipitation overlays
- **Seasonal Changes**: Biosphere responds to orbital seasons
- **Ecological Simulation**: Predator/prey relationships
- **Climate Modeling**: Long-term atmospheric changes

### Multiplayer Considerations
- **Shared State**: Synchronize layer changes across players
- **Conflict Resolution**: Handle simultaneous terraforming
- **Progress Tracking**: Show other players' development

## Documentation Mandate

**All layer system changes must update documentation:**

1. **Layer Additions**: Document new layer types and data structures
2. **Rendering Changes**: Update compositing order and visual effects
3. **Algorithm Updates**: Document biosphere expansion and infrastructure logic
4. **UI Modifications**: Record new controls and interactive features

## References

- [SimEarth (1990) Gameplay](https://en.wikipedia.org/wiki/SimEarth)
- [FreeCiv Layer System](https://www.freeciv.org/wiki/Layers)
- [Terraforming Literature](https://en.wikipedia.org/wiki/Terraforming)</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/developer/LAYERED_RENDERING.md