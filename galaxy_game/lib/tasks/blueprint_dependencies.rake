namespace :blueprints do
  desc "Process blueprint dependencies"
  task :process_dependencies, [:blueprint_path, :generate] => :environment do |t, args|
    generate = args[:generate] != "false"
    generator = BlueprintDependencyGenerator.new
    dependencies = generator.process_blueprint(args[:blueprint_path], generate)
    
    puts "Found #{dependencies.size} dependencies:"
    dependencies.group_by {|d| d[:type]}.each do |type, deps|
      puts "  #{type.capitalize} (#{deps.size}):"
      deps.each do |dep|
        puts "    - #{dep[:id]}"
      end
    end
  end
  
  desc "Process all blueprints and generate dependencies"
  task :process_all => :environment do
    generator = BlueprintDependencyGenerator.new
    blueprint_paths = Dir.glob("/home/galaxy_game/app/data/blueprints/**/*.json")
    
    total_deps = []
    blueprint_paths.each do |path|
      puts "Processing #{path}..."
      deps = generator.process_blueprint(path, false)
      total_deps += deps
    end
    
    # Find unique dependencies
    unique_deps = total_deps.uniq {|d| [d[:type], d[:id]]}
    missing_deps = generator.send(:find_missing_dependencies, unique_deps)
    
    puts "Found #{missing_deps.size} missing dependencies across all blueprints."
    if missing_deps.any?
      print "Generate them? (y/n): "
      answer = STDIN.gets.chomp.downcase
      if answer == 'y'
        generator.send(:generate_missing_dependencies, missing_deps)
      end
    end
  end
end