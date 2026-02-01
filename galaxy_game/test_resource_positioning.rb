#!/usr/bin/env ruby
# test_resource_positioning.rb
# Test the AI resource positioning service with planetary map generation

require_relative '../config/environment'
require_relative '../lib/ai_manager/planetary_map_generator'

puts "Testing AI Resource Positioning Service..."

# Create a mock planet object
class MockPlanet
  attr_accessor :name, :type, :id

  def initialize(name, type = 'terrestrial')
    @name = name
    @type = type
    @id = rand(1000)
  end
end

# Test 1: Generate procedural map with resource positioning
puts "\n=== Test 1: Procedural Map with Resources ==="
planet = MockPlanet.new('TestPlanet')
generator = AIManager::PlanetaryMapGenerator.new

map_data = generator.generate_planetary_map(
  planet: planet,
  sources: [],
  options: { width: 20, height: 15 }
)

puts "Generated map dimensions: #{map_data[:metadata][:width]}x#{map_data[:metadata][:height]}"
puts "Terrain grid size: #{map_data[:terrain_grid]&.size}x#{map_data[:terrain_grid]&.first&.size}"
puts "Elevation grid size: #{map_data[:elevation]&.size}x#{map_data[:elevation]&.first&.size}"
puts "Resource grid present: #{map_data[:resource_grid] ? 'YES' : 'NO'}"
puts "Resource counts: #{map_data[:resource_counts] || 'None'}"
puts "Strategic markers: #{map_data[:strategic_markers]&.size || 0}"

# Test 2: Test resource positioning service directly
puts "\n=== Test 2: Direct Resource Positioning Service Test ==="
resource_service = AIManager::ResourcePositioningService.new

# Create test map data
test_map = {
  elevation: Array.new(10) { Array.new(10) { 0.5 } },  # 10x10 grid at mid elevation
  terrain: Array.new(10) { Array.new(10) { 'plains' } }  # All plains
}

# Add some variation
test_map[:elevation][2][3] = 0.8  # Mountain
test_map[:elevation][7][8] = 0.2  # Lowland
test_map[:terrain][2][3] = 'mountains'
test_map[:terrain][7][8] = 'lowlands'

enhanced_map = resource_service.place_resources_on_map(test_map, planet_name: 'TestPlanet')

puts "Test map enhanced with resources:"
puts "Resource grid size: #{enhanced_map[:resource_grid]&.size}x#{enhanced_map[:resource_grid]&.first&.size}"
puts "Resource counts: #{enhanced_map[:resource_counts]}"
puts "Strategic markers: #{enhanced_map[:strategic_markers]&.size}"

# Test 3: Test with Civ4-style source data
puts "\n=== Test 3: Civ4-style Source Data Test ==="
civ4_source = {
  type: 'civ4',
  filename: 'test_civ4_map',
  data: {
    biomes: [
      ['ocean', 'ocean', 'plains', 'mountains'],
      ['ocean', 'plains', 'hills', 'mountains'],
      ['plains', 'plains', 'hills', 'peaks'],
      ['desert', 'plains', 'hills', 'mountains']
    ],
    lithosphere: {
      elevation: [
        [0.2, 0.25, 0.6, 0.85],
        [0.22, 0.55, 0.7, 0.9],
        [0.5, 0.58, 0.75, 0.95],
        [0.4, 0.6, 0.72, 0.88]
      ]
    }
  }
}

map_with_civ4 = generator.generate_planetary_map(
  planet: planet,
  sources: [civ4_source],
  options: { width: 4, height: 4 }
)

puts "Civ4-style map generated:"
puts "Resource grid present: #{map_with_civ4[:resource_grid] ? 'YES' : 'NO'}"
puts "Resource counts: #{map_with_civ4[:resource_counts] || 'None'}"
puts "Strategic markers: #{map_with_civ4[:strategic_markers]&.size || 0}"

puts "\n=== Resource Positioning Tests Complete ==="