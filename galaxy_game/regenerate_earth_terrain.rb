#!/usr/bin/env ruby
# Simple script to regenerate terrain for Earth
# Run with: ruby regenerate_earth_terrain.rb

require 'json'

# Mock the necessary classes and methods to regenerate terrain
class MockRails
  def self.logger
    MockLogger.new
  end
end

class MockLogger
  def info(msg)
    puts "[INFO] #{msg}"
  end

  def warn(msg)
    puts "[WARN] #{msg}"
  end
end

# Mock ActiveRecord
class MockGeosphere
  attr_accessor :terrain_map

  def update!(attrs)
    @terrain_map = attrs[:terrain_map]
    puts "Updated geosphere with terrain_map"
  end
end

class MockCelestialBody
  attr_accessor :name, :geosphere, :radius, :surface_temperature, :mass

  def initialize
    @name = 'Earth'
    @geosphere = MockGeosphere.new
    @radius = 6371000
    @surface_temperature = 288
    @mass = 5.972e24
  end

  def create_geosphere!
    @geosphere ||= MockGeosphere.new
  end
end

# Mock the PlanetaryMapGenerator
class MockPlanetaryMapGenerator
  def generate_planetary_map(planet:, sources:, options: {})
    puts "[MockPlanetaryMapGenerator] Generating procedural map for #{planet.name}"

    width = 80
    height = 50

    # Generate varied terrain grid with biome letters
    terrain_grid = Array.new(height) { Array.new(width) }
    biome_counts = Hash.new(0)

    height.times do |y|
      width.times do |x|
        # Create varied terrain based on position
        noise = Math.sin(x * 0.05) * Math.cos(y * 0.05) + rand * 0.3

        biome = case
        when noise < -0.3 then 'o'  # ocean
        when noise < -0.1 then 'g'  # grasslands
        when noise < 0.1 then 'p'   # plains
        when noise < 0.3 then 'f'   # forest
        else 'd'  # desert
        end

        terrain_grid[y][x] = biome
        biome_counts[biome] += 1
      end
    end

    {
      terrain_grid: terrain_grid,
      biome_counts: biome_counts,
      elevation_data: Array.new(height) { Array.new(width, 0.5) },
      strategic_markers: [],
      planet_name: planet.name,
      planet_type: 'terrestrial',
      metadata: {
        generated_at: Time.now.iso8601,
        source_maps: [],
        generation_options: {},
        width: width,
        height: height,
        quality: 'procedural_generated'
      }
    }
  end
end

# Simplified version of the AutomaticTerrainGenerator
class TerrainRegenerator
  def initialize
    @planetary_map_generator = MockPlanetaryMapGenerator.new
  end

  def generate_elevation_data_from_grid(terrain_grid_2d)
    return [] unless terrain_grid_2d.is_a?(Array) && terrain_grid_2d.first.is_a?(Array)

    height = terrain_grid_2d.size
    width = terrain_grid_2d.first.size

    elevation_map = {
      'o' => -200,  # ocean - below sea level
      'd' => 0,     # desert - low elevation
      'p' => 800,   # plains - medium elevation
      'g' => 1000,  # grassland - medium-high
      'f' => 500,   # forest - medium elevation
    }

    elevation_grid = Array.new(height) { Array.new(width) }

    height.times do |y|
      width.times do |x|
        biome = terrain_grid_2d[y][x]
        base_elevation = elevation_map[biome] || 0
        elevation_grid[y][x] = base_elevation + rand(-50..50)
      end
    end

    elevation_grid
  end

  def regenerate_terrain_for_earth
    puts "Regenerating terrain for Earth..."

    body = MockCelestialBody.new

    # Clear existing terrain
    if body.geosphere&.terrain_map
      body.geosphere.terrain_map = nil
      puts "Cleared existing terrain"
    end

    # Generate new terrain
    generator_params = {
      radius: body.radius,
      planet_name: body.name,
      complexity: 0.5,
      elevation_scale: 1.0,
      water_coverage: 0.7,
      temperature: body.surface_temperature
    }

    raw_terrain = @planetary_map_generator.generate_planetary_map(
      planet: body,
      sources: [],
      options: generator_params
    )

    # Transform into expected format
    terrain_data = {
      grid: raw_terrain[:terrain_grid],
      elevation: generate_elevation_data_from_grid(raw_terrain[:terrain_grid]),
      biomes: raw_terrain[:biome_counts],
      resource_grid: [],
      strategic_markers: [],
      resource_counts: {},
      generation_method: 'regenerated',
      generation_date: Time.now,
      source: 'terrain_regeneration',
      planet_properties: {
        radius: body.radius,
        surface_temperature: body.surface_temperature,
        mass: body.mass
      }
    }

    # Store the terrain
    geosphere = body.geosphere || body.create_geosphere!
    geosphere.update!(
      terrain_map: terrain_data
    )

    puts "Terrain regeneration complete!"
    puts "Grid size: #{terrain_data[:grid].size}x#{terrain_data[:grid].first.size}"
    puts "Biome counts: #{terrain_data[:biomes]}"

    # Save to a JSON file for manual import
    output_file = 'regenerated_earth_terrain.json'
    File.write(output_file, JSON.pretty_generate(terrain_data))
    puts "Saved terrain data to #{output_file}"

    terrain_data
  end
end

# Run the regeneration
if __FILE__ == $0
  regenerator = TerrainRegenerator.new
  terrain = regenerator.regenerate_terrain_for_earth

  puts "\nSample terrain grid (first 5x5):"
  5.times do |y|
    row = terrain[:grid][y].first(5).join(' ')
    puts row
  end

  puts "\nSample elevation grid (first 5x5):"
  5.times do |y|
    row = terrain[:elevation][y].first(5).map { |e| e.to_i }.join(' ')
    puts row
  end
end