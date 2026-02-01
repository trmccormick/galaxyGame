#!/usr/bin/env ruby
# tools/process_existing_maps.rb
# Process all existing FreeCiv and Civ4 maps into AI training data

require_relative '../config/environment'

class ExistingMapsProcessor
  def initialize
    @freeciv_processor = Import::FreecivMapProcessor.new
    @civ4_processor = Import::Civ4MapProcessor.new
    @output_dir = Rails.root.join('data', 'maps', 'processed_training_data')
    FileUtils.mkdir_p(@output_dir)
  end

  def process_all_maps
    puts "🔍 Scanning for existing maps..."

    freeciv_maps = find_freeciv_maps
    civ4_maps = find_civ4_maps

    puts "📊 Found #{freeciv_maps.size} FreeCiv maps and #{civ4_maps.size} Civ4 maps"

    processed_count = 0

    # Process FreeCiv maps
    freeciv_maps.each do |map_path|
      next unless process_single_map(map_path, :freeciv)
      processed_count += 1
    end

    # Process Civ4 maps
    civ4_maps.each do |map_path|
      next unless process_single_map(map_path, :civ4)
      processed_count += 1
    end

    puts "✅ Successfully processed #{processed_count} maps into training data"
    puts "📁 Training data saved to: #{@output_dir}"

    create_training_index
  end

  def process_single_map(map_path, format)
    map_name = File.basename(map_path, '.*')
    planet_name = infer_planet_name(map_name)

    puts "🔄 Processing #{format.upcase}: #{map_name} (#{planet_name})"

    begin
      # Process the map
      case format
      when :freeciv
        data = @freeciv_processor.process(map_path)
      when :civ4
        data = @civ4_processor.process(map_path)
      end

      # Add metadata
      data[:planet_name] = planet_name
      data[:source_format] = format
      data[:original_file] = map_path
      data[:processed_at] = Time.current.iso8601

      # Save processed data
      output_file = @output_dir.join("#{planet_name.downcase}_#{format}_#{map_name}.json")
      File.write(output_file, JSON.pretty_generate(data))

      puts "  ✅ Saved: #{output_file.basename}"
      true

    rescue => e
      puts "  ❌ Failed: #{e.message}"
      false
    end
  end

  def create_training_index
    index_file = @output_dir.join('training_index.json')

    training_sources = Dir.glob(@output_dir.join('*.json')).map do |file|
      data = JSON.parse(File.read(file))
      {
        planet: data['planet_name'],
        format: data['source_format'],
        file: File.basename(file),
        dimensions: "#{data.dig('lithosphere', 'width')}x#{data.dig('lithosphere', 'height')}",
        quality: data.dig('lithosphere', 'quality') || data.dig('metadata', 'extraction_quality'),
        biomes_count: data['biomes']&.flatten&.uniq&.size || 0,
        strategic_markers: data['strategic_markers']&.size || 0
      }
    end

    index_data = {
      generated_at: Time.current.iso8601,
      total_sources: training_sources.size,
      sources: training_sources,
      usage: "Use these files with PlanetaryMapGenerator.generate_with_nasa_training()"
    }

    File.write(index_file, JSON.pretty_generate(index_data))
    puts "📋 Created training index: #{index_file.basename}"
  end

  private

  def find_freeciv_maps
    Dir.glob(Rails.root.join('data', 'maps', 'freeciv', '**', '*.sav'))
  end

  def find_civ4_maps
    Dir.glob(Rails.root.join('data', 'maps', 'civ4', '**', '*.Civ*'))
  end

  def infer_planet_name(map_name)
    map_name.downcase.tap do |name|
      return 'Earth' if name.include?('earth')
      return 'Mars' if name.include?('mars')
      return 'Luna' if name.include?('luna') || name.include?('moon')
      return 'Venus' if name.include?('venus')
      return 'Mercury' if name.include?('mercury')
      return 'Titan' if name.include?('titan')
      return name.split(/[_\-\s]/).first.capitalize # Fallback to first word
    end
  end
end

# Command line usage
if __FILE__ == $0
  puts "🚀 Processing Existing Maps for AI Training Data"
  puts "=" * 50

  processor = ExistingMapsProcessor.new
  processor.process_all_maps

  puts "\n🎯 Next Steps:"
  puts "1. Review the processed training data in data/maps/processed_training_data/"
  puts "2. Use with: PlanetaryMapGenerator.generate_with_nasa_training()"
  puts "3. Test planetary generation with: ruby test_planetary_generation_with_resources.rb"
end