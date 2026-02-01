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
generator = AIManager::PlanetaryMapGenerator.new
map_data = generator.generate_planetary_map(planet: planet, sources: [], options: {width: 50, height: 25})
puts '✅ Success! Generated terrain for Luna'
puts "Terrain types: #{map_data[:terrain_grid].flatten.uniq.join(', ')}"
puts "Generator: #{map_data[:metadata][:generator]}"
