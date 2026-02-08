# app/services/terra_sim/biome_validator.rb
# Validates biome placement against environmental constraints
# Ensures biomes are realistically positioned based on elevation, temperature, and moisture

module TerraSim
  class BiomeValidator
    BIOME_CONSTRAINTS = {
      'ocean' => {
        elevation: { max: 0 },
        temperature: { min: 273, max: 310 }, # 0°C to 37°C
        rainfall: { min: 0, max: 10000 },
        required: ['hydrosphere']
      },

      'ice' => {
        elevation: { min: -11000, max: 10000 },
        temperature: { max: 273 }, # Below freezing
        rainfall: { min: 0, max: 500 },
        preferred_latitude: { min: 60, max: 90 }  # Polar regions
      },

      'tundra' => {
        elevation: { min: 0, max: 3000 },
        temperature: { min: 253, max: 278 }, # -20°C to 5°C
        rainfall: { min: 100, max: 500 }
      },

      'boreal_forest' => {
        elevation: { min: 0, max: 2000 },
        temperature: { min: 258, max: 288 }, # -15°C to 15°C
        rainfall: { min: 400, max: 1500 }
      },

      'temperate_forest' => {
        elevation: { min: 0, max: 2500 },
        temperature: { min: 268, max: 298 }, # -5°C to 25°C
        rainfall: { min: 500, max: 3000 }
      },

      'tropical_forest' => {
        elevation: { min: 0, max: 1500 },
        temperature: { min: 293, max: 313 }, # 20°C to 40°C
        rainfall: { min: 1500, max: 6000 },
        preferred_latitude: { min: 0, max: 23 }  # Equatorial
      },

      'grassland' => {
        elevation: { min: 0, max: 2000 },
        temperature: { min: 268, max: 308 }, # -5°C to 35°C
        rainfall: { min: 300, max: 900 }
      },

      'savanna' => {
        elevation: { min: 0, max: 1500 },
        temperature: { min: 288, max: 318 }, # 15°C to 45°C
        rainfall: { min: 300, max: 1200 },
        preferred_latitude: { min: 5, max: 20 }  # Subtropical
      },

      'desert' => {
        elevation: { min: 0, max: 3000 },
        temperature: { min: 268, max: 328 }, # -5°C to 55°C
        rainfall: { max: 250 }
      },

      'mountains' => {
        elevation: { min: 2000, max: 10000 },
        temperature: { varies: true }  # Depends on elevation
      },

      'swamp' => {
        elevation: { min: -5, max: 50 },  # Low-lying
        temperature: { min: 288, max: 308 }, # 15°C to 35°C
        rainfall: { min: 1500, max: 4000 },
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
          next unless biome.present? && biome != 'unknown'

          total_tiles += 1
          environment = calculate_environment(x, y)
          validation = validate_single_biome(x, y, biome, environment)

          if validation[:valid]
            valid_tiles += 1
          else
            errors << {
              x: x,
              y: y,
              biome: biome,
              reason: validation[:reason],
              suggested: validation[:suggested_biome],
              environment: environment
            }
          end
        end
      end

      score = total_tiles > 0 ? (valid_tiles.to_f / total_tiles * 100).round(2) : 0

      {
        score: score,
        total_tiles: total_tiles,
        valid_tiles: valid_tiles,
        errors: errors,
        warnings: warnings,
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
          errors << "Elevation too low (#{elev.round}m, min #{constraints[:elevation][:min]}m)"
        end
        if constraints[:elevation][:max] && elev > constraints[:elevation][:max]
          errors << "Elevation too high (#{elev.round}m, max #{constraints[:elevation][:max]}m)"
        end
      end

      # Check temperature
      if constraints[:temperature] && !constraints[:temperature][:varies]
        temp = environment[:temperature]
        if constraints[:temperature][:min] && temp < constraints[:temperature][:min]
          errors << "Too cold (#{temp.round}K, min #{constraints[:temperature][:min]}K)"
        end
        if constraints[:temperature][:max] && temp > constraints[:temperature][:max]
          errors << "Too hot (#{temp.round}K, max #{constraints[:temperature][:max]}K)"
        end
      end

      # Check rainfall
      if constraints[:rainfall]
        rainfall = environment[:rainfall]
        if constraints[:rainfall][:min] && rainfall < constraints[:rainfall][:min]
          errors << "Too dry (#{rainfall.round}mm, min #{constraints[:rainfall][:min]}mm)"
        end
        if constraints[:rainfall][:max] && rainfall > constraints[:rainfall][:max]
          errors << "Too wet (#{rainfall.round}mm, max #{constraints[:rainfall][:max]}mm)"
        end
      end

      # Check latitude preferences
      if constraints[:preferred_latitude]
        lat = environment[:latitude].abs
        min_lat = constraints[:preferred_latitude][:min]
        max_lat = constraints[:preferred_latitude][:max]
        if lat < min_lat || lat > max_lat
          warnings << "Outside preferred latitude range (#{lat.round}°, preferred #{min_lat}°-#{max_lat}°)"
        end
      end

      # Check required features
      if constraints[:required]
        constraints[:required].each do |feature|
          case feature
          when 'hydrosphere'
            unless @hydrosphere&.water_coverage.to_f > 0
              errors << "Requires hydrosphere (no water present)"
            end
          when 'flat_terrain'
            if environment[:slope] > 10
              errors << "Requires flat terrain (slope #{environment[:slope].round}° > 10°)"
            end
          end
        end
      end

      valid = errors.empty?
      suggested_biome = suggest_correct_biome(environment) unless valid

      {
        valid: valid,
        reason: errors.first,
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
        base_rainfall = 300   # Polar
      end

      # Adjust for elevation (orographic effect)
      elev_km = elevation / 1000.0
      elev_factor = 1 + (elev_km * 0.1)  # 10% more rain per km
      base_rainfall *= elev_factor

      # Adjust for temperature (warmer air holds more moisture)
      temp_factor = temperature > 273 ? (temperature - 273) / 25.0 + 0.5 : 0.1
      base_rainfall *= temp_factor

      [base_rainfall, 0].max.round
    end

    # Calculate slope in degrees
    def calculate_slope(x, y, elevation_grid)
      height = elevation_grid.size
      width = elevation_grid.first.size

      # Get neighboring elevations
      neighbors = []
      [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]].each do |dx, dy|
        nx, ny = x + dx, y + dy
        if nx >= 0 && nx < width && ny >= 0 && ny < height
          neighbors << elevation_grid[ny][nx]
        end
      end

      return 0 if neighbors.empty?

      center_elev = elevation_grid[y][x]
      max_change = neighbors.map { |n| (n - center_elev).abs }.max

      # Assume 1km grid spacing for slope calculation
      grid_spacing = 1000.0  # meters
      Math.atan(max_change / grid_spacing) * 180 / Math::PI
    end

    # Suggest appropriate biome for environment
    def suggest_correct_biome(environment)
      # Try each biome and score it
      scores = {}

      BIOME_CONSTRAINTS.each do |biome_name, constraints|
        score = 0
        total_checks = 0

        # Elevation check
        if constraints[:elevation]
          total_checks += 1
          elev = environment[:elevation]
          if constraints[:elevation][:min] && elev >= constraints[:elevation][:min]
            score += 1
          end
          if constraints[:elevation][:max] && elev <= constraints[:elevation][:max]
            score += 1
          end
        end

        # Temperature check
        if constraints[:temperature] && !constraints[:temperature][:varies]
          total_checks += 1
          temp = environment[:temperature]
          if constraints[:temperature][:min] && temp >= constraints[:temperature][:min]
            score += 1
          end
          if constraints[:temperature][:max] && temp <= constraints[:temperature][:max]
            score += 1
          end
        end

        # Rainfall check
        if constraints[:rainfall]
          total_checks += 1
          rainfall = environment[:rainfall]
          if constraints[:rainfall][:min] && rainfall >= constraints[:rainfall][:min]
            score += 1
          end
          if constraints[:rainfall][:max] && rainfall <= constraints[:rainfall][:max]
            score += 1
          end
        end

        scores[biome_name] = total_checks > 0 ? score.to_f / total_checks : 0
      end

      scores.max_by { |biome, score| score }&.first
    end

    # Generate human-readable summary
    def generate_summary(score, errors, warnings)
      if score >= 90
        "Excellent (#{score}% valid) - Biome placement is highly realistic"
      elsif score >= 75
        "Good (#{score}% valid) - Most biomes are appropriately placed"
      elsif score >= 50
        "Fair (#{score}% valid) - Some biomes need adjustment"
      else
        "Poor (#{score}% valid) - Major biome placement issues detected"
      end
    end
  end
end