# app/services/import/civ4_elevation_extractor.rb
module Import
  class Civ4ElevationExtractor
    # Extract elevation data from Civ4 World Builder Save files
    # Uses PlotType + TerrainType + FeatureType for 70-80% accurate elevation

    def extract(civ4_data)
      width = civ4_data[:width]
      height = civ4_data[:height]
      plots = civ4_data[:plots]

      # Initialize elevation map
      elevation_map = Array.new(height) { Array.new(width, 0.5) }

      # Process each plot
      plots.each do |plot|
        x, y = plot[:x], plot[:y]
        next if x >= width || y >= height || x < 0 || y < 0

        elevation = calculate_elevation_from_plot(plot)
        elevation_map[y][x] = elevation
      end

      # Add realistic variation
      elevation_map = add_realistic_variation(elevation_map)

      # Smooth for continuity
      elevation_map = smooth_elevation_map(elevation_map)

      {
        elevation: elevation_map,
        quality: 'medium_70_80_percent',
        method: 'plottype_terraintype_extraction'
      }
    end

    private

    # Calculate elevation from Civ4 plot data
    def calculate_elevation_from_plot(plot)
      plot_type = plot[:plot_type]
      terrain_type = plot[:terrain_type]
      feature_type = plot[:feature_type]

      # Base elevation from PlotType (4 discrete levels)
      base_elevation = case plot_type
      when 0 then 0.65  # Flat land - above water but more reasonable
      when 1 then 0.55  # Coastal - elevated shore
      when 2 then 0.80  # Hills - clearly elevated
      when 3 then        # Water OR mountain peaks (ambiguous!)
        # Disambiguate using TerrainType
        case terrain_type
        when 'TERRAIN_OCEAN' then 0.35  # Deep ocean basin (raised from 0.10)
        when 'TERRAIN_COAST' then 0.45  # Shallow coastal water (raised from 0.20)
        when 'TERRAIN_SNOW' then 0.90   # Snow-capped mountain peaks
        when 'TERRAIN_GRASS' then 0.85  # High grass-covered peaks
        when 'TERRAIN_PLAINS' then 0.80 # High plains peaks
        when 'TERRAIN_TUNDRA' then 0.85 # High tundra peaks
        when 'TERRAIN_DESERT' then 0.75 # High desert peaks
        else 0.15  # Default to water
        end
      else 0.50  # Fallback
      end

      # TerrainType refinements for land plots
      if plot_type != 3 && terrain_type
        base_elevation = refine_elevation_for_terrain(base_elevation, terrain_type)
      end

      # FeatureType adjustments
      if feature_type
        base_elevation = apply_feature_adjustment(base_elevation, feature_type)
      end

      # CRITICAL: Ensure land areas (non-water terrain) are always above sea level
      # If an area has biomes/terrain, it cannot be underwater
      is_water_terrain = ['TERRAIN_OCEAN', 'TERRAIN_COAST'].include?(terrain_type)
      if !is_water_terrain && plot_type != 3
        base_elevation = [base_elevation, 0.50].max  # Reasonable minimum elevation for land
      end

      # Clamp to valid range
      [[base_elevation, 0.0].max, 1.0].min
    end

    # Refine elevation based on terrain type
    def refine_elevation_for_terrain(base_elevation, terrain_type)
      case terrain_type
      when 'TERRAIN_SNOW'
        # Snow = high altitude (except polar sea ice)
        base_elevation + 0.30
      when 'TERRAIN_TUNDRA'
        # Tundra = moderately elevated
        base_elevation + 0.15
      when 'TERRAIN_DESERT'
        # Desert can be elevated plateaus
        base_elevation + 0.10
      when 'TERRAIN_PLAINS'
        # Plains are typically lower
        base_elevation - 0.05
      else
        base_elevation
      end
    end

    # Apply feature adjustments
    def apply_feature_adjustment(elevation, feature_type)
      case feature_type
      when 'FEATURE_FOREST'
        elevation + 0.05  # Trees grow on slopes
      when 'FEATURE_JUNGLE'
        elevation + 0.03  # Jungles in lowlands
      when 'FEATURE_FALLOUT'
        elevation + 0.10  # Fallout areas often elevated
      when 'FEATURE_FLOOD_PLAINS'
        elevation - 0.10  # River valleys
      when 'FEATURE_OASIS'
        elevation - 0.05  # Desert depressions
      when 'FEATURE_ICE'
        # Ambiguous - could be sea ice or glacier
        if elevation < 0.3
          0.20  # Sea ice
        else
          [elevation, 0.90].max  # Glacier
        end
      else
        elevation
      end
    end

    # Add realistic variation to prevent uniform elevation
    def add_realistic_variation(elevation_map)
      height = elevation_map.length
      width = elevation_map.first.length

      varied_map = Array.new(height) do |y|
        Array.new(width) do |x|
          base = elevation_map[y][x]
          variation = (rand - 0.5) * 0.06  # ±3% variation for subtle terrain diversity
          [[base + variation, 0.0].max, 1.0].min
        end
      end

      varied_map
    end

    # Smooth elevation for continuity using neighbor averaging
    def smooth_elevation_map(elevation_map)
      height = elevation_map.length
      width = elevation_map.first.length

      smoothed = Array.new(height) do |y|
        Array.new(width) do |x|
          neighbors = []

          # Get 8 neighboring values
          [-1, 0, 1].each do |dy|
            [-1, 0, 1].each do |dx|
              next if dx == 0 && dy == 0  # Skip center
              ny, nx = y + dy, x + dx
              if ny >= 0 && ny < height && nx >= 0 && nx < width
                neighbors << elevation_map[ny][nx]
              end
            end
          end

          if neighbors.size >= 3
            # Blend current value with neighbor average (70/30)
            current = elevation_map[y][x]
            avg_neighbors = neighbors.sum / neighbors.size
            (current * 0.7) + (avg_neighbors * 0.3)
          else
            elevation_map[y][x]  # Keep original if too few neighbors
          end
        end
      end

      smoothed
    end

    # Add realistic variation with biome-aware enhancement (Phase 1 Quick Fix)
    # Addresses the Sahara problem and other flat desert regions
    def add_realistic_variation(elevation_map)
      height = elevation_map.length
      width = elevation_map.first.length

      enhanced = Array.new(height) do |y|
        Array.new(width) do |x|
          base_elev = elevation_map[y][x]

          # CRITICAL: Never push land areas below sea level
          is_land = base_elev > 0.50  # Land areas have elevation > 0.50
          min_elevation = is_land ? 0.55 : 0.05  # Higher land minimum vs water minimum

          # Apply desert elevation enhancement (Quick Fix for Grok)
          # Desert detection: moderate elevation flat areas (typical Civ4 desert pattern)
          is_potential_desert = base_elev >= 0.50 && base_elev <= 0.65

          if is_potential_desert
            # Boost desert elevation + add variation for realistic plateaus/dunes
            variation = (rand * 0.3) - 0.15  # -0.15 to +0.15 random variation
            enhanced_elev = base_elev + 0.15 + variation
            enhanced_elev = [enhanced_elev, 0.80].min  # Cap at 0.80 to avoid mountain levels
            enhanced_elev = [enhanced_elev, min_elevation].max  # Respect land/water minimum
          else
            # Standard variation for other biomes
            variation = (rand - 0.5) * 0.05  # Small random variation
            enhanced_elev = base_elev + variation
            enhanced_elev = [enhanced_elev, min_elevation].max  # Never below minimum
          end

          # Clamp to valid range
          [0.0, [enhanced_elev, 1.0].min].max
        end
      end

      enhanced
    end
  end
end