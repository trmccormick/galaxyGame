# lib/tasks/terrain_sample.rake

namespace :terrain do
  desc "Generate and store sample terrain data for planetary bodies"
  task :generate_samples, [:planet_name] => :environment do |t, args|
    planet_name = args[:planet_name] || 'Earth'

    puts "🗺️ Generating sample terrain data for #{planet_name}..."

    # Find the celestial body
    celestial_body = CelestialBodies::CelestialBody.find_by(name: planet_name)
    unless celestial_body
      puts "❌ Celestial body '#{planet_name}' not found"
      exit 1
    end

    unless celestial_body.geosphere
      puts "❌ No geosphere found for #{planet_name}"
      exit 1
    end

    # Generate terrain data based on planet type
    terrain_data = case planet_name.downcase
    when 'earth'
      Planet::SampleTerrainGenerator.generate_earth_sample
    when 'mars'
      Planet::SampleTerrainGenerator.generate_mars_sample
    when 'luna', 'moon'
      Planet::SampleTerrainGenerator.generate_luna_sample
    else
      puts "⚠️ Unknown planet '#{planet_name}', generating Earth-like terrain"
      Planet::SampleTerrainGenerator.generate_earth_sample
    end

    # Store in database
    celestial_body.geosphere.update!(terrain_map: terrain_data)

    puts "✅ Stored terrain data for #{planet_name}: #{terrain_data[:width]}x#{terrain_data[:height]} grid"
    puts "   Terrain types: #{terrain_data[:grid].flatten.uniq.sort.join(', ')}"
  end

  desc "Generate sample terrain for all known celestial bodies"
  task :generate_all_samples => :environment do
    puts "🗺️ Generating sample terrain for all celestial bodies..."

    CelestialBodies::CelestialBody.includes(:geosphere).each do |body|
      next unless body.geosphere

      puts "Processing #{body.name}..."

      terrain_data = case body.name.downcase
      when 'earth'
        Planet::SampleTerrainGenerator.generate_earth_sample
      when 'mars'
        Planet::SampleTerrainGenerator.generate_mars_sample
      when 'luna', 'moon'
        Planet::SampleTerrainGenerator.generate_luna_sample
      else
        # Skip unknown bodies or generate generic terrain
        puts "   Skipping #{body.name} (unknown type)"
        next
      end

      body.geosphere.update!(terrain_map: terrain_data)
      puts "   ✅ #{body.name}: #{terrain_data[:width]}x#{terrain_data[:height]}"
    end

    puts "✅ Sample terrain generation complete"
  end

  desc "Clear all terrain map data"
  task :clear_all => :environment do
    puts "🗑️ Clearing all terrain map data..."

    count = 0
    CelestialBodies::Spheres::Geosphere.where.not(terrain_map: nil).each do |geo|
      geo.update!(terrain_map: nil)
      count += 1
    end

    puts "✅ Cleared terrain data from #{count} geospheres"
  end

  desc "Show terrain statistics for all bodies"
  task :stats => :environment do
    puts "📊 Terrain Map Statistics:"
    puts ""

    CelestialBodies::CelestialBody.includes(:geosphere).each do |body|
      next unless body.geosphere

      terrain_map = body.geosphere.terrain_map
      if terrain_map
        grid = terrain_map['grid']
        width = terrain_map['width'] || grid.first&.size || 0
        height = terrain_map['height'] || grid.size
        terrain_types = grid.flatten.uniq.sort

        puts "#{body.name}:"
        puts "  Size: #{width}x#{height}"
        puts "  Terrain Types: #{terrain_types.join(', ')}"
        puts "  Generated: #{terrain_map['generated_at']}"
        puts ""
      else
        puts "#{body.name}: No terrain data"
        puts ""
      end
    end
  end
end