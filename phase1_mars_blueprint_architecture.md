# Phase 1: Mars Terraforming Blueprint Architecture Changes
# ===================================================

## Overview
Transform Civ4/FreeCiv map processors from habitable world generators to terraforming blueprint extractors for Mars. Key changes:
- Extract settlement locations, terraforming targets, and geological features instead of applying biomes
- Account for Mars' historical shoreline migration due to atmospheric loss
- Create blueprint data structures for TerraSim integration

## Current Architecture Issues
1. **Civ4MapProcessor**: Extracts elevation/biomes directly, applies them to generate habitable worlds
2. **FreecivMapProcessor**: Uses BIOME_ELEVATION_HINTS that don't account for Mars historical geology
3. **Mars Shoreline Problem**: PlotType=3 represents both water and peaks, but current code assumes water
4. **Biome Application**: Maps are used for direct biome application rather than blueprint extraction

## Phase 1 Changes Required

### 1. Modify Civ4MapProcessor for Blueprint Extraction
**File**: `galaxy_game/app/services/import/civ4_map_processor.rb`

**Changes**:
- Add `mars_blueprint_mode` parameter to `process()` method
- When in blueprint mode:
  - Extract settlement locations from cities/starting positions
  - Extract terraforming targets from terrain features
  - Extract geological naming data from bonus types/features
  - Skip biome application and elevation generation
  - Return blueprint data structure instead of terrain data

**New Methods**:
```ruby
def extract_mars_blueprints(raw_data)
  {
    settlement_sites: extract_settlement_sites(raw_data),
    terraforming_targets: extract_terraforming_targets(raw_data),
    geological_features: extract_geological_features(raw_data),
    historical_water_levels: estimate_historical_water_levels(raw_data)
  }
end

def extract_settlement_sites(raw_data)
  # Extract from cities, starting positions, goody huts
  # Return: [{x:, y:, type:, suitability:}]
end

def extract_terraforming_targets(raw_data)
  # Extract from terrain types that represent terraformable features
  # Use TERRAFORMING_REVERSE_MAPS from TerrainTerraformingService
  # Return: [{x:, y:, target_biome:, current_terrain:, priority:}]
end

def estimate_historical_water_levels(raw_data)
  # Account for shoreline migration
  # PlotType=3 with TERRAIN_COAST/TERRAIN_OCEAN = ancient shoreline
  # Return elevation adjustments for historical water boundaries
end
```

### 2. Modify FreecivMapProcessor for Mars Context
**File**: `galaxy_game/app/services/import/freeciv_map_processor.rb`

**Changes**:
- Add Mars-specific BIOME_ELEVATION_HINTS that account for historical geology
- Modify `infer_elevation_from_biomes()` to use Mars-corrected elevations
- Add blueprint extraction mode similar to Civ4 processor

**Mars-Specific Elevation Hints**:
```ruby
MARS_BIOME_ELEVATION_HINTS = {
  # Ancient water features (now dry)
  ocean: 0.20,        # Ancient ocean basins (not current water)
  deep_sea: 0.15,     # Ancient deep sea basins
  swamp: 0.35,        # Ancient wetlands/coastal areas

  # Current Mars terrain
  desert: 0.60,       # Regolith deserts
  rocky: 0.75,        # Rocky highlands
  arctic: 0.80,       # Polar ice caps
  tundra: 0.70        # Transitional zones
}.freeze
```

### 3. Create Mars-Specific Elevation Processor
**File**: `galaxy_game/app/services/import/mars_elevation_processor.rb` (NEW)

**Purpose**: Handle Mars' unique elevation challenges
- Correct for shoreline migration
- Account for ancient water levels
- Generate elevation constraints for TerraSim

**Key Methods**:
```ruby
def correct_for_historical_shorelines(elevation_grid, blueprint_data)
  # Adjust elevations based on historical_water_levels from blueprints
  # Ancient shorelines should be at lower elevations than current terrain suggests
end

def generate_terraforming_constraints(blueprint_data)
  # Create elevation constraints that TerraSim can use
  # Define viable ranges for different terraforming targets
end
```

### 4. Update MultiBodyTerrainGenerator for Blueprint Integration
**File**: `galaxy_game/app/services/terrain/multi_body_terrain_generator.rb`

**Changes**:
- Modify `apply_mars_characteristics()` to accept blueprint data
- Use blueprint settlement sites for feature placement
- Integrate with TerraSim targets

### 5. Create Blueprint Data Structures
**File**: `galaxy_game/app/models/terraforming_blueprint.rb` (NEW)

**Structure**:
```ruby
class TerraformingBlueprint < ApplicationRecord
  belongs_to :celestial_body
  has_many :settlement_sites
  has_many :terraforming_targets
  has_many :geological_features

  # JSON fields for complex data
  serialize :elevation_constraints, JSON
  serialize :historical_water_data, JSON
end
```

## Implementation Plan

### Step 1: Core Processor Changes
1. Modify Civ4MapProcessor to support blueprint extraction mode
2. Add Mars-specific elevation corrections
3. Create blueprint data extraction methods

### Step 2: Blueprint Data Structures
1. Create TerraformingBlueprint model
2. Define associated models for settlement sites, targets, features
3. Add database migrations

### Step 3: Integration Points
1. Update AI Manager to use blueprint data
2. Modify TerraSim integration to consume blueprint targets
3. Update geological naming system

### Step 4: Testing & Validation
1. Test blueprint extraction with Mars Civ4 maps
2. Validate elevation corrections against known Mars geology
3. Ensure TerraSim can consume blueprint data

## Expected Outcomes
- Civ4/FreeCiv maps become terraforming blueprint sources instead of habitable world templates
- Mars terrain generation accounts for historical shoreline migration
- Settlement planning uses extracted lava tube bases and strategic locations
- TerraSim receives biome targets instead of applied biomes
- Geological naming integrates with imported Civ4 features

## Risk Mitigation
- Maintain backward compatibility with existing habitable world generation
- Add feature flags to enable/disable blueprint mode
- Comprehensive testing with Mars maps before production deployment</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/phase1_mars_blueprint_architecture.md