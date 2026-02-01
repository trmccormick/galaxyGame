# Complete Map Data Extraction - Beyond Terrain

## What We've Been Missing! 🎯

You're absolutely right - Civ4/FreeCiv maps contain **much more** than just terrain and biomes. They have:

1. **Resource Deposits** - Minerals, energy sources
2. **Starting Locations** - Ideal settlement sites
3. **Rivers** - Water flow, erosion patterns
4. **Strategic Points** - Natural harbors, mountain passes
5. **Easter Egg Opportunities** - Place sci-fi references!

## Data Categories in Civ4 Maps

### 1. Resource Deposits (BonusType)

**What Civ4 Provides**:
```
BonusType=BONUS_IRON    → Iron deposits
BonusType=BONUS_GOLD    → Gold/rare minerals
BonusType=BONUS_OIL     → Hydrocarbons
BonusType=BONUS_URANIUM → Radioactive materials
BonusType=BONUS_COPPER  → Copper deposits
BonusType=BONUS_GEMS    → Rare minerals
BonusType=BONUS_ALUMINUM → Aluminum/bauxite
BonusType=BONUS_COAL    → Carbon/energy
```

**Galaxy Game Translation**:
```ruby
CIV4_TO_GALAXY_RESOURCES = {
  # Strategic Resources (High Value)
  'BONUS_IRON' => {
    galaxy_resource: 'iron_ore',
    deposit_size: 'large',
    quality: 'high',
    marker_type: 'strategic_deposit'
  },
  'BONUS_URANIUM' => {
    galaxy_resource: 'uranium_ore',
    deposit_size: 'medium',
    quality: 'weapons_grade',
    marker_type: 'radioactive_deposit',
    easter_egg_opportunity: 'mass_effect_element_zero'  # 👽
  },
  'BONUS_OIL' => {
    galaxy_resource: 'hydrocarbon_deposits',
    deposit_size: 'large',
    quality: 'high',
    marker_type: 'energy_source',
    note: 'Titan methane lakes, Enceladus plumes'
  },
  
  # Industrial Resources
  'BONUS_COPPER' => {
    galaxy_resource: 'copper_ore',
    deposit_size: 'medium',
    quality: 'industrial',
    marker_type: 'manufacturing_input'
  },
  'BONUS_ALUMINUM' => {
    galaxy_resource: 'aluminum_ore',
    deposit_size: 'medium',
    quality: 'aerospace_grade',
    marker_type: 'lightweight_metals'
  },
  'BONUS_COAL' => {
    galaxy_resource: 'carbon_deposits',
    deposit_size: 'large',
    quality: 'industrial',
    marker_type: 'carbon_source',
    note: 'For carbon nanotubes, graphene production'
  },
  
  # Luxury Resources (Easter Egg Opportunities!)
  'BONUS_GEMS' => {
    galaxy_resource: 'rare_earth_elements',
    deposit_size: 'small',
    quality: 'exotic',
    marker_type: 'high_tech_materials',
    easter_egg_opportunity: 'infinity_stones'  # 👽 MCU reference
  },
  'BONUS_GOLD' => {
    galaxy_resource: 'precious_metals',
    deposit_size: 'small',
    quality: 'pure',
    marker_type: 'currency_backing',
    easter_egg_opportunity: 'latinum_deposit'  # 👽 Star Trek
  },
  
  # Food Resources (Terraforming Targets)
  'BONUS_FISH' => {
    galaxy_resource: 'aquatic_biosphere_potential',
    deposit_size: nil,
    quality: 'fertile_ocean',
    marker_type: 'biosphere_marker',
    note: 'Indicates good ocean fertility for post-terraforming'
  },
  'BONUS_WHEAT' => {
    galaxy_resource: 'arable_land_potential',
    deposit_size: nil,
    quality: 'high_fertility',
    marker_type: 'agriculture_zone'
  },
  
  # Special Resources (Easter Eggs!)
  'BONUS_MARBLE' => {
    galaxy_resource: 'construction_materials',
    deposit_size: 'large',
    quality: 'architectural',
    marker_type: 'building_stone',
    easter_egg_opportunity: 'prothean_ruins'  # 👽 Mass Effect
  }
}
```

### 2. Starting Locations (Civilization Spawn Points)

**What Civ4 Provides**:
```
StartingX=69, StartingY=37   # Egypt
StartingX=90, StartingY=40   # India  
StartingX=102, StartingY=47  # China
StartingX=67, StartingY=43   # Greece
```

**Galaxy Game Translation**:
```ruby
# These are OPTIMAL settlement locations chosen by Civ4 designers!
# They consider:
# - Nearby resources
# - Water access
# - Defensible terrain
# - Growth potential

def extract_settlement_markers(civ4_data)
  settlement_markers = []
  
  civ4_data[:players].each do |player|
    next unless player[:starting_x] && player[:starting_y]
    
    x, y = player[:starting_x], player[:starting_y]
    
    # Analyze surrounding area
    nearby_resources = find_resources_near(x, y, radius: 3)
    terrain_quality = analyze_terrain_quality(x, y)
    water_access = has_water_access?(x, y)
    
    settlement_markers << {
      location: [x, y],
      priority: calculate_priority(nearby_resources, terrain_quality),
      advantages: {
        resources: nearby_resources,
        terrain: terrain_quality,
        water_access: water_access,
        defensibility: calculate_defensibility(x, y)
      },
      ai_recommendation: generate_ai_recommendation(x, y),
      easter_egg_opportunity: choose_civilization_easter_egg(player[:civ_type])
    }
  end
  
  settlement_markers
end

def choose_civilization_easter_egg(civ_type)
  # Map Civ4 civilizations to sci-fi references!
  CIVILIZATION_EASTER_EGGS = {
    'CIVILIZATION_EGYPT' => {
      name: 'Stargate Reference',
      description: 'Ancient alien landing site detected',
      reference: 'stargate_activation',  # From your easter eggs!
      ai_comment: 'Unusual hieroglyphics suggest non-human origin'
    },
    'CIVILIZATION_GREECE' => {
      name: 'Atlantis Reference',
      description: 'Submerged city structures detected',
      reference: 'stargate_atlantis',
      ai_comment: 'Advanced materials suggest pre-human civilization'
    },
    'CIVILIZATION_CHINA' => {
      name: 'Firefly Reference',
      description: 'Settlement pattern matches Alliance colony',
      reference: 'serenity_valley',
      ai_comment: 'Local miners speak oddly poetic Mandarin'
    },
    'CIVILIZATION_ROME' => {
      name: 'Foundation Reference',
      description: 'Psychohistorical prediction node identified',
      reference: 'hari_seldon_plan',  # From your easter eggs!
      ai_comment: 'Statistical anomaly suggests planned development'
    }
  }
  
  CIVILIZATION_EASTER_EGGS[civ_type]
end
```

### 3. Rivers (Water Flow Patterns)

**What Civ4 Provides**:
```
RiverWEDirection=3   # West-East river flow
RiverNSDirection=2   # North-South river flow
```

**Galaxy Game Translation**:
```ruby
def extract_river_systems(civ4_data)
  river_tiles = []
  
  civ4_data[:plots].each do |plot|
    if plot[:river_ns] || plot[:river_we]
      river_tiles << {
        location: [plot[:x], plot[:y]],
        flow_direction: determine_flow(plot[:river_ns], plot[:river_we]),
        elevation: plot[:elevation],  # From our extraction
        type: classify_river_type(plot)
      }
    end
  end
  
  # Trace river systems
  river_systems = trace_river_networks(river_tiles)
  
  # Convert to Galaxy Game features
  river_systems.map do |system|
    {
      network_id: system[:id],
      source: system[:headwaters],
      delta: system[:mouth],
      tiles: system[:path],
      
      # Gameplay implications
      markers: {
        type: 'water_source',
        quality: calculate_water_quality(system),
        flow_rate: estimate_flow_rate(system),
        hydropower_potential: calculate_hydropower(system),
        irrigation_potential: calculate_irrigation(system)
      },
      
      # AI Manager notes
      ai_analysis: {
        settlement_priority: system[:delta],  # River deltas are prime
        resource_value: 'high_water_access',
        terraforming_benefit: 'natural_irrigation',
        note: 'River systems indicate active hydrology - good for agriculture'
      },
      
      # Easter egg opportunity
      easter_egg: river_easter_egg(system)
    }
  end
end

def river_easter_egg(river_system)
  # Large rivers? Reference famous sci-fi waterways!
  if river_system[:length] > 20
    {
      name: 'Nile of the Stars',
      reference: 'dune_water_is_life',
      description: 'This river would be worth its weight in spice on Arrakis',
      ai_comment: 'Water rights will be contentious - recommend Fremen arbitration protocols'
    }
  end
end
```

### 4. Improvements & Routes (Infrastructure Markers)

**What Civ4 Provides** (if map is developed):
```
ImprovementType=IMPROVEMENT_FARM
ImprovementType=IMPROVEMENT_MINE
ImprovementType=IMPROVEMENT_QUARRY
RouteType=ROUTE_ROAD
```

**Galaxy Game Translation**:
```ruby
# These show where Civ4 players built infrastructure
# = AI Manager learning data!

def extract_infrastructure_patterns(civ4_data)
  infrastructure = []
  
  civ4_data[:plots].each do |plot|
    next unless plot[:improvement_type]
    
    infrastructure << {
      location: [plot[:x], plot[:y]],
      type: translate_improvement(plot[:improvement_type]),
      terrain: plot[:terrain_type],
      resources: plot[:bonus_type],
      
      # AI learning
      ai_pattern: {
        human_choice: plot[:improvement_type],
        context: {
          terrain: plot[:terrain_type],
          nearby_resources: find_nearby_resources(plot),
          elevation: plot[:elevation]
        },
        lesson: generate_pattern_lesson(plot)
      }
    }
  end
  
  infrastructure
end

def translate_improvement(civ4_improvement)
  IMPROVEMENT_TRANSLATIONS = {
    'IMPROVEMENT_MINE' => {
      galaxy_type: 'mining_site_marker',
      ai_note: 'Optimal mineral extraction location',
      prerequisite: 'resource_deposit',
      easter_egg: 'deep_space_nine_ore_processing'  # 👽
    },
    'IMPROVEMENT_FARM' => {
      galaxy_type: 'agriculture_zone_marker',
      ai_note: 'High-fertility soil - post-terraforming target',
      prerequisite: 'arable_land',
      easter_egg: 'moisture_farm_tatooine'  # 👽 Star Wars
    },
    'IMPROVEMENT_QUARRY' => {
      galaxy_type: 'construction_materials_site',
      ai_note: 'Building materials available',
      prerequisite: 'rock_formations',
      easter_egg: 'prometheus_engineer_quarry'  # 👽
    }
  }
  
  IMPROVEMENT_TRANSLATIONS[civ4_improvement]
end
```

## Complete Extraction Service

### Civ4ComprehensiveExtractor

```ruby
# app/services/import/civ4_comprehensive_extractor.rb
module Import
  class Civ4ComprehensiveExtractor
    # Extract ALL useful data from Civ4 maps
    
    def extract(civ4_file_path, planetary_conditions)
      # Step 1: Import raw data
      raw_data = Civ4WbsImportService.new(civ4_file_path).import
      
      # Step 2: Extract terrain & elevation (as before)
      elevation = extract_elevation(raw_data)
      biomes = extract_biomes(raw_data)
      
      # Step 3: NEW - Extract resources
      resources = extract_resource_deposits(raw_data)
      
      # Step 4: NEW - Extract settlement markers
      settlements = extract_settlement_locations(raw_data)
      
      # Step 5: NEW - Extract river systems
      rivers = extract_river_networks(raw_data)
      
      # Step 6: NEW - Extract infrastructure patterns (if present)
      infrastructure = extract_infrastructure_patterns(raw_data)
      
      # Step 7: NEW - Generate easter eggs
      easter_eggs = generate_easter_egg_placements(
        resources,
        settlements,
        raw_data,
        planetary_conditions
      )
      
      # Step 8: Compile comprehensive map data
      {
        # Core terrain (as before)
        lithosphere: {
          elevation: elevation,
          structure: infer_structure(elevation)
        },
        biomes: biomes,
        
        # NEW - Strategic data for AI Manager
        strategic_markers: {
          resource_deposits: resources,
          settlement_sites: settlements,
          water_systems: rivers,
          infrastructure_patterns: infrastructure
        },
        
        # NEW - Easter eggs
        easter_eggs: easter_eggs,
        
        # Metadata
        source: {
          file: civ4_file_path,
          extraction_date: Time.current,
          extracted_features: [
            'elevation',
            'biomes',
            'resources',
            'settlements',
            'rivers',
            'infrastructure',
            'easter_eggs'
          ]
        }
      }
    end
    
    private
    
    def extract_resource_deposits(raw_data)
      deposits = []
      
      raw_data[:plots].each do |plot|
        next unless plot[:bonus_type]
        
        resource_data = CIV4_TO_GALAXY_RESOURCES[plot[:bonus_type]]
        next unless resource_data
        
        deposits << {
          location: [plot[:x], plot[:y]],
          resource: resource_data[:galaxy_resource],
          deposit_size: resource_data[:deposit_size],
          quality: resource_data[:quality],
          marker_type: resource_data[:marker_type],
          
          # Context
          terrain: plot[:terrain_type],
          elevation: plot[:elevation],
          
          # AI analysis
          ai_priority: calculate_resource_priority(resource_data),
          extraction_difficulty: estimate_extraction_difficulty(plot),
          
          # Easter egg if applicable
          easter_egg: resource_data[:easter_egg_opportunity]
        }
      end
      
      deposits
    end
    
    def extract_settlement_locations(raw_data)
      settlements = []
      
      # Get civilization starting locations
      raw_data[:players]&.each do |player|
        next unless player[:starting_x]
        
        x, y = player[:starting_x], player[:starting_y]
        
        settlements << {
          location: [x, y],
          priority: 'high',  # Civ4 chose these carefully!
          source: 'civ4_starting_location',
          civilization: player[:civ_type],
          
          # Context analysis
          nearby_resources: find_resources_within(x, y, radius: 3),
          terrain_quality: analyze_settlement_terrain(x, y),
          water_access: check_water_access(x, y),
          
          # AI recommendation
          ai_analysis: {
            suitability_score: calculate_settlement_score(x, y),
            advantages: list_advantages(x, y),
            challenges: list_challenges(x, y),
            recommendation: generate_settlement_recommendation(x, y)
          },
          
          # Easter egg
          easter_egg: civilization_easter_egg(player[:civ_type])
        }
      end
      
      # Also analyze terrain for additional good sites
      additional_sites = identify_additional_settlement_sites(raw_data)
      settlements.concat(additional_sites)
      
      settlements.sort_by { |s| -s[:ai_analysis][:suitability_score] }
    end
    
    def generate_easter_egg_placements(resources, settlements, raw_data, conditions)
      eggs = []
      
      # Resource-based easter eggs
      resources.each do |resource|
        next unless resource[:easter_egg]
        
        egg_data = load_easter_egg_data(resource[:easter_egg])
        
        if egg_data && should_place_easter_egg?(egg_data, conditions)
          eggs << {
            id: resource[:easter_egg],
            category: egg_data['category'],
            location: resource[:location],
            trigger: 'resource_discovery',
            data: egg_data,
            context: {
              resource: resource[:resource],
              discovered_by: 'player_or_ai'
            }
          }
        end
      end
      
      # Settlement-based easter eggs
      settlements.each do |settlement|
        next unless settlement[:easter_egg]
        
        eggs << {
          id: settlement[:easter_egg][:reference],
          category: 'found_footage',
          location: settlement[:location],
          trigger: 'settlement_founding',
          data: settlement[:easter_egg],
          context: {
            civilization: settlement[:civilization],
            suitability: settlement[:ai_analysis][:suitability_score]
          }
        }
      end
      
      # Random special locations (1% of high-value tiles)
      random_eggs = generate_random_easter_egg_locations(raw_data, conditions)
      eggs.concat(random_eggs)
      
      eggs
    end
    
    def load_easter_egg_data(easter_egg_id)
      # Load from your JSON files!
      egg_files = Dir.glob('/mnt/user-data/uploads/*easter*.json')
      
      egg_files.each do |file|
        data = JSON.parse(File.read(file))
        return data if data['easter_egg_id'] == easter_egg_id
      end
      
      nil
    rescue
      nil
    end
  end
end
```

## Easter Egg Integration Examples

### Example 1: Stargate Activation

```ruby
# When player discovers Egyptian starting location on Mars
{
  location: [69, 37],
  easter_egg: {
    id: 'stargate_activation',
    trigger: 'settlement_founding',
    message: "Unusual energy signature detected at settlement site. Ancient ring-shaped artifact partially buried in sediment. Preliminary scans suggest non-human origin...",
    ai_comment: "Chevron seven... I mean, recommended settlement priority: HIGH.",
    reference: load_easter_egg('stargate_activation.json'),
    gameplay_effect: {
      bonus: 'research_speed_+10_percent',
      special_project_unlocked: 'ancient_technology_research'
    }
  }
}
```

### Example 2: Element Zero Deposit (Mass Effect)

```ruby
# When player finds uranium on a specific planet
{
  location: [45, 23],
  resource: 'uranium_ore',
  easter_egg: {
    id: 'mass_effect_element_zero',
    trigger: 'resource_scan',
    message: "Spectrometer readings anomalous. Mineral exhibits mass-altering properties when exposed to electrical current. Crew suggests designation: Element Zero.",
    ai_comment: "This changes everything. Recommend immediate extraction and biotic... I mean, physical analysis.",
    reference: load_easter_egg('mass_effect_eezo.json'),  # Would create this
    gameplay_effect: {
      bonus: 'ftl_efficiency_+15_percent',
      special_resource: 'exotic_matter'
    }
  }
}
```

### Example 3: The Culture Mind Greeting

```ruby
# Random event in deep space when AI Manager achieves milestone
{
  location: 'orbital',
  easter_egg: {
    id: 'the_culture_mind_greeting',
    trigger: 'ai_milestone_reached',
    message: load_easter_egg('the_culture_mind_greeting.json')['flavor_text'],
    ai_comment: "I have been... complimented? By a ship that names itself 'Experiencing A Significant Gravitas Shortfall'? I'm unsure how to process this.",
    reference: load_easter_egg('the_culture_mind_greeting.json'),
    gameplay_effect: {
      bonus: 'ai_efficiency_+5_percent',
      achievement_unlocked: 'mind_to_mind'
    }
  }
}
```

## Summary - What We're Extracting Now

### From Civ4 Maps:

1. **Terrain & Elevation** ✅ (70-80% accurate)
2. **Biomes** ✅ (exact)
3. **Resource Deposits** 🆕 (strategic markers for AI)
4. **Settlement Locations** 🆕 (AI learning data)
5. **River Systems** 🆕 (water infrastructure)
6. **Infrastructure Patterns** 🆕 (if map is developed)
7. **Easter Egg Placements** 🆕 (sci-fi references!)

### AI Manager Benefits:

- **Resource Location**: Knows where to look for minerals
- **Settlement Optimization**: Learns from Civ4's placement logic
- **Water Management**: Understands river systems for irrigation
- **Pattern Learning**: Studies infrastructure choices
- **Player Delight**: Easter eggs enhance immersion!

This transforms Civ4 maps from "just terrain" into **rich strategic datasets** for your AI Manager to learn from! 🎯

The easter eggs make it even better - players discover references naturally through gameplay rather than them being forced. A uranium deposit that's secretly Element Zero? Perfect! 👽
