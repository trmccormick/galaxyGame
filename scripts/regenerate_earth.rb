# Regenerate Sol bodies terrain using NASA GeoTIFF data with improved downsampling

['Earth', 'Luna', 'Mars'].each do |name|
  body = CelestialBodies::CelestialBody.find_by(name: name)
  if body
    puts "Regenerating #{name}..."
    
    # Clear existing terrain to force regeneration
    body.geosphere&.update(terrain_map: nil)
    
    # Regenerate using NASA data
    generator = StarSim::AutomaticTerrainGenerator.new
    generator.generate_terrain_for_body(body)
    
    body.reload
    if body.geosphere&.terrain_map
      tm = body.geosphere.terrain_map
      puts "  Source: #{tm['source']}"
      if tm['elevation'] && tm['elevation'].first
        flat = tm['elevation'].flatten.compact
        puts "  Elevation range: #{flat.min.round(1)} to #{flat.max.round(1)}"
        puts "  Grid: #{tm['elevation'].first.size} x #{tm['elevation'].size}"
        puts "  Unique values: #{flat.uniq.size} / #{flat.size}"
      end
    end
  else
    puts "#{name} not found"
  end
end
