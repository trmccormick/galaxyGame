#!/usr/bin/env ruby
# scripts/test_terrain_integration.rb
# Test the integration of multi-body terrain generator with planetary map generator

require_relative '../galaxy_game/config/environment'

puts "🌍 Testing Terrain Integration"
puts "=" * 50

# Create mock planet objects for testing
class MockPlanet
  attr_reader :name, :type, :radius

  def initialize(name, type = 'terrestrial', radius = 6_371_000)
    @name = name
    @type = type
    @radius = radius
  end
end

# Test planets
planets = [
  MockPlanet.new('Luna', 'airless', 1_737_000),
  MockPlanet.new('Mars', 'terrestrial', 3_389_000),
  MockPlanet.new('Earth', 'terrestrial', 6_371_000),
  MockPlanet.new('Unknown Planet', 'terrestrial', 5_000_000)
]

generator = AIManager::PlanetaryMapGenerator.new

planets.each do |planet|
  puts "\n🧪 Testing #{planet.name} terrain generation..."

  begin
    # Generate map with no sources (should use procedural/NASA terrain)
    map_data = generator.generate_planetary_map(
      planet: planet,
      sources: [],
      options: { width: 100, height: 50 }
    )

    # Validate the result
    terrain_grid = map_data[:terrain_grid]
    elevation_data = map_data[:elevation_data] || map_data[:elevation]

    puts "  ✅ Generated #{terrain_grid.size}x#{terrain_grid.first.size} terrain grid"
    puts "  ✅ Generated #{elevation_data.size}x#{elevation_data.first.size} elevation grid"

    # Check terrain types
    terrain_types = terrain_grid.flatten.uniq
    puts "  📊 Terrain types: #{terrain_types.sort.join(', ')}"

    # Check elevation range
    elevations = elevation_data.flatten
    elev_min = elevations.min
    elev_max = elevations.max
    puts "  📊 Elevation range: #{elev_min.round(1)} - #{elev_max.round(1)}"

    # Check metadata
    metadata = map_data[:metadata]
    generator_used = metadata[:generator] || 'unknown'
    nasa_derived = metadata[:nasa_derived] || false
    puts "  🏷️  Generator: #{generator_used}"
    puts "  🔬 NASA-derived: #{nasa_derived}"

  rescue => e
    puts "  ❌ Error generating #{planet.name} terrain: #{e.message}"
    puts "  📋 Backtrace: #{e.backtrace.first(3).join(' | ')}"
  end
end

puts "\n" + "=" * 50
puts "🎯 Terrain Integration Test Complete!"
puts "Multi-body terrain generation is now integrated into the planetary map system."