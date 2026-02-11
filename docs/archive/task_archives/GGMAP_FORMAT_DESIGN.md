# Galaxy Game Native Map Format - Design Analysis
**Date**: 2026-02-11
**Context**: FreeCiv/Civ4 formats don't capture game-specific strategic data

---

## The Core Problem

### What FreeCiv/Civ4 Provide:
```
✅ Terrain types (plains, mountains, desert)
✅ Elevation data (basic)
✅ Biome distribution
✅ Resource markers (generic)

❌ Lava tube locations
❌ Settlement suitability analysis
❌ AI Manager base suggestions
❌ Terraforming targets (worldhouses, etc.)
❌ Geological features (caves, aquifers)
❌ Strategic infrastructure sites
```

### What Galaxy Game Actually Needs:
```
📊 Scientific Layer: Real planetary geology
   - Lava tubes (natural habitats on Luna/Mars)
   - Aquifers (water extraction sites)
   - Stable bedrock (foundation for megastructures)
   - Seismic zones (avoid for critical infrastructure)

🏗️ Strategic Layer: AI Manager guidance
   - Optimal settlement locations (flat + resources + safety)
   - Expansion zones (prioritized regions)
   - Resource extraction sites (ore deposits, ice)
   - Infrastructure corridors (transport networks)

🌍 Terraforming Layer: Long-term targets
   - Worldhouse locations (Mars atmospheric processors)
   - Orbital mirror positions (Venus cooling)
   - Ocean basin zones (future water bodies)
   - Biosphere seed regions (where to start greening)

🎮 Gameplay Layer: Player interaction
   - Points of interest (discoveries, anomalies)
   - Danger zones (radiation, extreme temps)
   - Tutorial markers (for teaching scenarios)
   - Mission objectives (custom scenarios)
```

---

## Proposed: Galaxy Game Map Format (.ggmap)

### Design Philosophy

**1. Hierarchical Structure**
```
Base Layer (Terrain/Elevation) ← From AI/NASA
  ↓
Scientific Layer (Geology/Features) ← Generated from planetary params
  ↓
Strategic Layer (AI Guidance) ← AI Manager analysis
  ↓
Scenario Layer (Custom Content) ← Map Studio edits
```

**2. Non-Destructive**
- Each layer builds on previous
- Layers can be regenerated independently
- Manual edits preserved in scenario layer

**3. Game-Specific**
- Designed for space colonization mechanics
- Integrates with AI Manager
- Supports terraforming simulation
- Enables narrative scenarios

### Format Structure

```json
{
  "format_version": "1.0",
  "metadata": {
    "name": "Mars - Utopia Planitia",
    "celestial_body_id": 123,
    "created_at": "2026-02-11T10:00:00Z",
    "author": "system",
    "locked": false,
    "description": "Mars landing site with optimal settlement zones"
  },
  
  "dimensions": {
    "width": 96,
    "height": 48,
    "resolution": "standard",  // standard, high, ultra
    "coordinate_system": "equirectangular"
  },
  
  "base_terrain": {
    "source": "nasa_geotiff",  // or "ai_generated" or "manual"
    "generation_method": "mola_data",
    "generated_at": "2026-02-11T09:00:00Z",
    
    "elevation": {
      "data": [[...]],  // 2D array, normalized 0-1
      "min_meters": -8000,
      "max_meters": 21000,
      "average_meters": 2500
    },
    
    "terrain_types": {
      "data": [["plains", "hills", ...]], // 2D array
      "legend": {
        "plains": { "color": "#DDAA77", "description": "Flat lowlands" },
        "hills": { "color": "#AA7744", "description": "Elevated terrain" },
        "mountains": { "color": "#885522", "description": "High peaks" }
      }
    },
    
    "biomes": {
      "data": [["barren", "barren", ...]], // 2D array
      "legend": {
        "barren": { "color": "#8B4513", "description": "Lifeless surface" },
        "lichen": { "color": "#556B2F", "description": "Simple organisms" },
        "grassland": { "color": "#90EE90", "description": "Terraformed plains" }
      }
    }
  },
  
  "scientific_layer": {
    "generation_method": "planetary_analysis",
    "generated_at": "2026-02-11T09:30:00Z",
    
    "geological_features": [
      {
        "type": "lava_tube",
        "id": "lava_tube_001",
        "location": { "x": 45, "y": 23 },
        "extent": { "length_km": 50, "diameter_m": 100 },
        "properties": {
          "stability": 0.85,  // 0-1 scale
          "accessibility": 0.70,
          "radiation_shielding": 0.95,
          "suitable_for": ["habitat", "storage", "greenhouse"]
        },
        "discovery_state": "requires_survey"  // undiscovered, requires_survey, confirmed
      },
      {
        "type": "aquifer",
        "id": "aquifer_001",
        "location": { "x": 67, "y": 34 },
        "extent": { "area_km2": 500, "depth_m": 200 },
        "properties": {
          "water_ice_concentration": 0.60,
          "accessibility": 0.50,
          "extraction_difficulty": "moderate",
          "estimated_volume_m3": 1e8
        },
        "discovery_state": "confirmed"
      },
      {
        "type": "stable_bedrock",
        "id": "bedrock_001",
        "location": { "x": 30, "y": 15 },
        "extent": { "area_km2": 100 },
        "properties": {
          "load_bearing": 0.95,
          "seismic_stability": 0.90,
          "suitable_for": ["megastructure", "spaceport", "city_core"]
        }
      }
    ],
    
    "resource_deposits": [
      {
        "type": "iron_ore",
        "id": "iron_001",
        "location": { "x": 52, "y": 28 },
        "properties": {
          "concentration": 0.45,  // percentage
          "estimated_tons": 1e6,
          "extraction_difficulty": "easy",
          "purity": 0.75
        },
        "discovery_state": "confirmed"
      },
      {
        "type": "rare_earth_elements",
        "id": "ree_001",
        "location": { "x": 78, "y": 41 },
        "properties": {
          "elements": ["neodymium", "dysprosium"],
          "estimated_tons": 1e4,
          "extraction_difficulty": "hard"
        },
        "discovery_state": "requires_survey"
      }
    ],
    
    "hazard_zones": [
      {
        "type": "dust_storm_corridor",
        "locations": [
          { "x": 10, "y": 10 },
          { "x": 15, "y": 12 },
          { "x": 20, "y": 14 }
        ],
        "severity": "high",
        "seasonal": true,
        "mitigation": "reinforced_structures"
      },
      {
        "type": "radiation_hotspot",
        "location": { "x": 5, "y": 5 },
        "radius_km": 10,
        "severity": "extreme",
        "shielding_required": true
      }
    ]
  },
  
  "strategic_layer": {
    "generation_method": "ai_manager_analysis",
    "generated_at": "2026-02-11T10:00:00Z",
    "confidence": 0.82,  // AI confidence in recommendations
    
    "settlement_sites": [
      {
        "id": "settlement_alpha",
        "location": { "x": 45, "y": 23 },
        "priority": "highest",
        "reasoning": "Near lava tube + water + flat terrain",
        "suitability_scores": {
          "terrain_flatness": 0.90,
          "resource_proximity": 0.85,
          "natural_shelter": 0.95,
          "expansion_potential": 0.80,
          "radiation_protection": 0.90
        },
        "recommended_for": "primary_colony",
        "capacity_estimate": {
          "initial_population": 100,
          "max_population": 10000,
          "timeframe_years": 50
        },
        "nearby_resources": [
          { "type": "water_ice", "distance_km": 5 },
          { "type": "iron_ore", "distance_km": 15 },
          { "type": "silicon", "distance_km": 8 }
        ]
      },
      {
        "id": "settlement_beta",
        "location": { "x": 67, "y": 34 },
        "priority": "high",
        "reasoning": "Direct aquifer access + stable ground",
        "suitability_scores": {
          "terrain_flatness": 0.85,
          "resource_proximity": 0.95,
          "natural_shelter": 0.40,
          "expansion_potential": 0.75,
          "radiation_protection": 0.50
        },
        "recommended_for": "resource_extraction_hub",
        "specialization": "water_mining"
      }
    ],
    
    "expansion_zones": [
      {
        "id": "zone_001",
        "boundary": [
          { "x": 40, "y": 20 },
          { "x": 50, "y": 20 },
          { "x": 50, "y": 26 },
          { "x": 40, "y": 26 }
        ],
        "priority": "primary",
        "phase": 1,
        "reasoning": "Optimal conditions for initial development",
        "development_order": ["settlement_alpha", "infrastructure_corridor_001", "resource_extraction_sites"]
      }
    ],
    
    "infrastructure_recommendations": [
      {
        "type": "transport_corridor",
        "id": "corridor_001",
        "path": [
          { "x": 45, "y": 23 },
          { "x": 52, "y": 28 },
          { "x": 67, "y": 34 }
        ],
        "reasoning": "Connects primary settlement to water and ore",
        "recommended_mode": "pressurized_tunnel",
        "priority": "high",
        "estimated_cost_credits": 5000000
      },
      {
        "type": "spaceport",
        "id": "spaceport_001",
        "location": { "x": 30, "y": 15 },
        "reasoning": "Stable bedrock + flat terrain + clear landing approaches",
        "priority": "highest",
        "capacity": "heavy_cargo"
      }
    ],
    
    "resource_extraction_sites": [
      {
        "resource_id": "iron_001",
        "extraction_method": "surface_mining",
        "priority": "high",
        "estimated_timeline": {
          "survey_months": 3,
          "setup_months": 12,
          "operation_years": 20
        },
        "ai_manager_tasks": [
          {
            "phase": "survey",
            "duration_months": 3,
            "required_units": ["survey_drone", "geologist"],
            "objective": "Confirm deposit extent and quality"
          },
          {
            "phase": "setup",
            "duration_months": 12,
            "required_units": ["construction_crew", "mining_equipment"],
            "objective": "Establish extraction facility"
          }
        ]
      }
    ]
  },
  
  "terraforming_layer": {
    "generation_method": "terraforming_simulation",
    "generated_at": "2026-02-11T10:30:00Z",
    
    "current_state": {
      "atmosphere_pressure_kpa": 0.6,  // Current Mars
      "temperature_avg_c": -60,
      "water_coverage_percent": 0,
      "vegetation_coverage_percent": 0,
      "habitability_index": 0.15  // 0 = uninhabitable, 1 = Earth-like
    },
    
    "target_state": {
      "atmosphere_pressure_kpa": 60,  // Breathable (0.6 bar)
      "temperature_avg_c": 10,
      "water_coverage_percent": 30,
      "vegetation_coverage_percent": 40,
      "habitability_index": 0.75,
      "estimated_years": 500
    },
    
    "worldhouse_sites": [
      {
        "id": "worldhouse_001",
        "location": { "x": 48, "y": 24 },  // Equatorial for max solar
        "type": "atmospheric_processor",
        "priority": "critical",
        "reasoning": "Optimal solar exposure + stable ground + near colony",
        "specifications": {
          "processing_capacity_tons_day": 10000,
          "power_requirement_mw": 500,
          "construction_time_years": 10,
          "operational_life_years": 200
        },
        "dependencies": [
          "settlement_alpha",  // Requires nearby base for maintenance
          "spaceport_001"      // Requires cargo capability for materials
        ],
        "impact": {
          "atmosphere_increase_kpa_year": 0.01,
          "temperature_increase_c_year": 0.05,
          "radius_of_effect_km": 500
        }
      },
      {
        "id": "worldhouse_002",
        "location": { "x": 70, "y": 35 },
        "type": "water_distributor",
        "priority": "high",
        "reasoning": "Near aquifer + optimal for basin flooding",
        "impact": {
          "water_released_m3_year": 1e6,
          "humidity_increase_percent_year": 0.5
        }
      }
    ],
    
    "ocean_basin_zones": [
      {
        "id": "basin_001",
        "boundary": [...],  // Polygon of target ocean
        "target_depth_m": 1000,
        "target_coverage_percent": 15,
        "phase": "late_stage",  // Happens after 300+ years
        "water_source": "polar_ice_melt + comet_impacts"
      }
    ],
    
    "biosphere_seed_regions": [
      {
        "id": "seed_001",
        "location": { "x": 45, "y": 23 },
        "priority": "primary",
        "reasoning": "Protected lava tube + artificial environment",
        "phase": "early_stage",  // Can start immediately
        "organism_types": ["extremophile_algae", "lichen", "moss"],
        "spread_rate_km2_year": 0.1,
        "conditions_required": {
          "min_temperature_c": -20,
          "min_pressure_kpa": 0.8,
          "radiation_shielding": true
        }
      }
    ],
    
    "timeline": [
      {
        "year": 0,
        "phase": "Foundation",
        "objectives": ["Establish primary colony", "Build first worldhouse", "Start atmosphere processing"]
      },
      {
        "year": 50,
        "phase": "Expansion",
        "objectives": ["Multiple settlements active", "Worldhouse network online", "Visible atmosphere thickening"]
      },
      {
        "year": 200,
        "phase": "Greening",
        "objectives": ["Biosphere spreading", "Liquid water on surface", "Temperature rising"]
      },
      {
        "year": 500,
        "phase": "Habitable",
        "objectives": ["Breathable atmosphere", "Oceans formed", "Self-sustaining biosphere"]
      }
    ]
  },
  
  "scenario_layer": {
    "author": "admin_user",
    "created_at": "2026-02-11T11:00:00Z",
    "description": "Custom tutorial scenario for Mars landing",
    
    "custom_features": [
      {
        "type": "point_of_interest",
        "id": "poi_001",
        "location": { "x": 48, "y": 24 },
        "name": "Ancient Rover Site",
        "description": "Opportunity rover discovered here in 2150",
        "interaction": "player_can_visit",
        "reward": {
          "type": "research_bonus",
          "value": 100
        }
      },
      {
        "type": "tutorial_marker",
        "id": "tutorial_001",
        "location": { "x": 45, "y": 23 },
        "trigger": "first_colony_placement",
        "message": "This lava tube provides natural radiation shielding - perfect for your first habitat!",
        "next_step": "Build habitat in lava tube"
      }
    ],
    
    "mission_objectives": [
      {
        "id": "mission_001",
        "title": "First Steps on Mars",
        "description": "Establish your first colony in the recommended lava tube",
        "objectives": [
          { "type": "build", "target": "habitat", "location": "settlement_alpha" },
          { "type": "extract", "target": "water_ice", "amount": 1000 },
          { "type": "survive", "duration_sols": 100 }
        ],
        "rewards": {
          "credits": 10000,
          "research_points": 500,
          "unlock": "advanced_habitats"
        }
      }
    ],
    
    "manual_overrides": [
      {
        "layer": "strategic_layer",
        "feature_id": "settlement_alpha",
        "property": "priority",
        "original_value": "highest",
        "override_value": "tutorial_forced",
        "reason": "Force player to use this site for tutorial"
      }
    ]
  },
  
  "ai_manager_integration": {
    "autonomous_actions_enabled": true,
    "decision_framework": {
      "settlement_placement": {
        "use_strategic_layer": true,
        "allow_player_override": true,
        "confidence_threshold": 0.7
      },
      "resource_extraction": {
        "prioritize_proximity": true,
        "consider_efficiency": true,
        "respect_hazard_zones": true
      },
      "infrastructure_planning": {
        "follow_recommended_corridors": true,
        "optimize_for_cost": false,  // Prioritize speed
        "consider_future_expansion": true
      }
    },
    
    "learning_data": {
      "successful_settlements": [],  // Populated as game progresses
      "failed_locations": [],
      "resource_efficiency_metrics": {},
      "player_overrides": []  // Learns from player corrections
    }
  }
}
```

---

## Map Studio Integration

### Generation Workflow

```
1. User creates new planet or opens existing
   ↓
2. AI generates base_terrain (from NASA or procedural)
   ↓
3. System analyzes planetary parameters (temp, pressure, composition)
   ↓
4. Generates scientific_layer (lava tubes, aquifers, resources)
   Based on: Planet type, geology, known features
   ↓
5. AI Manager analyzes terrain + scientific data
   ↓
6. Generates strategic_layer (settlement sites, infrastructure)
   ↓
7. Terraforming simulator runs (if applicable)
   ↓
8. Generates terraforming_layer (worldhouse sites, timeline)
   ↓
9. Map saved to geosphere as .ggmap format
   ↓
10. Monitor view renders all layers
```

### Map Studio Editing

**Layer-Based Editor UI**:
```
┌─────────────────────────────────────────┐
│  Mars - Utopia Planitia                 │
├─────────────────────────────────────────┤
│  Layer Controls:                         │
│  [✓] Base Terrain (locked)              │
│  [✓] Scientific (edit mode)              │
│  [✓] Strategic (AI suggestions)          │
│  [ ] Terraforming (preview)              │
│  [✓] Scenario (custom)                   │
├─────────────────────────────────────────┤
│                                          │
│         [Terrain Canvas]                 │
│                                          │
│  Tools:                                  │
│  🗺️  Add Lava Tube                       │
│  💧  Add Aquifer                         │
│  🏗️  Place Settlement Site              │
│  🏭  Place Worldhouse                    │
│  📍  Add POI                             │
│  ✏️  Edit Properties                     │
│                                          │
└─────────────────────────────────────────┘
```

**Editing Actions**:
```javascript
// Add lava tube
{
  action: 'add_feature',
  layer: 'scientific_layer',
  feature_type: 'lava_tube',
  location: { x: 45, y: 23 },
  properties: {
    length_km: 50,
    diameter_m: 100,
    stability: 0.85  // Slider in UI
  }
}

// Override AI settlement suggestion
{
  action: 'modify_feature',
  layer: 'strategic_layer',
  feature_id: 'settlement_alpha',
  property: 'location',
  new_value: { x: 50, y: 25 },  // Drag on map
  reason: 'Manual adjustment for better aesthetics'
}

// Add custom tutorial marker
{
  action: 'add_feature',
  layer: 'scenario_layer',
  feature_type: 'tutorial_marker',
  location: { x: 45, y: 23 },
  properties: {
    message: 'Click here to build your first habitat',
    trigger: 'first_colony_placement'
  }
}
```

---

## Technical Implementation

### Storage in Database

```ruby
# geosphere.terrain_map (JSONB)
{
  "format": "ggmap",
  "version": "1.0",
  "data": { ... }  # Full .ggmap structure
}

# Or separate table for complex scenarios:
class MapData < ApplicationRecord
  belongs_to :geosphere
  
  # Columns:
  # - format (string): "ggmap"
  # - version (string): "1.0"
  # - base_terrain (jsonb)
  # - scientific_layer (jsonb)
  # - strategic_layer (jsonb)
  # - terraforming_layer (jsonb)
  # - scenario_layer (jsonb)
  # - metadata (jsonb)
end
```

### Generation Services

```ruby
# app/services/map_generation/ggmap_generator.rb
class MapGeneration::GgmapGenerator
  def generate(celestial_body)
    {
      base_terrain: generate_base_terrain(celestial_body),
      scientific_layer: generate_scientific_layer(celestial_body),
      strategic_layer: generate_strategic_layer(celestial_body),
      terraforming_layer: generate_terraforming_layer(celestial_body),
      scenario_layer: {}  # Empty, user-populated
    }
  end
  
  private
  
  def generate_scientific_layer(body)
    # Use planetary parameters to generate features
    features = []
    
    # Mars/Luna get lava tubes
    if body.type_includes?('rocky') && body.geological_activity > 0
      features << generate_lava_tubes(body)
    end
    
    # Bodies with ice get aquifers
    if body.surface_temperature < 273 && body.hydrosphere.present?
      features << generate_aquifers(body)
    end
    
    # All bodies get resource deposits based on composition
    features << generate_resource_deposits(body)
    
    features
  end
  
  def generate_strategic_layer(body)
    # AI Manager analyzes terrain + scientific layer
    analyzer = AIManager::SettlementAnalyzer.new(body)
    
    {
      settlement_sites: analyzer.find_optimal_sites,
      expansion_zones: analyzer.plan_expansion,
      infrastructure: analyzer.recommend_infrastructure
    }
  end
end
```

### AI Manager Integration

```ruby
# app/services/ai_manager/settlement_analyzer.rb
class AIManager::SettlementAnalyzer
  def find_optimal_sites
    # Analyze map data
    terrain = @body.geosphere.terrain_map
    scientific = terrain['scientific_layer']
    
    sites = []
    
    # High priority: Near lava tubes (natural shelter)
    scientific['geological_features']
      .select { |f| f['type'] == 'lava_tube' }
      .each do |tube|
        sites << {
          location: tube['location'],
          priority: 'highest',
          reasoning: 'Natural radiation shielding + stable structure',
          suitability_scores: calculate_suitability(tube['location'])
        }
      end
    
    # Medium priority: Near aquifers (water access)
    scientific['geological_features']
      .select { |f| f['type'] == 'aquifer' }
      .each do |aquifer|
        sites << {
          location: aquifer['location'],
          priority: 'high',
          reasoning: 'Direct water access',
          suitability_scores: calculate_suitability(aquifer['location'])
        }
      end
    
    sites.sort_by { |s| -s[:priority] }
  end
end
```

---

## Benefits of .ggmap Format

### 1. Game-Specific Data
```
✅ Lava tubes for natural habitats
✅ Aquifer locations for water mining
✅ AI settlement recommendations
✅ Terraforming target sites
✅ Strategic infrastructure planning
```

### 2. AI Manager Integration
```
✅ Pre-analyzed optimal locations
✅ Resource extraction priorities
✅ Infrastructure recommendations
✅ Learning data storage
✅ Player feedback incorporation
```

### 3. Scalability
```
✅ Generates for any planet type
✅ Adapts to planetary parameters
✅ Scientific layer from composition
✅ Strategic layer from AI analysis
✅ Works for thousands of planets
```

### 4. Customization
```
✅ Scenario layer for custom content
✅ Manual overrides preserve
✅ Tutorial markers
✅ Mission objectives
✅ Narrative elements
```

### 5. Terraforming Support
```
✅ Multi-century timeline
✅ Worldhouse placement
✅ Ocean basin planning
✅ Biosphere progression
✅ Milestone tracking
```

---

## Implementation Phases

### Phase 1: Format Definition (2 hours)
**Tasks**:
1. Finalize .ggmap JSON schema
2. Create sample Mars.ggmap file
3. Document all fields and types
4. Define validation rules

**Output**: Complete format specification

### Phase 2: Generation Services (8 hours)
**Tasks**:
1. Build GgmapGenerator service
2. Implement scientific layer generation (lava tubes, aquifers)
3. Integrate AI Manager for strategic layer
4. Add terraforming simulation for long-term planning
5. Test generation for Mars, Luna, exoplanets

**Output**: Any planet can generate .ggmap automatically

### Phase 3: Map Studio Integration (12 hours)
**Tasks**:
1. Update Map Studio to read .ggmap format
2. Layer-based editor UI
3. Feature placement tools (lava tubes, settlements, etc.)
4. Property editors
5. Save/load .ggmap files

**Output**: Can edit all layers in Map Studio

### Phase 4: Game Integration (6 hours)
**Tasks**:
1. AI Manager reads strategic layer for decisions
2. Terraforming system uses terraforming layer
3. Mission system uses scenario layer
4. Monitor view renders all layers
5. Player can discover hidden features

**Output**: .ggmap drives gameplay systems

---

## Use Cases

### Use Case 1: Mars Colony Planning
```
1. Generate Mars.ggmap automatically
2. Scientific layer identifies:
   - 50km lava tube near Olympus Mons
   - Aquifer under Utopia Planitia
   - Iron ore deposits
3. Strategic layer recommends:
   - Primary settlement at lava tube
   - Water extraction at aquifer
   - Transport corridor between them
4. Player sees AI suggestions, places colony
5. AI Manager autonomously builds infrastructure
```

### Use Case 2: Custom Tutorial Scenario
```
1. Load generated Mars.ggmap
2. Open Map Studio, switch to Scenario layer
3. Add tutorial markers:
   - "Build your first habitat here"
   - "This is a safe water source"
   - "Avoid this radiation zone"
4. Define mission objectives
5. Lock terrain from regeneration
6. Save as "Mars Tutorial.ggmap"
7. Players get guided experience
```

### Use Case 3: Long-Term Terraforming
```
1. Mars.ggmap includes terraforming layer
2. Worldhouse sites pre-calculated
3. Ocean basins marked for future
4. Biosphere seed regions identified
5. Timeline shows 500-year progression
6. AI Manager automatically prioritizes worldhouse construction
7. Player sees long-term vision
8. Atmosphere gradually thickens over centuries
```

---

## Recommendation

### ✅ YES - Create .ggmap Native Format

**Why**:
1. **FreeCiv/Civ4 are insufficient** for space game mechanics
2. **Lava tubes, aquifers, terraforming** are core gameplay
3. **AI Manager needs strategic data** to make smart decisions
4. **Scenarios need custom content** (tutorials, missions)
5. **Future-proof** - can extend format as game grows

### 📋 Suggested Priority

**High Priority**:
- Format definition (2 hours)
- Scientific layer generation (lava tubes, aquifers) (4 hours)
- AI Manager strategic analysis (4 hours)

**Medium Priority**:
- Terraforming layer (4 hours)
- Map Studio layer editing (12 hours)

**Lower Priority**:
- Scenario layer (custom missions) (6 hours)
- Advanced features (learning, optimization) (ongoing)

### 🚀 Next Steps

1. **Define .ggmap schema** (finalize JSON structure)
2. **Build generator for Mars** (prove concept with one planet)
3. **Test with AI Manager** (verify strategic layer works)
4. **Integrate with Map Studio** (enable editing)
5. **Extend to all planets** (generalize generation)

---

**My Strong Opinion**: This is the right approach. FreeCiv/Civ4 were designed for turn-based strategy on Earth. Galaxy Game needs space colonization mechanics - and that requires a custom format that captures lava tubes, terraforming targets, and AI guidance.

