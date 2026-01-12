require 'json'
require 'fileutils'

class MaterialMigration
  require_relative '../../config/initializers/game_data_paths'
  # Use paths as they exist in the container
  SOURCE_ROOT = GalaxyGame::Paths::JSON_DATA.join('old-json-data', 'production_old4', 'materials').to_s
  TARGET_ROOT = GalaxyGame::Paths::MATERIALS_PATH.to_s
  
  GAS_TEMPLATE = {
    "template" => "material",
    "category" => "gas",
    "id" => nil,
    "name" => nil,
    "chemical_formula" => nil,
    "description" => nil,
    "molar_mass" => nil, # Important for atmosphere calculations
    "density" => nil,
    "boiling_point" => nil,
    "melting_point" => nil,
    "state_at_stp" => "gas",
    "appearance" => nil,
    "color" => nil,
    "odor" => nil,
    "taste" => nil,
    "toxicity" => nil,
    "flammability" => nil,
    "reactivity" => nil,
    "storage" => {
      "pressure" => "standard",
      "temperature" => "standard",
      "stability" => "stable",
      "incompatible_with" => []
    },
    "handling" => {
      "ppe_required" => [],
      "hazard_class" => [],
      "disposal" => "standard"
    },
    "properties" => {
      "transparent" => true,
      "oxidizer" => false,
      "radioactive" => false
    }
  }

  def initialize
    # Determine if we're in Docker or local environment
    @in_docker = File.directory?('/home/galaxy_game')
    
    if @in_docker
      @source_root = SOURCE_ROOT
      @target_root = TARGET_ROOT
      puts "Running in Docker container environment"
    else
      @source_root = LOCAL_SOURCE_ROOT
      @target_root = LOCAL_TARGET_ROOT
      puts "Running in local development environment"
    end
    
    puts "Source root: #{@source_root}"
    puts "Target root: #{@target_root}"
  end

  def run
    puts "Starting material migration..."
    migrate_gases
    puts "Migration complete!"
  end

  def migrate_gases
    source_gas_dir = File.join(@source_root, 'gases')
    target_gas_dir = File.join(@target_root, 'gases')
    
    # Check if source directory exists
    unless File.directory?(source_gas_dir)
      puts "ERROR: Source gas directory #{source_gas_dir} does not exist!"
      puts "Available directories:"
      Dir.glob(File.join(@source_root, '*')).each do |dir|
        puts "- #{dir}" if File.directory?(dir)
      end
      return false
    end
    
    # Create target directories if they don't exist
    ['compound', 'inert', 'reactive'].each do |subdir|
      dir_path = File.join(target_gas_dir, subdir)
      FileUtils.mkdir_p(dir_path)
      puts "Created directory: #{dir_path}"
    end
    
    # Process all gas files
    gas_files = Dir.glob(File.join(source_gas_dir, '*.json'))
    puts "Found #{gas_files.size} gas files to process"
    
    migrated_count = 0
    error_count = 0
    
    gas_files.each do |file_path|
      begin
        filename = File.basename(file_path)
        gas_id = filename.gsub('.json', '')
        
        # Read source file
        json_data = JSON.parse(File.read(file_path))
        
        # Fill in template with source data
        new_gas_data = GAS_TEMPLATE.dup
        new_gas_data["id"] = gas_id
        new_gas_data["name"] = json_data["name"] || gas_id.gsub('_', ' ').titleize
        new_gas_data["chemical_formula"] = json_data["chemical_formula"] || "Unknown"
        new_gas_data["description"] = json_data["description"] || "A gas used in industrial processes."
        
        # Critical for atmosphere calculations - must be present
        if json_data["molar_mass"].nil?
          # Look up common gases molar mass values
          molar_mass = case gas_id
          when "hydrogen"          then 2.016
          when "helium"            then 4.0026
          when "nitrogen"          then 28.0134
          when "oxygen"            then 31.9988
          when "argon"             then 39.948
          when "carbon_dioxide"    then 44.01
          when "neon"              then 20.1797
          when "methane"           then 16.04
          when "ammonia"           then 17.031
          when "water_vapor"       then 18.01528
          when "carbon_monoxide"   then 28.01
          when "nitrous_oxide"     then 44.013
          when "sulfur_dioxide"    then 64.066
          when "hydrogen_sulfide"  then 34.08
          when "ozone"             then 48.00
          else
            puts "WARNING: No molar mass found for #{gas_id} - using placeholder value"
            40.0 # Placeholder value
          end
          new_gas_data["molar_mass"] = molar_mass
        else
          new_gas_data["molar_mass"] = json_data["molar_mass"].to_f
        end
        
        # Determine gas type
        gas_type = determine_gas_type(gas_id)
        
        # Copy other properties if they exist
        ["density", "boiling_point", "melting_point", "appearance", "color", 
         "odor", "taste", "toxicity", "flammability", "reactivity"].each do |prop|
          new_gas_data[prop] = json_data[prop] if json_data[prop]
        end
        
        # Set reactivity property
        new_gas_data["properties"]["oxidizer"] = true if ["oxygen", "chlorine", "fluorine", "ozone"].include?(gas_id)
        
        # Write to appropriate target directory
        target_path = File.join(target_gas_dir, gas_type, filename)
        File.write(target_path, JSON.pretty_generate(new_gas_data))
        
        puts "Migrated: #{gas_id} to #{gas_type}/#{filename}"
        migrated_count += 1
      rescue => e
        puts "ERROR processing #{file_path}: #{e.message}"
        error_count += 1
      end
    end
    
    puts "Gas migration complete: #{migrated_count} migrated, #{error_count} errors"
  end
  
  def determine_gas_type(gas_id)
    inert_gases = ["helium", "neon", "argon", "krypton", "xenon", "radon"]
    compound_gases = [
      "carbon_dioxide", "carbon_monoxide", "methane", "ammonia", 
      "nitrous_oxide", "sulfur_dioxide", "hydrogen_sulfide", "water_vapor"
    ]
    
    if inert_gases.include?(gas_id)
      "inert"
    elsif compound_gases.include?(gas_id)
      "compound"
    else
      "reactive"
    end
  end
end

# Run the migration
migration = MaterialMigration.new
migration.run