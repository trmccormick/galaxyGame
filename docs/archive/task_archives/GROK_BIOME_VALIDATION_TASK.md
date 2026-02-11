# TASK 1: Commit Current Monitor Work to Git

## STOP - Commit Before Proceeding

Before starting any new work, commit the current monitor view changes to git:

```bash
cd /home/galaxy_game

# Check what files were modified
git status

# Review the changes
git diff

# Add the monitor view files
git add app/views/admin/celestial_bodies/monitor.html.erb
git add app/assets/javascripts/monitor.js  # if modified
git add app/controllers/admin/celestial_bodies_controller.rb  # if modified

# Any other files that were changed for hydrosphere rendering
git add <any other modified files>

# Commit with descriptive message
git commit -m "Fix monitor view: Add composition-based hydrosphere colors and layer rendering

- Renamed Water toggle to Hydrosphere toggle
- Implemented composition-based colors (blue for H2O, orange for CH4, etc.)
- Fixed state distribution logic (Mars shows ice caps, not oceans)
- Fixed Earth ocean filling using bathtub model
- Separated base elevation from overlay layers
- All layer toggles working correctly"

# Push to repository
git push origin <current-branch-name>
```

## Verification

After committing, verify:
```bash
git log --oneline -1  # Should show your commit message
git status            # Should show "working tree clean"
```

**DO NOT PROCEED TO TASK 2 UNTIL THIS IS COMPLETE.**

---

# TASK 2: Implement Biome Validation System

## Overview

Currently, biomes are loaded from Civ4/FreeCiv maps without any validation against environmental constraints. This means:
- Forests can exist in desert climates
- Arctic biomes can appear at the equator
- Biome placement may not make physical sense

We need a validation layer that checks if biome placement is environmentally realistic based on:
- Elevation
- Temperature (from latitude + atmosphere)
- Moisture/rainfall (from hydrosphere + atmospheric circulation)

## Architecture

### New Service: BiomeValidator

**Location:** `app/services/terra_sim/biome_validator.rb`

**Purpose:** Validate biome placement against environmental constraints

**Key Methods:**
- `validate_biome_grid(celestial_body, biome_grid)` → Returns validation score (0-100%)
- `validate_single_biome(x, y, biome, environment)` → Returns true/false + reason
- `suggest_correct_biome(x, y, environment)` → Returns recommended biome for location

### Environmental Constraints

Define realistic constraints for each biome type:

```ruby
module TerraSim
  class BiomeValidator
    BIOME_CONSTRAINTS = {
      'ocean' => {
        elevation: { max: 0 },
        temperature: { min: 271, max: 373 },  # Liquid water range
        required: ['hydrosphere']
      },
      
      'ice' => {
        elevation: { min: -11000, max: 10000 },
        temperature: { max: 273 },  # Below freezing
        preferred_latitude: { min: 60, max: 90 }  # Polar regions
      },
      
      'tundra' => {
        elevation: { min: 0, max: 3000 },
        temperature: { min: 243, max: 273 },  # Cold but not frozen
        rainfall: { min: 100, max: 500 }
      },
      
      'boreal_forest' => {
        elevation: { min: 0, max: 2000 },
        temperature: { min: 258, max: 283 },  # Cool
        rainfall: { min: 400, max: 1500 }
      },
      
      'temperate_forest' => {
        elevation: { min: 0, max: 2500 },
        temperature: { min: 273, max: 298 },  # Moderate
        rainfall: { min: 500, max: 3000 }
      },
      
      'tropical_forest' => {
        elevation: { min: 0, max: 1500 },
        temperature: { min: 293, max: 313 },  # Warm/hot
        rainfall: { min: 1500, max: 5000 },
        preferred_latitude: { min: 0, max: 23 }  # Equatorial
      },
      
      'grassland' => {
        elevation: { min: 0, max: 2000 },
        temperature: { min: 273, max: 308 },
        rainfall: { min: 300, max: 900 }
      },
      
      'savanna' => {
        elevation: { min: 0, max: 1500 },
        temperature: { min: 283, max: 313 },
        rainfall: { min: 500, max: 1200 },
        preferred_latitude: { min: 5, max: 20 }  # Subtropical
      },
      
      'desert' => {
        elevation: { min: 0, max: 3000 },
        temperature: { min: 273, max: 333 },  # Wide range
        rainfall: { max: 250 }
      },
      
      'mountains' => {
        elevation: { min: 2000, max: 10000 },
        temperature: { varies: true }  # Depends on elevation
      },
      
      'swamp' => {
        elevation: { min: -5, max: 50 },  # Low-lying
        temperature: { min: 278, max: 308 },
        rainfall: { min: 1000, max: 3000 },
        required: ['hydrosphere', 'flat_terrain']
      }
    }.freeze
    
    def initialize(celestial_body)
      @body = celestial_body
      @geosphere = celestial_body.geosphere
      @atmosphere = celestial_body.atmosphere
      @hydrosphere = celestial_body.hydrosphere
    end
    
    # Main validation method
    def validate_biome_grid(biome_grid)
      return { score: 0, errors: ['No biome grid provided'] } unless biome_grid
      
      total_tiles = 0
      valid_tiles = 0
      errors = []
      warnings = []
      
      biome_grid.each_with_index do |row, y|
        row.each_with_index do |biome, x|
          total_tiles += 1
          
          environment = calculate_environment(x, y)
          validation = validate_single_biome(x, y, biome, environment)
          
          if validation[:valid]
            valid_tiles += 1
          else
            errors << {
              x: x, y: y, 
              biome: biome,
              reason: validation[:reason],
              suggested: validation[:suggested_biome]
            }
          end
          
          warnings += validation[:warnings] if validation[:warnings]
        end
      end
      
      score = (valid_tiles.to_f / total_tiles * 100).round(2)
      
      {
        score: score,
        total_tiles: total_tiles,
        valid_tiles: valid_tiles,
        invalid_tiles: total_tiles - valid_tiles,
        errors: errors.take(100),  # Limit error list
        warnings: warnings.take(50),
        summary: generate_summary(score, errors, warnings)
      }
    end
    
    # Validate a single biome placement
    def validate_single_biome(x, y, biome, environment)
      constraints = BIOME_CONSTRAINTS[biome]
      
      return { valid: false, reason: "Unknown biome: #{biome}" } unless constraints
      
      errors = []
      warnings = []
      
      # Check elevation
      if constraints[:elevation]
        elev = environment[:elevation]
        
        if constraints[:elevation][:min] && elev < constraints[:elevation][:min]
          errors << "Elevation too low (#{elev}m < #{constraints[:elevation][:min]}m)"
        end
        
        if constraints[:elevation][:max] && elev > constraints[:elevation][:max]
          errors << "Elevation too high (#{elev}m > #{constraints[:elevation][:max]}m)"
        end
      end
      
      # Check temperature
      if constraints[:temperature] && !constraints[:temperature][:varies]
        temp = environment[:temperature]
        
        if constraints[:temperature][:min] && temp < constraints[:temperature][:min]
          errors << "Too cold (#{temp}K < #{constraints[:temperature][:min]}K)"
        end
        
        if constraints[:temperature][:max] && temp > constraints[:temperature][:max]
          errors << "Too hot (#{temp}K > #{constraints[:temperature][:max]}K)"
        end
      end
      
      # Check rainfall
      if constraints[:rainfall]
        rainfall = environment[:rainfall]
        
        if constraints[:rainfall][:min] && rainfall < constraints[:rainfall][:min]
          errors << "Too dry (#{rainfall}mm < #{constraints[:rainfall][:min]}mm)"
        end
        
        if constraints[:rainfall][:max] && rainfall > constraints[:rainfall][:max]
          errors << "Too wet (#{rainfall}mm > #{constraints[:rainfall][:max]}mm)"
        end
      end
      
      # Check latitude preferences
      if constraints[:preferred_latitude]
        lat = environment[:latitude]
        lat_abs = lat.abs
        
        if lat_abs < constraints[:preferred_latitude][:min] || 
           lat_abs > constraints[:preferred_latitude][:max]
          warnings << "Unusual for latitude #{lat}° (typically #{constraints[:preferred_latitude][:min]}-#{constraints[:preferred_latitude][:max]}°)"
        end
      end
      
      # Check required features
      if constraints[:required]
        constraints[:required].each do |feature|
          case feature
          when 'hydrosphere'
            unless @hydrosphere && @hydrosphere['total_hydrosphere_mass'].to_f > 0
              errors << "Requires hydrosphere (planet is dry)"
            end
          when 'flat_terrain'
            if environment[:slope] > 5  # degrees
              warnings << "Typically found on flatter terrain"
            end
          end
        end
      end
      
      valid = errors.empty?
      suggested_biome = suggest_correct_biome(environment) unless valid
      
      {
        valid: valid,
        reason: errors.join('; '),
        warnings: warnings,
        suggested_biome: suggested_biome
      }
    end
    
    # Calculate environmental conditions at a location
    def calculate_environment(x, y)
      terrain_map = @geosphere.terrain_map
      
      # Get elevation
      elevation = terrain_map['elevation'][y][x] rescue 0
      
      # Calculate latitude (-90 to +90)
      grid_height = terrain_map['elevation'].size
      latitude = 90 - (y.to_f / grid_height * 180)
      
      # Calculate temperature based on latitude and elevation
      base_temp = @body.surface_temperature || 288
      
      # Adjust for latitude (cooler at poles)
      lat_factor = Math.cos(latitude * Math::PI / 180)
      temp_latitude_adjustment = (1 - lat_factor) * -30  # Up to -30K at poles
      
      # Adjust for elevation (lapse rate: ~6.5K per 1000m)
      temp_elevation_adjustment = -(elevation / 1000.0 * 6.5)
      
      temperature = base_temp + temp_latitude_adjustment + temp_elevation_adjustment
      
      # Calculate rainfall (simplified model)
      rainfall = calculate_rainfall(x, y, latitude, elevation, temperature)
      
      # Calculate slope (simplified - compare to neighbors)
      slope = calculate_slope(x, y, terrain_map['elevation'])
      
      {
        x: x,
        y: y,
        elevation: elevation,
        latitude: latitude,
        temperature: temperature,
        rainfall: rainfall,
        slope: slope
      }
    end
    
    # Simplified rainfall calculation
    def calculate_rainfall(x, y, latitude, elevation, temperature)
      # Base rainfall from latitude (ITCZ at equator, dry at 30°, wet at 60°)
      lat_abs = latitude.abs
      
      if lat_abs < 10
        base_rainfall = 2000  # Tropical
      elsif lat_abs < 30
        base_rainfall = 500   # Subtropical dry
      elsif lat_abs < 60
        base_rainfall = 1000  # Temperate
      else
        base_rainfall = 300   # Polar dry
      end
      
      # Adjust for hydrosphere presence
      if @hydrosphere
        hydro_mass = @hydrosphere['total_hydrosphere_mass'].to_f
        if hydro_mass > 1e21  # Earth-like
          base_rainfall *= 1.2
        elsif hydro_mass < 1e18  # Mars-like
          base_rainfall *= 0.1
        end
      else
        base_rainfall *= 0.1  # Dry world
      end
      
      # Orographic effect (mountains create rain shadows)
      if elevation > 1000
        base_rainfall *= 1.3  # Windward side gets more
      end
      
      # Temperature affects evaporation
      if temperature < 273
        base_rainfall *= 0.5  # Cold = less evaporation
      elsif temperature > 303
        base_rainfall *= 1.2  # Hot = more evaporation
      end
      
      base_rainfall.round
    end
    
    # Calculate slope in degrees
    def calculate_slope(x, y, elevation_grid)
      height = elevation_grid.size
      width = elevation_grid[0].size
      
      return 0 if x == 0 || y == 0 || x >= width - 1 || y >= height - 1
      
      center = elevation_grid[y][x]
      
      # Sample 4 neighbors
      north = elevation_grid[y-1][x]
      south = elevation_grid[y+1][x]
      east = elevation_grid[y][x+1]
      west = elevation_grid[y][x-1]
      
      # Calculate max elevation change
      max_change = [
        (center - north).abs,
        (center - south).abs,
        (center - east).abs,
        (center - west).abs
      ].max
      
      # Assume ~10km grid spacing, convert to degrees
      # slope = arctan(rise/run)
      grid_spacing = 10000  # meters
      Math.atan(max_change / grid_spacing) * 180 / Math::PI
    end
    
    # Suggest appropriate biome for environment
    def suggest_correct_biome(environment)
      # Try each biome and score it
      scores = {}
      
      BIOME_CONSTRAINTS.each do |biome, constraints|
        score = 0
        
        # Elevation match
        if constraints[:elevation]
          elev = environment[:elevation]
          if (!constraints[:elevation][:min] || elev >= constraints[:elevation][:min]) &&
             (!constraints[:elevation][:max] || elev <= constraints[:elevation][:max])
            score += 3
          end
        end
        
        # Temperature match
        if constraints[:temperature] && !constraints[:temperature][:varies]
          temp = environment[:temperature]
          if (!constraints[:temperature][:min] || temp >= constraints[:temperature][:min]) &&
             (!constraints[:temperature][:max] || temp <= constraints[:temperature][:max])
            score += 3
          end
        end
        
        # Rainfall match
        if constraints[:rainfall]
          rainfall = environment[:rainfall]
          if (!constraints[:rainfall][:min] || rainfall >= constraints[:rainfall][:min]) &&
             (!constraints[:rainfall][:max] || rainfall <= constraints[:rainfall][:max])
            score += 2
          end
        end
        
        # Latitude preference bonus
        if constraints[:preferred_latitude]
          lat_abs = environment[:latitude].abs
          if lat_abs >= constraints[:preferred_latitude][:min] &&
             lat_abs <= constraints[:preferred_latitude][:max]
            score += 1
          end
        end
        
        scores[biome] = score
      end
      
      # Return highest scoring biome
      scores.max_by { |biome, score| score }&.first
    end
    
    # Generate human-readable summary
    def generate_summary(score, errors, warnings)
      if score >= 90
        "Excellent biome placement (#{score}%)"
      elsif score >= 75
        "Good biome placement with minor issues (#{score}%)"
      elsif score >= 50
        "Acceptable biome placement with significant issues (#{score}%)"
      else
        "Poor biome placement - major environmental mismatches (#{score}%)"
      end
    end
  end
end
```

## Integration Points

### 1. Add Validation to Monitor View

**File:** `app/views/admin/celestial_bodies/monitor.html.erb`

Add validation display:

```erb
<!-- Add after layer controls -->
<div class="biome-validation-panel">
  <h4>Biome Validation</h4>
  <div id="validation-score">
    <!-- Populated by JavaScript -->
  </div>
  <button onclick="runBiomeValidation()">Validate Biomes</button>
  <div id="validation-details" style="display: none;">
    <!-- Validation errors/warnings -->
  </div>
</div>
```

Add JavaScript:

```javascript
function runBiomeValidation() {
  fetch(`/admin/celestial_bodies/${bodyId}/validate_biomes`)
    .then(response => response.json())
    .then(data => {
      displayValidationResults(data);
    });
}

function displayValidationResults(validation) {
  const scoreDiv = document.getElementById('validation-score');
  
  const scoreClass = validation.score >= 75 ? 'good' : 
                     validation.score >= 50 ? 'warning' : 'error';
  
  scoreDiv.innerHTML = `
    <div class="validation-score ${scoreClass}">
      ${validation.summary}
      <br>
      Valid: ${validation.valid_tiles} / ${validation.total_tiles} tiles
    </div>
  `;
  
  // Show details if there are errors
  if (validation.errors.length > 0) {
    const detailsDiv = document.getElementById('validation-details');
    detailsDiv.style.display = 'block';
    
    const errorList = validation.errors.slice(0, 10).map(err => 
      `Tile (${err.x},${err.y}): ${err.biome} - ${err.reason} (suggested: ${err.suggested})`
    ).join('<br>');
    
    detailsDiv.innerHTML = `
      <h5>Sample Issues:</h5>
      ${errorList}
      ${validation.errors.length > 10 ? '<br>...and more' : ''}
    `;
  }
}
```

### 2. Add Controller Action

**File:** `app/controllers/admin/celestial_bodies_controller.rb`

```ruby
def validate_biomes
  @celestial_body = CelestialBodies::CelestialBody.find(params[:id])
  
  biome_grid = @celestial_body.geosphere.terrain_map['biomes']
  
  validator = TerraSim::BiomeValidator.new(@celestial_body)
  validation_result = validator.validate_biome_grid(biome_grid)
  
  render json: validation_result
end
```

Add route:

```ruby
# config/routes.rb
namespace :admin do
  resources :celestial_bodies do
    member do
      get :validate_biomes
    end
  end
end
```

### 3. Add Tests

**File:** `spec/services/terra_sim/biome_validator_spec.rb`

```ruby
require 'rails_helper'

RSpec.describe TerraSim::BiomeValidator do
  let(:earth) { create(:celestial_body, :earth_like) }
  let(:validator) { described_class.new(earth) }
  
  describe '#validate_single_biome' do
    it 'accepts tropical forest at equator with high rainfall' do
      environment = {
        elevation: 100,
        latitude: 0,
        temperature: 300,
        rainfall: 2000,
        slope: 2
      }
      
      result = validator.validate_single_biome(0, 0, 'tropical_forest', environment)
      expect(result[:valid]).to be true
    end
    
    it 'rejects tropical forest at pole' do
      environment = {
        elevation: 100,
        latitude: 80,
        temperature: 250,
        rainfall: 2000,
        slope: 2
      }
      
      result = validator.validate_single_biome(0, 0, 'tropical_forest', environment)
      expect(result[:valid]).to be false
      expect(result[:reason]).to include('Too cold')
    end
    
    it 'rejects desert with high rainfall' do
      environment = {
        elevation: 500,
        latitude: 30,
        temperature: 310,
        rainfall: 1000,
        slope: 1
      }
      
      result = validator.validate_single_biome(0, 0, 'desert', environment)
      expect(result[:valid]).to be false
      expect(result[:reason]).to include('Too wet')
    end
  end
  
  describe '#suggest_correct_biome' do
    it 'suggests desert for hot, dry environment' do
      environment = {
        elevation: 500,
        latitude: 30,
        temperature: 310,
        rainfall: 100,
        slope: 1
      }
      
      biome = validator.suggest_correct_biome(environment)
      expect(biome).to eq('desert')
    end
    
    it 'suggests ice for polar environment' do
      environment = {
        elevation: 0,
        latitude: 85,
        temperature: 250,
        rainfall: 200,
        slope: 0
      }
      
      biome = validator.suggest_correct_biome(environment)
      expect(biome).to eq('ice')
    end
  end
end
```

## Testing Plan

1. **Run tests:**
   ```bash
   bundle exec rspec spec/services/terra_sim/biome_validator_spec.rb
   ```

2. **Manual testing:**
   - Load Earth in monitor view
   - Click "Validate Biomes" button
   - Should show ~80-90% validation score (Civ4/FreeCiv are pretty good)
   - View sample errors to see where placement is unrealistic

3. **Test other bodies:**
   - Mars: Should show errors if forests exist
   - Terraformed planets: Validate planned biome placement

## Success Criteria

- [ ] BiomeValidator service implemented with full constraints
- [ ] All tests passing
- [ ] Monitor view shows validation score
- [ ] Can see validation errors and suggestions
- [ ] Works for Earth, Mars, and other bodies
- [ ] Code committed to git with descriptive message

## Estimated Time

- Service implementation: 2-3 hours
- Controller/view integration: 1 hour
- Tests: 1-2 hours
- Total: 4-6 hours

This provides the foundation for Phase 2 (source comparison) and Phase 3 (Digital Twin testing).
