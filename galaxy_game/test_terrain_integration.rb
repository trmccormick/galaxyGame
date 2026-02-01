puts '🌍 Testing Terrain Integration'

class MockPlanet
  attr_reader :name, :type, :radius
  def initialize(name, type='airless', radius=1737000)
    @name = name
    @type = type
    @radius = radius
  end
end

planet = MockPlanet.new('Luna')

# Test the terrain generator directly
puts 'Testing MultiBodyTerrainGenerator directly...'
terrain_gen = Terrain::MultiBodyTerrainGenerator.new
terrain_data = terrain_gen.generate_terrain('luna', width: 50, height: 25)
puts "Terrain data keys: #{terrain_data.keys.join(', ')}"
puts "Grid present: #{terrain_data[:grid].present?}"
puts "Elevation present: #{terrain_data[:elevation].present?}"
puts "Generator: #{terrain_data[:generator]}"

puts 'Testing planetary map generator...'
generator = AIManager::PlanetaryMapGenerator.new
map_data = generator.generate_planetary_map(planet: planet, sources: [], options: {width: 50, height: 25})
puts '✅ Success! Generated terrain for Luna'
puts "Generator: '#{map_data[:metadata][:generator]}'"
