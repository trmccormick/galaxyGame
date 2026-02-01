#!/usr/bin/env ruby
# tools/extract_freeciv_training_data.rb
# Extract training data from FreeCiv .sav files for AI learning

require 'json'
require_relative '../galaxy_game/app/services/import/freeciv_map_processor'

class FreecivTrainingDataExtractor
  def initialize
    @processor = Import::FreecivMapProcessor.new
  end

  def extract_training_data
    puts "🔍 EXTRACTING TRAINING DATA FROM FREECIV MAPS"
    puts "=" * 60

    # Find FreeCiv maps
    freeciv_maps = find_freeciv_maps
    puts "📁 Found #{freeciv_maps.size} FreeCiv maps:"

    training_data = []

    freeciv_maps.each do |map_path|
      puts "\n🎮 Processing: #{File.basename(map_path)}"

      begin
        # Load and process the map
        processed_data = @processor.process(map_path)

        # Extract training features
        features = extract_features(processed_data, map_path)

        training_data << features

        puts "   ✅ Extracted: #{features[:biomes].size} biomes, #{features[:elevation_range]} elevation range"
        puts "   📊 Terrain types: #{features[:terrain_types].join(', ')}"

      rescue => e
        puts "   ❌ Error processing #{File.basename(map_path)}: #{e.message}"
      end
    end

    # Save training data
    save_training_data(training_data)

    puts "\n🎯 TRAINING DATA SUMMARY:"
    puts "• Total maps processed: #{training_data.size}"
    puts "• Planets covered: #{training_data.map { |d| d[:planet] }.uniq.join(', ')}"
    puts "• Total biomes: #{training_data.sum { |d| d[:biomes].size }}"
    puts "• Elevation ranges: #{training_data.map { |d| d[:elevation_range] }.uniq.join(', ')}"

    training_data
  end

  private

  def find_freeciv_maps
    Dir.glob('data/maps/freeciv/**/*.sav')
  end

  def extract_features(processed_data, map_path)
    planet = infer_planet_from_path(map_path)

    # Extract biomes (terrain types)
    biomes = extract_biomes(processed_data)

    # Extract elevation data
    elevation_data = extract_elevation(processed_data)

    # Extract strategic features
    strategic_features = extract_strategic_features(processed_data)

    {
      planet: planet,
      source: 'freeciv',
      file: File.basename(map_path),
      biomes: biomes,
      elevation_range: elevation_data[:range],
      elevation_grid: elevation_data[:grid],
      terrain_types: biomes.uniq,
      strategic_features: strategic_features,
      dimensions: processed_data['dimensions'] || {},
      extracted_at: Time.now.iso8601
    }
  end

  def infer_planet_from_path(path)
    filename = File.basename(path).downcase
    if filename.include?('earth')
      'Earth'
    elsif filename.include?('mars')
      'Mars'
    elsif filename.include?('moon') || filename.include?('luna')
      'Moon'
    elsif filename.include?('venus')
      'Venus'
    elsif filename.include?('africa')
      'Earth' # Africa is Earth region
    else
      'Unknown'
    end
  end

  def extract_biomes(data)
    # FreeCiv uses terrain types that map to biomes
    terrain_grid = data.dig('terrain', 'grid') || []
    terrain_grid.flatten.uniq.compact
  end

  def extract_elevation(data)
    elevation_grid = data.dig('elevation', 'grid') || []
    elevations = elevation_grid.flatten.compact

    {
      range: elevations.empty? ? 'unknown' : "#{elevations.min}-#{elevations.max}",
      grid: elevation_grid
    }
  end

  def extract_strategic_features(data)
    # Look for cities, resources, special terrain
    features = []

    # Cities
    if data['cities']
      features << { type: 'cities', count: data['cities'].size }
    end

    # Resources
    if data['resources']
      features << { type: 'resources', count: data['resources'].size }
    end

    # Special terrain (mountains, hills, etc.)
    if data.dig('terrain', 'special_features')
      features.concat(data['terrain']['special_features'])
    end

    features
  end

  def save_training_data(data)
    output_file = 'data/training/freeciv_extracted_training_data.json'

    # Ensure directory exists
    FileUtils.mkdir_p(File.dirname(output_file))

    File.write(output_file, JSON.pretty_generate({
      metadata: {
        source: 'FreeCiv maps',
        extracted_at: Time.now.strftime('%Y-%m-%dT%H:%M:%S%z'),
        maps_processed: data.size,
        planets: data.map { |d| d[:planet] }.uniq
      },
      training_data: data
    }))

    puts "💾 Saved training data to: #{output_file}"
  end
end

# Run extraction
if __FILE__ == $0
  require 'fileutils'

  Dir.chdir(File.expand_path('../..', __FILE__)) # Go to project root

  extractor = FreecivTrainingDataExtractor.new
  extractor.extract_training_data
end