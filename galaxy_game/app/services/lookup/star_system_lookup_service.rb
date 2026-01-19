module Lookup
  class StarSystemLookupService < BaseLookupService
    SYSTEMS_PATH = GalaxyGame::Paths::STAR_SYSTEMS_PATH
    GENERATED_SYSTEMS_PATH = GalaxyGame::Paths::GENERATED_STAR_SYSTEMS_PATH

    def initialize
      super
      Rails.logger.debug "Star system data path: #{SYSTEMS_PATH.inspect}"
      @systems = load_systems
    end

    def fetch(system_name)
      # Find the system by name from already loaded systems
      # Prefer curated systems over generated ones
      curated_systems = @systems.select { |sys| sys[:_source_type] == :curated }
      generated_systems = @systems.select { |sys| sys[:_source_type] == :generated }
      
      # Special handling for Sol system: prefer sol.json over sol-complete.json
      if system_name.to_s.downcase == 'sol'
        sol_systems = curated_systems.select do |sys|
          (sys[:id] == 'Sol' || sys[:id] == 'sol') && 
          (sys[:_source_file] == 'sol.json' || sys[:_source_file] == 'sol-complete.json')
        end
        
        # Prefer sol.json (partial/working version) over sol-complete.json
        system_data = sol_systems.find { |sys| sys[:_source_file] == 'sol.json' } ||
                     sol_systems.find { |sys| sys[:_source_file] == 'sol-complete.json' }
      end
      
      # If not found (or not Sol system), search normally
      if system_data.nil?
        system_data = curated_systems.find do |sys|
          sys[:id] == system_name.to_s || 
          sys[:solar_system]&.[](:name)&.downcase == system_name.to_s.downcase ||
          sys[:name]&.downcase == system_name.to_s.downcase
        end
      end
      
      # If not found in curated, try generated
      if system_data.nil?
        system_data = generated_systems.find do |sys|
          sys[:id] == system_name.to_s || 
          sys[:solar_system]&.[](:name)&.downcase == system_name.to_s.downcase ||
          sys[:name]&.downcase == system_name.to_s.downcase
        end
      end
      
      # Try to load from seeds folder if not found in JSON files
      if system_data.nil?
        begin
          # Try to load from seed files if it's a known system
          seed_path = Rails.root.join("db", "seeds", "#{system_name.to_s.downcase}_system.rb")
          
          # Try alternate path if not found
          unless File.exist?(seed_path)
            seed_path = Rails.root.join("db", "seeds", "#{system_name.to_s.downcase}.rb")
          end
          
          if File.exist?(seed_path)
            # Load the Ruby file directly
            system_data_const = "#{system_name.upcase}_SYSTEM_DATA"
            
            # First try to access the constant if it's already loaded
            if Object.const_defined?(system_data_const)
              system_data = Object.const_get(system_data_const)
            else
              # Load the file if constant isn't defined
              load seed_path
              system_data = Object.const_get(system_data_const) if Object.const_defined?(system_data_const)
            end
            
            puts "Loaded system data from: #{seed_path}"
            puts "Available categories in seed: #{system_data[:celestial_bodies].keys.join(', ')}"
          end
        rescue StandardError => e
          Rails.logger.error "Error loading seed data for #{system_name}: #{e.message}"
          puts "Error loading seed data: #{e.message}"
          puts e.backtrace.join("\n")
        end
      end
      
      # Debug what categories we have
      if system_data && system_data[:celestial_bodies]
        if system_data[:celestial_bodies].is_a?(Hash)
          Rails.logger.debug "Loaded celestial body categories: #{system_data[:celestial_bodies].keys.join(', ')}"
        elsif system_data[:celestial_bodies].is_a?(Array)
          Rails.logger.debug "Loaded celestial bodies as array with #{system_data[:celestial_bodies].size} bodies"
        end
      end
      
      system_data
    end

    def system_exists?(identifier)
      # Check if a system with this identifier exists in the loaded data
      @systems.any? do |system|
        system[:id] == identifier.to_s || system[:name]&.downcase == identifier.to_s.downcase
      end
    end

    def list_systems
      @systems.map { |s| s[:id] || s[:name] }
    end

    def reload!
      puts "Explicitly reloading system data..."
      @systems = nil  # Clear any cached data
      initialize      # Re-initialize the service
    end

    private

    def load_systems
      systems = []
      
      # Load curated systems
      if File.directory?(SYSTEMS_PATH)
        Dir.glob(File.join(SYSTEMS_PATH, "*.json")).each do |file|
          # Skip files with 'complete' or 'old' in the name as they may have different structures
          # Exception: Don't skip 'complete' files for the Sol system as sol-complete.json serves as backup
          next if (File.basename(file).include?('complete') || File.basename(file).include?('old')) && !File.basename(file).start_with?('sol')
          
          begin
            data = JSON.parse(File.read(file), symbolize_names: true)
            data[:_source_file] = File.basename(file)
            data[:_source_type] = :curated
            Rails.logger.debug "Loaded curated star system from #{file}"
            systems << data
          rescue JSON::ParserError => e
            Rails.logger.error "Error parsing #{file}: #{e.message}"
          rescue StandardError => e
            Rails.logger.error "Error loading #{file}: #{e.message}"
          end
        end
      end

      # Load generated systems
      if File.directory?(GENERATED_SYSTEMS_PATH)
        Dir.glob(File.join(GENERATED_SYSTEMS_PATH, "*.json")).each do |file|
          begin
            data = JSON.parse(File.read(file), symbolize_names: true)
            data[:_source_file] = File.basename(file)
            data[:_source_type] = :generated
            Rails.logger.debug "Loaded generated star system from #{file}"
            systems << data
          rescue JSON::ParserError => e
            Rails.logger.error "Error parsing #{file}: #{e.message}"
          rescue StandardError => e
            Rails.logger.error "Error loading #{file}: #{e.message}"
          end
        end
      end

      systems
    end
  end
end

