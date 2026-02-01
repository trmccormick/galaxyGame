require_relative 'app/services/terrain_analysis/terrain_decomposition_service'

data = {
  'width' => 3,
  'height' => 3,
  'grid' => [
    [:deep_sea, :coast, :plains],
    [:grasslands, :forest, :rocky],
    [:mountains, :tundra, :arctic]
  ]
}

service = TerrainAnalysis::TerrainDecompositionService.new(data)

# Debug the layers
layers = service.send(:separate_into_layers, data['grid'], 3, 3)
puts "hydrological layer: #{layers['hydrological']}"
water_volume = service.send(:calculate_initial_water_volume, layers['hydrological'])
puts "calculated water_volume: #{water_volume}"

# Simulate decompose
elevation_map = service.send(:generate_elevation_map, data['grid'], 3, 3)
decomposed_map = {
  'width' => 3,
  'height' => 3,
  'elevation' => elevation_map,
  'water_volume' => water_volume,
  'layers' => layers,
  'biome_counts' => {}
}
puts "decomposed_map water_volume: #{decomposed_map['water_volume']}"

hydro_service = TerrainAnalysis::HydrosphereVolumeService.new(decomposed_map)
updated = hydro_service.update_water_bodies
puts "updated water_volume: #{updated['water_volume']}"

result = service.decompose

puts "final water_volume: #{result['water_volume']}"