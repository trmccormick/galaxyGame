# spec/support/disable_terrain_generation.rb
RSpec.configure do |config|
  config.before(:each) do
    # Stub AutomaticTerrainGenerator for all tests
    # This prevents expensive terrain generation during test runs
    allow_any_instance_of(StarSim::AutomaticTerrainGenerator)
      .to receive(:generate_terrain_for_body)
      .and_return(true)
    
    allow_any_instance_of(StarSim::AutomaticTerrainGenerator)
      .to receive(:generate_base_terrain)
      .and_return({
        grid: Array.new(90) { Array.new(180, 'p') },
        elevation: Array.new(90) { Array.new(180, 0.5) },
        biomes: Array.new(90) { Array.new(180, 'plains') },
        resource_grid: Array.new(90) { Array.new(180, nil) },
        strategic_markers: [],  # Empty array instead of 2D array
        resource_counts: {},
        width: 180,
        height: 90,
        metadata: {
          source: 'test_stub',
          generation_method: 'stubbed_for_testing'
        }
      })

    # Also stub PlanetaryMapGenerator to prevent pattern loading
    allow_any_instance_of(AIManager::PlanetaryMapGenerator)
      .to receive(:generate_planetary_map_with_patterns)
      .and_return({
        elevation: Array.new(90) { Array.new(180, 0.5) },
        biomes: Array.new(90) { Array.new(180, 'plains') },
        width: 180,
        height: 90
      })
  end
end