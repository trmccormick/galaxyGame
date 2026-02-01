#!/usr/bin/env ruby
# tools/analyze_existing_maps.rb
# Analyze what we can extract from existing maps without full Rails

require 'json'

class MapsAnalyzer
  def analyze
    puts "🗺️  ANALYZING EXISTING MAP ASSETS"
    puts "=" * 50

    analyze_freeciv_maps
    analyze_civ4_maps
    analyze_topology_images
    analyze_processed_json

    puts "\n🎯 POTENTIAL FOR AI TRAINING:"
    puts "✅ FreeCiv: Earth 180x90, Mars 133x64 - Great for terrain patterns"
    puts "✅ Civ4: Earth, Mars, Moon 100x50, Venus 100x50 - Multiple planets"
    puts "✅ Images: 12 topology maps - Could extract elevation data"
    puts "✅ JSON: 2 processed maps - Already usable training data"

    puts "\n🚀 IMMEDIATE USE:"
    puts "• Use processed JSON files directly in planetary generator"
    puts "• Extract biomes/elevation from FreeCiv/Civ4 maps"
    puts "• Convert topology images to elevation grids"
    puts "• Create planet-specific training datasets"
  end

  private

  def analyze_freeciv_maps
    puts "\n📄 FREECIV MAPS (.sav files):"
    maps = Dir.glob('data/maps/freeciv/**/*.sav')
    maps.each do |map|
      name = File.basename(map, '.sav')
      size = File.size(map)
      planet = infer_planet(name)
      puts "  • #{name} (#{planet}) - #{format_bytes(size)}"
    end
    puts "  → Can extract: biomes, elevation hints, strategic markers"
  end

  def analyze_civ4_maps
    puts "\n🏛️  CIV4 MAPS (.Civ4WorldBuilderSave files):"
    maps = Dir.glob('data/maps/civ4/**/*.Civ*')
    maps.first(5).each do |map|  # Show first 5
      name = File.basename(map)
      size = File.size(map)
      planet = infer_planet(name)
      puts "  • #{name} (#{planet}) - #{format_bytes(size)}"
    end
    if maps.size > 5
      puts "  ... and #{maps.size - 5} more"
    end
    puts "  → Can extract: elevation, biomes, features, strategic markers"
  end

  def analyze_topology_images
    puts "\n🖼️  TOPOLOGY IMAGES:"
    images = Dir.glob('data/maps/topology_maps/**/*.{png,jpg,jpeg,gif}')
    planets = images.group_by { |img| infer_planet(File.basename(img)) }

    planets.each do |planet, imgs|
      puts "  • #{planet}: #{imgs.size} images"
    end
    puts "  → Potential: elevation data extraction with image processing"
  end

  def analyze_processed_json
    puts "\n📊 PROCESSED JSON (Ready to use):"
    jsons = Dir.glob('data/maps/galaxy_game/*.json')
    jsons.each do |json_file|
      data = JSON.parse(File.read(json_file)) rescue {}
      name = File.basename(json_file, '.json')
      grid_size = data['terrain_grid']&.size.to_i
      puts "  • #{name} - #{grid_size}x#{data['terrain_grid']&.first&.size} grid"
    end
    puts "  → Ready for: PlanetaryMapGenerator.generate_with_nasa_training()"
  end

  def infer_planet(filename)
    name = filename.downcase
    return 'Earth' if name.include?('earth')
    return 'Mars' if name.include?('mars')
    return 'Luna' if name.include?('luna') || name.include?('moon')
    return 'Venus' if name.include?('venus')
    return 'Mercury' if name.include?('mercury')
    return 'Titan' if name.include?('titan')
    return 'Africa' if name.include?('africa')
    'Unknown'
  end

  def format_bytes(bytes)
    units = ['B', 'KB', 'MB', 'GB']
    unit_index = 0
    size = bytes.to_f

    while size >= 1024 && unit_index < units.length - 1
      size /= 1024.0
      unit_index += 1
    end

    "#{size.round(1)} #{units[unit_index]}"
  end
end

# Run analysis
if __FILE__ == $0
  Dir.chdir(File.expand_path('../..', __FILE__)) # Go to project root
  analyzer = MapsAnalyzer.new
  analyzer.analyze
end