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
result = service.decompose

puts "water_volume: #{result['water_volume']}"
puts "layers keys: #{result['layers']&.keys}"