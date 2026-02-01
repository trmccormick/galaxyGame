#!/usr/bin/env ruby
# tools/demo_existing_maps.rb
# Demonstrate using existing processed maps for planetary generation

require 'json'

class ExistingMapsDemo
  def demonstrate_usage
    puts "🚀 DEMO: Using Existing Maps for Planetary Generation"
    puts "=" * 60

    # Load existing processed maps
    processed_maps = find_processed_maps

    puts "📊 Available Training Data:"
    processed_maps.each do |map_file|
      data = JSON.parse(File.read(map_file))
      planet = data['planet_name'] || 'Unknown'
      width = data.dig('lithosphere', 'width') || data['terrain_grid']&.first&.size || '?'
      height = data.dig('lithosphere', 'height') || data['terrain_grid']&.size || '?'
      biomes = data['biomes']&.flatten&.uniq&.size || 0

      puts "  • #{planet}: #{width}x#{height} (#{biomes} biome types)"
    end

    puts "\n🎯 IMMEDIATE USE CASES:"

    # 1. Earth training data
    earth_data = processed_maps.find { |f| f.include?('earth') }
    if earth_data
      data = JSON.parse(File.read(earth_data))
      puts "\n1️⃣ EARTH TRAINING DATA:"
      puts "   File: #{File.basename(earth_data)}"
      puts "   Grid: #{data['terrain_grid']&.size}x#{data['terrain_grid']&.first&.size}"
      puts "   Biomes: #{data['terrain_grid']&.flatten&.uniq&.join(', ')}"
      puts "   → Perfect for learning Earth-like terrain patterns"
    end

    # 2. Show how to use with planetary generator
    puts "\n2️⃣ INTEGRATION WITH PLANETARY GENERATOR:"
    puts "   # Load training sources"
    puts "   earth_source = JSON.parse(File.read('data/maps/galaxy_game/earth_20260128_221726.json'))"
    puts "   "
    puts "   # Use in generator"
    puts "   generator = AIManager::PlanetaryMapGenerator.new"
    puts "   map = generator.generate_planetary_map("
    puts "     planet: earth_planet,"
    puts "     sources: [earth_source],"
    puts "     options: { width: 80, height: 50 }"
    puts "   )"

    # 3. Show FreeCiv/Civ4 potential
    puts "\n3️⃣ FREECIV & CIV4 MAPS (Need Processing):"
    puts "   FreeCiv Earth: 180x90 → Can extract biomes + elevation"
    puts "   Civ4 Mars: ???x??? → High-quality elevation data"
    puts "   Civ4 Moon: 100x50 → Lunar terrain patterns"
    puts "   → Use: FreecivMapProcessor and Civ4MapProcessor"

    # 4. Show image processing potential
    puts "\n4️⃣ TOPOLOGY IMAGES (Future Enhancement):"
    puts "   12 images available (Mars: 5, Venus: 1, Luna: 1, etc.)"
    puts "   → Could extract elevation using image brightness"
    puts "   → Convert to grayscale → normalize to 0-1 elevation"

    puts "\n✅ READY TO USE:"
    puts "• #{processed_maps.size} processed JSON map#{processed_maps.size == 1 ? '' : 's'} for immediate testing"
    puts "• FreeCiv/Civ4 processors for extracting more data"
    puts "• Image processing pipeline for topology maps"
    puts "• Planetary radius scaling for realistic proportions"
  end

  private

  def find_processed_maps
    Dir.glob('data/maps/galaxy_game/*.json')
  end
end

# Run demo
if __FILE__ == $0
  Dir.chdir(File.expand_path('../..', __FILE__)) # Go to project root
  demo = ExistingMapsDemo.new
  demo.demonstrate_usage
end