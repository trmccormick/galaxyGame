namespace :starsim do
  desc "Generate multiple star systems and save them to data/json-data/generated_star_systems"
  task :generate_systems, [:count, :planets_per_system, :stars_per_system] => :environment do |t, args|
    count = (args[:count] || 1).to_i
    planets = (args[:planets_per_system] || 10).to_i
    stars = (args[:stars_per_system] || 1).to_i

    if count < 1
      puts "Error: count must be at least 1"
      exit 1
    end

    if planets < 1
      puts "Error: planets_per_system must be at least 1"
      exit 1
    end

    if stars < 1
      puts "Error: stars_per_system must be at least 1"
      exit 1
    end

    puts "🌟 Generating #{count} star system(s)..."
    puts "   Stars per system: #{stars}"
    puts "   Planets per system: #{planets}"
    puts ""

    generator = StarSim::ProceduralGenerator.new
    output_dir = GalaxyGame::Paths::GENERATED_STAR_SYSTEMS_PATH
    FileUtils.mkdir_p(output_dir) unless Dir.exist?(output_dir)

    generated_files = []
    
    count.times do |i|
      begin
        # Generate the system seed
        system_data = generator.generate_system_seed(num_stars: stars, num_planets: planets)
        
        # Create filename with identifier and timestamp
        identifier = system_data['solar_system']['identifier'] || "PROC-#{i + 1}"
        timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
        filename = "#{identifier.downcase}_#{timestamp}.json"
        filepath = output_dir.join(filename)

        # Write to file
        File.open(filepath, 'w') do |f|
          f.write(JSON.pretty_generate(system_data))
        end

        generated_files << filename
        puts "✓ Generated: #{filename}"
        
      rescue => e
        puts "✗ Error generating system #{i + 1}: #{e.message}"
        next
      end
    end

    puts ""
    puts "✅ Successfully generated #{generated_files.length} system(s)"
    puts "📁 Location: #{output_dir}"
    puts ""
  end

  desc "List all generated star systems"
  task :list_systems => :environment do
    output_dir = GalaxyGame::Paths::GENERATED_STAR_SYSTEMS_PATH
    
    unless Dir.exist?(output_dir)
      puts "No generated systems directory found at #{output_dir}"
      exit 0
    end

    files = Dir.glob(output_dir.join('*.json'))
    
    if files.empty?
      puts "No generated systems found in #{output_dir}"
      exit 0
    end

    puts "📋 Generated Star Systems:"
    puts ""
    files.sort.each do |file|
      filename = File.basename(file)
      begin
        data = JSON.parse(File.read(file))
        system_name = data['solar_system']['name'] || 'Unknown'
        star_count = data['stars']&.length || 0
        planet_count = data['celestial_bodies']&.dig('terrestrial_planets')&.length || 0
        
        puts "  • #{filename}"
        puts "    Name: #{system_name}"
        puts "    Stars: #{star_count} | Planets: #{planet_count}"
        puts ""
      rescue => e
        puts "  • #{filename} (error reading: #{e.message})"
        puts ""
      end
    end
  end

  desc "Delete all generated star systems (with confirmation)"
  task :clear_systems => :environment do
    output_dir = GalaxyGame::Paths::GENERATED_STAR_SYSTEMS_PATH
    
    unless Dir.exist?(output_dir)
      puts "No generated systems directory found"
      exit 0
    end

    files = Dir.glob(output_dir.join('*.json'))
    
    if files.empty?
      puts "No systems to delete"
      exit 0
    end

    puts "⚠️  About to delete #{files.length} generated system file(s)"
    puts ""
    files.each { |f| puts "  • #{File.basename(f)}" }
    puts ""
    
    print "Are you sure? (yes/no): "
    response = STDIN.gets.chomp.downcase
    
    if response == 'yes'
      files.each { |f| File.delete(f) }
      puts "✅ Deleted #{files.length} system file(s)"
    else
      puts "Cancelled"
    end
  end
end
