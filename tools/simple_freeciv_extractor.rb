#!/usr/bin/env ruby
# tools/simple_freeciv_extractor.rb
# Simple extraction of training data from FreeCiv .sav files

require 'json'

class SimpleFreecivExtractor
  def extract_training_data
    puts "🔍 SIMPLE FREECIV TRAINING DATA EXTRACTION"
    puts "=" * 50

    freeciv_maps = find_freeciv_maps
    puts "📁 Found #{freeciv_maps.size} FreeCiv maps:"

    training_data = []

    freeciv_maps.each do |map_path|
      puts "\n🎮 Processing: #{File.basename(map_path)}"

      begin
        data = extract_map_data(map_path)
        training_data << data

        puts "   ✅ Extracted: #{data[:biomes].size} biomes, #{data[:dimensions]}"

      rescue => e
        puts "   ❌ Error: #{e.message}"
      end
    end

    save_training_data(training_data)

    puts "\n🎯 SUMMARY:"
    puts "• Maps processed: #{training_data.size}"
    puts "• Planets: #{training_data.map { |d| d[:planet] }.uniq.join(', ')}"
    puts "• Total terrain cells: #{training_data.sum { |d| d[:biomes].size }}"

    training_data
  end

  private

  def find_freeciv_maps
    Dir.glob('data/maps/freeciv/**/*.sav')
  end

  def extract_map_data(file_path)
    content = File.read(file_path)

    # Extract dimensions
    width = content.match(/width=(\d+)/)&.[](1)&.to_i
    height = content.match(/height=(\d+)/)&.[](1)&.to_i

    # If no explicit dimensions, infer from terrain data
    if !width || !height
      terrain_lines = content.scan(/^t\d+="([^"]+)"/)
      if terrain_lines.any?
        height = terrain_lines.size
        width = terrain_lines.first.first.size
      end
    end

    # Extract terrain data (lines starting with t followed by number)
    terrain_lines = content.scan(/^t\d+="([^"]+)"/)

    # Flatten all terrain data into one big string
    terrain_string = terrain_lines.flatten.join

    # Convert to 2D array
    biomes = []
    if width > 0 && height > 0
      terrain_string.chars.each_slice(width) do |row|
        biomes << row
      end
      biomes = biomes.first(height) if biomes.size > height
    end

    # Infer planet from filename
    planet = infer_planet(file_path)

    # Count biome types
    biome_counts = biomes.flatten.group_by(&:itself).transform_values(&:size)

    {
      planet: planet,
      source: 'freeciv_sav',
      file: File.basename(file_path),
      dimensions: "#{width}x#{height}",
      biomes: biomes,
      biome_counts: biome_counts,
      terrain_types: biome_counts.keys,
      extracted_at: Time.now.strftime('%Y-%m-%dT%H:%M:%S%z')
    }
  end

  def infer_planet(file_path)
    filename = File.basename(file_path).downcase
    if filename.include?('earth')
      'Earth'
    elsif filename.include?('mars')
      'Mars'
    elsif filename.include?('africa')
      'Earth' # Africa is Earth region
    else
      'Unknown'
    end
  end

  def save_training_data(data)
    output_file = 'data/training/simple_freeciv_training_data.json'

    FileUtils.mkdir_p(File.dirname(output_file))

    File.write(output_file, JSON.pretty_generate({
      metadata: {
        source: 'FreeCiv .sav files (simple extraction)',
        extracted_at: Time.now.strftime('%Y-%m-%dT%H:%M:%S%z'),
        maps_processed: data.size,
        planets: data.map { |d| d[:planet] }.uniq
      },
      training_data: data
    }))

    puts "💾 Saved to: #{output_file}"
  end
end

# Run extraction
if __FILE__ == $0
  require 'fileutils'

  Dir.chdir(File.expand_path('../..', __FILE__)) # Go to project root

  extractor = SimpleFreecivExtractor.new
  extractor.extract_training_data
end