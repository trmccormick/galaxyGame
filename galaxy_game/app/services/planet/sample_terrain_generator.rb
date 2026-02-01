# app/services/planet/sample_terrain_generator.rb

module Planet
  class SampleTerrainGenerator
    # Color mapping for terrain types (matches canvas renderer)
    TERRAIN_COLORS = {
      ocean: '#0066cc',
      deep_sea: '#003366',
      arctic: '#ffffff',
      tundra: '#cccccc',
      grasslands: '#66cc66',
      plains: '#99cc99',
      forest: '#006600',
      jungle: '#004400',
      desert: '#ffcc66',
      mountains: '#8b4513'
    }.freeze

    def self.generate_earth_sample(width: 100, height: 50)
      puts "🌍 Generating sample Earth-like terrain (#{width}x#{height})..."

      grid = Array.new(height) do |y|
        Array.new(width) do |x|
          # Convert tile coordinates to latitude/longitude for realistic terrain
          lat = ((y.to_f / height) - 0.5) * 180  # -90 to +90 degrees
          lon = ((x.to_f / width) - 0.5) * 360   # -180 to +180 degrees

          generate_terrain_for_coords(lat, lon)
        end
      end

      terrain_data = {
        grid: grid,
        width: width,
        height: height,
        generated_at: Time.current.iso8601,
        generator: 'SampleTerrainGenerator',
        planet_type: 'earth_like'
      }

      puts "✅ Generated #{width}x#{height} terrain grid with #{grid.flatten.uniq.size} terrain types"
      terrain_data
    end

    def self.generate_mars_sample(width: 100, height: 50)
      puts "🔴 Generating sample Mars-like terrain (#{width}x#{height})..."

      grid = Array.new(height) do |y|
        Array.new(width) do |x|
          lat = ((y.to_f / height) - 0.5) * 180
          lon = ((x.to_f / width) - 0.5) * 360

          generate_mars_terrain_for_coords(lat, lon)
        end
      end

      terrain_data = {
        grid: grid,
        width: width,
        height: height,
        generated_at: Time.current.iso8601,
        generator: 'SampleTerrainGenerator',
        planet_type: 'mars_like'
      }

      puts "✅ Generated Mars terrain: #{width}x#{height}"
      terrain_data
    end

    def self.generate_luna_sample(width: 100, height: 50)
      puts "🌙 Generating sample Luna-like terrain (#{width}x#{height})..."

      grid = Array.new(height) do |y|
        Array.new(width) do |x|
          lat = ((y.to_f / height) - 0.5) * 180
          lon = ((x.to_f / width) - 0.5) * 360

          generate_luna_terrain_for_coords(lat, lon)
        end
      end

      terrain_data = {
        grid: grid,
        width: width,
        height: height,
        generated_at: Time.current.iso8601,
        generator: 'SampleTerrainGenerator',
        planet_type: 'luna_like'
      }

      puts "✅ Generated Luna terrain: #{width}x#{height}"
      terrain_data
    end

    private

    def self.generate_terrain_for_coords(lat, lon)
      abs_lat = lat.abs

      # Polar regions (Arctic/Antarctic)
      if abs_lat > 75
        return :arctic
      elsif abs_lat > 65
        return :tundra
      end

      # Ocean vs land (simplified continental shapes)
      # Use latitude and some noise to create continents
      continent_noise = Math.sin(lon * 0.01745) * Math.cos(lat * 0.01745)  # 0.01745 = PI/180
      continent_modifier = Math.sin(lon * 0.0349) * 0.3  # Add some east-west variation (PI/90)
      is_continent = (continent_noise + continent_modifier) > -0.2

      unless is_continent
        # Ocean terrain with depth variation
        if abs_lat > 60
          return :deep_sea
        else
          return :ocean
        end
      end

      # Land terrain based on latitude bands (climate zones)
      case abs_lat
      when 0..20  # Tropical/Equatorial
        case rand(100)
        when 0..40 then :jungle
        when 40..70 then :grasslands
        when 70..85 then :forest
        else :plains
        end
      when 20..35  # Subtropical
        case rand(100)
        when 0..30 then :grasslands
        when 30..60 then :forest
        when 60..80 then :plains
        else :desert
        end
      when 35..50  # Temperate
        case rand(100)
        when 0..25 then :forest
        when 25..50 then :plains
        when 50..70 then :grasslands
        else :mountains
        end
      when 50..65  # Subarctic/Boreal
        case rand(100)
        when 0..40 then :forest
        when 40..70 then :plains
        else :tundra
        end
      else  # Should not reach here due to polar check above
        :tundra
      end
    end

    def self.generate_mars_terrain_for_coords(lat, lon)
      abs_lat = lat.abs

      # Mars polar ice caps
      if abs_lat > 80
        return :arctic
      end

      # Mars has very little surface water, mostly desert with some variation
      case rand(100)
      when 0..5 then :mountains    # Tharsis region features
      when 5..20 then :desert      # Vast deserts
      when 20..30 then :plains     # Plains/valleys
      when 30..35 then :arctic     # Polar ice
      else :desert                 # Default to desert
      end
    end

    def self.generate_luna_terrain_for_coords(lat, lon)
      # Moon has no atmosphere, water, or vegetation
      # Terrain is primarily rock/regolith with craters

      case rand(100)
      when 0..10 then :mountains   # Highlands/mountains
      when 10..30 then :arctic     # Ice deposits in permanently shadowed craters
      else :desert                 # Lunar regolith (appears gray/desert-like)
      end
    end
  end
end