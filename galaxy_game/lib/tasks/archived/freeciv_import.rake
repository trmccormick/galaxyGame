# lib/tasks/freeciv_import.rake

namespace :freeciv do
  desc "Import terrain data from FreeCiv .sav files"
  task :import_terrain, [:file_path, :planet_name] => :environment do |t, args|
    file_path = args[:file_path]
    planet_name = args[:planet_name] || 'Unknown'

    unless file_path
      puts "❌ Usage: rake freeciv:import_terrain[file_path,planet_name]"
      puts "   Example: rake freeciv:import_terrain[data/freeCiv\\ Maps/mars-terraformed-133x64-v2.0.sav,Mars]"
      exit 1
    end

    unless File.exist?(file_path)
      puts "❌ File not found: #{file_path}"
      exit 1
    end

    puts "🗺️ Importing FreeCiv terrain from: #{file_path}"
    puts "   Target planet: #{planet_name}"

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

    # Import the terrain data
    import_service = Import::FreecivSavImportService.new(file_path)
    result = import_service.import

    if result.is_a?(Hash) && result[:grid]
      # Store in database
      terrain_data = {
        grid: result[:grid],
        width: result[:width],
        height: result[:height],
        biome_counts: result[:biome_counts],
        imported_at: Time.current.iso8601,
        source: 'freeciv_sav',
        file_name: File.basename(file_path),
        planet_type: planet_name.downcase
      }

      celestial_body.geosphere.update!(terrain_map: terrain_data)

      puts "✅ Successfully imported terrain data for #{planet_name}:"
      puts "   Dimensions: #{result[:width]}x#{result[:height]}"
      puts "   Terrain types: #{result[:biome_counts].keys.sort.join(', ')}"
      puts "   Total tiles: #{result[:grid].flatten.size}"

      # Show biome breakdown
      puts "\n📊 Biome Distribution:"
      result[:biome_counts].sort_by { |k,v| -v }.each do |terrain, count|
        percentage = (count.to_f / result[:grid].flatten.size * 100).round(1)
        puts "   #{terrain}: #{count} tiles (#{percentage}%)"
      end

    else
      puts "❌ Import failed:"
      import_service.errors.each { |error| puts "   - #{error}" }
      exit 1
    end
  end

  desc "Import both Mars and Earth FreeCiv terrain files"
  task :import_all => :environment do
    puts "🗺️ Importing all available FreeCiv terrain files..."

    # Define the files we found
    files_to_import = [
      {
        path: '/home/galaxy_game/freeCiv_maps/mars-terraformed-133x64-v2.0.sav',
        planet: 'Mars'
      },
      {
        path: '/home/galaxy_game/freeCiv_maps/earth-180x90-v1-3.sav',
        planet: 'Earth'
      }
    ]

    success_count = 0

    files_to_import.each do |file_info|
      if File.exist?(file_info[:path])
        puts "\n📁 Processing: #{file_info[:path]}"

        # Use the existing task
        begin
          Rake::Task['freeciv:import_terrain'].invoke(file_info[:path], file_info[:planet])
          success_count += 1
        rescue => e
          puts "❌ Failed to import #{file_info[:planet]}: #{e.message}"
        ensure
          # Re-enable the task for next run
          Rake::Task['freeciv:import_terrain'].reenable
        end
      else
        puts "⚠️ File not found: #{file_info[:path]}"
      end
    end

    puts "\n✅ Import complete: #{success_count}/#{files_to_import.size} files imported successfully"
  end

  desc "Show terrain statistics for FreeCiv imported data"
  task :stats => :environment do
    puts "📊 FreeCiv Terrain Import Statistics:"
    puts ""

    CelestialBodies::CelestialBody.includes(:geosphere).each do |body|
      next unless body.geosphere

      terrain_map = body.geosphere.terrain_map
      next unless terrain_map && terrain_map['source'] == 'freeciv_sav'

      puts "#{body.name}:"
      puts "  Source: #{terrain_map['file_name']}"
      puts "  Imported: #{terrain_map['imported_at']}"
      puts "  Dimensions: #{terrain_map['width']}x#{terrain_map['height']}"

      if terrain_map['biome_counts']
        puts "  Terrain types: #{terrain_map['biome_counts'].keys.sort.join(', ')}"

        # Show top 5 biomes
        puts "  Top biomes:"
        terrain_map['biome_counts'].sort_by { |k,v| -v }.first(5).each do |terrain, count|
          percentage = (count.to_f / terrain_map['grid'].flatten.size * 100).round(1)
          puts "    #{terrain}: #{count} (#{percentage}%)"
        end
      end
      puts ""
    end
  end
end