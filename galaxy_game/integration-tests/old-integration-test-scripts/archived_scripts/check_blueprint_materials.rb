require 'json'
require 'set'
require 'logger'
require 'pathname'
require 'ostruct' # Required for OpenStruct

# --- Mock Rails.root for standalone script execution ---
unless defined?(Rails)
  module Rails
    def self.root
      Pathname.new(File.expand_path('../../../../', __FILE__))
    end

    def self.env
      OpenStruct.new(test?: false, development?: true)
    end

    def self.logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.level = Logger::WARN # Only show WARN and ERROR messages by default
        log.formatter = proc { |severity, datetime, progname, msg|
          "#{severity[0]}: #{msg}\n" # Simplified format
        }
      end
    end
  end
end

# First, ensure we can require the lookup services
begin
  # Add the application's lib directory to the load path
  $LOAD_PATH.unshift(Rails.root.join('lib').to_s)
  $LOAD_PATH.unshift(Rails.root.join('app').to_s)
  
  # Require the lookup services
  require 'services/lookup/base_lookup_service'
  require 'services/lookup/blueprint_lookup_service'
  require 'services/lookup/craft_lookup_service'
  require 'services/lookup/item_lookup_service'
  require 'services/lookup/material_lookup_service'
  require 'services/lookup/module_lookup_service'
  require 'services/lookup/rig_lookup_service'
  require 'services/lookup/unit_lookup_service'
rescue LoadError => e
  puts "ERROR: Could not load lookup services: #{e.message}"
  puts "This script must be run from the root of the galaxy_game directory."
  exit 1
end

# --- Universal Definition Checker ---
class UniversalDefinitionChecker
  attr_reader :lookup_services
  
  def initialize
    @lookup_services = {}
    
    # Safely initialize each lookup service
    begin
      @lookup_services[:item] = Lookup::ItemLookupService.new
      @lookup_services[:material] = Lookup::MaterialLookupService.new
      @lookup_services[:unit] = Lookup::UnitLookupService.new
      @lookup_services[:blueprint] = Lookup::BlueprintLookupService.new
      @lookup_services[:craft] = Lookup::CraftLookupService.new
      
      # These might not be defined, so handle gracefully
      begin
        @lookup_services[:module] = Lookup::ModuleLookupService.new if defined?(Lookup::ModuleLookupService)
      rescue NameError => e
        puts "WARN: ModuleLookupService not available: #{e.message}"
      end
      
      begin
        @lookup_services[:rig] = Lookup::RigLookupService.new if defined?(Lookup::RigLookupService)
      rescue NameError => e
        puts "WARN: RigLookupService not available: #{e.message}"
      end
      
      # Print the directories we're checking
      puts "Initializing Universal Definition Checker..."
      puts "  Items directory: #{Lookup::ItemLookupService::BASE_PATH}" if @lookup_services[:item]
      puts "  Materials directory: #{Lookup::MaterialLookupService::MATERIAL_PATHS[:raw][:path]}" if @lookup_services[:material]
      puts "  Units directory: #{Lookup::UnitLookupService::UNIT_PATHS.values.first}" if @lookup_services[:unit]
      puts "  Blueprints directory: #{Lookup::BlueprintLookupService::BASE_PATH}" if @lookup_services[:blueprint]
      puts "  Crafts directory: #{Lookup::CraftLookupService::BASE_PATH}" if @lookup_services[:craft]
      
    rescue NameError => e
      puts "ERROR: Could not initialize lookup services: #{e.message}"
      puts "Make sure you have defined all the necessary lookup services in your application."
      exit 1
    end
  end

  # Checks if a definition exists in any of the primary lookup services
  def definition_exists?(name_or_id)
    return false if name_or_id.nil? || name_or_id.empty?
    
    # Normalize name/id for consistent lookup
    name_or_id = name_or_id.to_s.downcase.gsub('_', ' ')

    # Check all relevant lookup services - add unit lookup BEFORE material lookup
    # since units like "Solar Panel" should be found there
    begin
      return true if @lookup_services[:unit]&.find_unit(name_or_id)
    rescue ArgumentError
      # Ignore argument errors
    end

    begin
      return true if @lookup_services[:item]&.find_item(name_or_id)
    rescue ArgumentError
      # Ignore argument errors
    end

    begin
      return true if @lookup_services[:material]&.find_material(name_or_id)
    rescue ArgumentError
      # Ignore argument errors  
    end

    begin
      return true if @lookup_services[:blueprint]&.find_blueprint(name_or_id)
    rescue ArgumentError
      # Ignore argument errors
    end

    # DO NOT try the craft lookup for every name - it requires specific parameters
    # This is what was causing the script to hang with many errors
    
    # Only try module/rig lookups if they exist
    if @lookup_services[:module]&.respond_to?(:find_module)
      begin
        return true if @lookup_services[:module].find_module(name_or_id)
      rescue ArgumentError
        # Ignore argument errors
      end
    end

    if @lookup_services[:rig]&.respond_to?(:find_rig)
      begin
        return true if @lookup_services[:rig].find_rig(name_or_id)
      rescue ArgumentError
        # Ignore argument errors
      end
    end

    false
  end

  # Returns which service can find this entity (for debugging)
  def find_entity_type(name_or_id)
    return "NIL" if name_or_id.nil?
  
    # Normalize name/id for consistent lookup
    name_or_id = name_or_id.to_s.downcase.gsub('_', ' ')

    # Only try the safe lookup services
    begin
      return "Item" if @lookup_services[:item]&.find_item(name_or_id)
    rescue ArgumentError
      # Ignore
    end

    begin
      return "Material" if @lookup_services[:material]&.find_material(name_or_id)
    rescue ArgumentError
      # Ignore
    end

    begin
      return "Unit" if @lookup_services[:unit]&.find_unit(name_or_id)
    rescue ArgumentError
      # Ignore
    end

    begin
      return "Blueprint" if @lookup_services[:blueprint]&.find_blueprint(name_or_id)
    rescue ArgumentError
      # Ignore
    end

    # Skip craft lookup - requires specific parameters

    # Only try module/rig lookups if they exist
    if @lookup_services[:module]&.respond_to?(:find_module)
      begin
        return "Module" if @lookup_services[:module].find_module(name_or_id)
      rescue ArgumentError
        # Ignore
      end
    end

    if @lookup_services[:rig]&.respond_to?(:find_rig)
      begin
        return "Rig" if @lookup_services[:rig].find_rig(name_or_id)
      rescue ArgumentError
        # Ignore
      end
    end

    "Not Found"
  end
end

# --- Cargo Manifest Parser ---
class CargoManifestParser
  def initialize
    @manifest_path = Rails.root.join('app', 'data', 'json-data', 'starship-cargo-manifest')
    
    # Check if the directory exists
    unless Dir.exist?(@manifest_path)
      puts "WARN: Manifest directory not found: #{@manifest_path}"
    end
  end
  
  def all_manifests
    begin
      if Dir.exist?(@manifest_path)
        Dir.glob(File.join(@manifest_path, "*.json")).map do |file|
          begin
            JSON.parse(File.read(file))
          rescue JSON::ParserError => e
            Rails.logger.error("Error parsing JSON from #{file}: #{e.message}")
            nil
          end
        end.compact
      else
        []
      end
    rescue StandardError => e
      puts "ERROR: Failed to read manifest files: #{e.message}"
      []
    end
  end
  
  def collect_references
    referenced_names = Set.new
    
    begin
      all_manifests.each do |manifest|
        # Process craft
        if manifest['craft']
          # Craft name
          referenced_names.add(manifest['craft']['name']) if manifest['craft']['name']
          
          # Installed units
          if manifest['craft']['installed_units']
            manifest['craft']['installed_units'].each do |unit|
              referenced_names.add(unit['name']) if unit['name']
              referenced_names.add(unit['id']) if unit['id']
            end
          end
          
          # Installed modules
          if manifest['craft']['installed_modules']
            manifest['craft']['installed_modules'].each do |mod|
              referenced_names.add(mod['name']) if mod['name']
              referenced_names.add(mod['id']) if mod['id']
            end
          end
          
          # Stowed units
          if manifest['craft']['stowed_units']
            manifest['craft']['stowed_units'].each do |unit|
              referenced_names.add(unit['name']) if unit['name']
              referenced_names.add(unit['blueprint_id']) if unit['blueprint_id']
            end
          end
        end
        
        # Process inventory
        if manifest['inventory'] && manifest['inventory']['supplies']
          manifest['inventory']['supplies'].each do |supply|
            referenced_names.add(supply['name']) if supply['name']
          end
        end
      end
    rescue StandardError => e
      puts "ERROR: Failed to collect references from manifests: #{e.message}"
    end
    
    referenced_names
  end
end

# --- Debugging: File System Information ---
def debug_file_system
  puts "\n===== File System Debug Information ====="
  
  # Check Rails.root
  puts "Rails.root: #{Rails.root}"
  
  # Check the actual blueprint path
  blueprint_path = Rails.root.join('app', 'data', 'blueprints')
  puts "Blueprint path: #{blueprint_path} (exists: #{Dir.exist?(blueprint_path)})"
  if Dir.exist?(blueprint_path)
    blueprint_files = Dir.glob(File.join(blueprint_path, '**', '*.json'))
    puts "  - Blueprint JSON files found: #{blueprint_files.size}"
    puts "  - First few files: #{blueprint_files.take(3).join(', ')}" if blueprint_files.any?
  end
  
  # Check various material paths
  material_base = Rails.root.join('app', 'data', 'materials')
  puts "Material base path: #{material_base} (exists: #{Dir.exist?(material_base)})"
  
  # Check refined_metals specifically
  refined_metals_path = material_base.join('processed', 'refined_metals')
  puts "Refined metals path: #{refined_metals_path} (exists: #{Dir.exist?(refined_metals_path)})"
  if Dir.exist?(refined_metals_path)
    metal_files = Dir.glob(File.join(refined_metals_path, '*.json'))
    puts "  - Metal JSON files found: #{metal_files.size}"
    puts "  - Files: #{metal_files.map { |f| File.basename(f) }.join(', ')}"
  end
  
  # Try direct system commands for more reliable results
  puts "\nDirect system checks:"
  puts `ls -la #{Rails.root.join('app', 'data')}`
  puts `find #{Rails.root.join('app', 'data')} -type f -name "*.json" | wc -l`
  
  puts "===== End Debug Information =====\n"
end

# --- Main Script Logic ---
begin
  puts "Blueprint Dependency Validation Tool"
  puts "-----------------------------------"
  puts "Environment: #{Rails.env}"
  puts "RAILS_ENV: #{ENV['RAILS_ENV']}"

  # Debug: Show file system information
  debug_file_system

  # Initialize the universal checker
  checker = UniversalDefinitionChecker.new

  # Get all blueprints
  begin
    blueprint_lookup_service = checker.lookup_services[:blueprint]
    if blueprint_lookup_service.nil?
      puts "ERROR: Blueprint lookup service not available."
      exit 1
    end
    
    all_blueprints = blueprint_lookup_service.all_blueprints
  rescue StandardError => e
    puts "ERROR: Failed to load blueprints: #{e.message}"
    all_blueprints = []
  end

  # Set to store all unique names referenced by blueprints
  all_referenced_names = Set.new

  # --- Collect referenced names from BLUEPRINTS ---
  if all_blueprints.empty?
    puts "WARN: No blueprints found."
  else
    puts "Scanning #{all_blueprints.size} blueprints for dependencies..."
    all_blueprints.each do |bp_data|
      begin
        blueprint_display_name = bp_data['name'] || bp_data['id'] || 'Unnamed Blueprint'
        
        # Product of this blueprint (item_produced_id)
        if bp_data['item_produced_id']
          all_referenced_names.add(bp_data['item_produced_id'])
        end
        
        # Required Materials (from 'materials' and 'maintenance.materials_needed_for_repair')
        materials_list = []

        # Safely extract materials from 'materials' field
        if bp_data['materials'].is_a?(Array)
          materials_list.concat(bp_data['materials'])
        elsif bp_data['materials'].is_a?(Hash)
          # If it's a hash, extract it differently
          bp_data['materials'].each do |key, value|
            materials_list << {'material' => key, 'quantity' => value} if key.is_a?(String)
          end
        end

        # Safely extract materials from 'cost.materials' field
        if bp_data.dig('cost', 'materials').is_a?(Array)
          materials_list.concat(bp_data.dig('cost', 'materials') || [])
        elsif bp_data.dig('cost', 'materials').is_a?(Hash)
          # If it's a hash, extract it differently
          bp_data.dig('cost', 'materials')&.each do |key, value|
            materials_list << {'material' => key, 'quantity' => value} if key.is_a?(String)
          end
        end

        # Safely extract materials from 'maintenance.materials_needed_for_repair'
        if bp_data.dig('maintenance', 'materials_needed_for_repair').is_a?(Array)
          materials_list.concat(bp_data.dig('maintenance', 'materials_needed_for_repair') || [])
        elsif bp_data.dig('maintenance', 'materials_needed_for_repair').is_a?(Hash)
          # If it's a hash, extract it differently
          bp_data.dig('maintenance', 'materials_needed_for_repair')&.each do |key, value|
            materials_list << {'material' => key, 'quantity' => value} if key.is_a?(String)
          end
        end

        # Process the materials list
        materials_list.each do |material_entry|
          if material_entry.is_a?(Hash)
            # Extract material name from 'id' or 'material' field
            material_name = material_entry['id'] || material_entry['material']
            all_referenced_names.add(material_name) if material_name
          elsif material_entry.is_a?(String)
            # If it's just a string, use it directly
            all_referenced_names.add(material_entry)
          end
        end
        
        # Compatible Units (from Craft Blueprints)
        if bp_data['compatible_units']
          bp_data['compatible_units'].each do |port_type, units_array|
            units_array.each { |unit_name| all_referenced_names.add(unit_name) } if units_array.is_a?(Array)
          end
        end
        
        # Production Facility/Equipment (from 'production.facility' or 'requirements.facilities')
        if bp_data['production'] && bp_data['production']['facility']
          all_referenced_names.add(bp_data['production']['facility'])
        end
        if bp_data['requirements'] && bp_data['requirements']['facilities']
          if bp_data['requirements']['facilities'].is_a?(Array)
            bp_data['requirements']['facilities'].each { |facility_name| all_referenced_names.add(facility_name) }
          end
        end
        
        # Modules (from 'modules.default' and 'modules.types')
        if bp_data['modules']
          if bp_data['modules']['default'] && bp_data['modules']['default'].is_a?(Array)
            bp_data['modules']['default'].each { |module_name| all_referenced_names.add(module_name) }
          end
          if bp_data['modules']['types'] && bp_data['modules']['types'].is_a?(Array)
            bp_data['modules']['types'].each { |module_type_name| all_referenced_names.add(module_type_name) }
          end
        end
      rescue StandardError => e
        puts "WARN: Error processing blueprint #{bp_data['name'] || bp_data['id']}: #{e.message}"
      end
    end
  end

  # --- Collect referenced names from CARGO MANIFESTS ---
  puts "Scanning cargo manifests for references..."
  begin
    cargo_parser = CargoManifestParser.new
    manifest_references = cargo_parser.collect_references
    all_referenced_names.merge(manifest_references)
  rescue StandardError => e
    puts "ERROR: Failed to process cargo manifests: #{e.message}"
  end

  puts "\n--- Blueprint & Cargo Manifest Validation Report ---"
  puts "Total unique entities referenced: #{all_referenced_names.size}"
  puts "---------------------------------------------------"

  missing_definitions = []
  found_count = 0

  # Check each referenced name against the universal checker
  all_referenced_names.sort.each do |name|
    begin
      unless checker.definition_exists?(name)
        missing_definitions << name
      else
        found_count += 1
      end
    rescue StandardError => e
      puts "WARN: Error checking definition for '#{name}': #{e.message}"
      missing_definitions << name
    end
  end

  puts "Found definitions: #{found_count}"
  puts "Missing definitions: #{missing_definitions.size}"

  puts "\n--- Missing Definitions ---"
  if missing_definitions.empty?
    puts "  None found. All entities referenced have a definition JSON file. Great!"
  else
    puts "  The following entities are referenced by your blueprints or cargo manifests"
    puts "  but DO NOT have a corresponding definition JSON file:"
    missing_definitions.each do |name|
      puts "- #{name}"
    end
  end
  puts "---------------------------------------------------"

  # Optional: Show where each entity was found (useful for debugging)
  if ARGV.include?('--debug')
    puts "\n--- Entity Type Report (First 20 items) ---"
    all_referenced_names.sort.take(20).each do |name|
      begin
        entity_type = checker.find_entity_type(name)
        puts "#{name}: #{entity_type}"
      rescue StandardError => e
        puts "#{name}: Error - #{e.message}"
      end
    end
  end

  # After initializing the checker
  if checker.lookup_services[:material].respond_to?(:debug_paths)
    checker.lookup_services[:material].debug_paths
  end

  def test_material_loading
    puts "\n===== Testing Material Loading ====="
    begin
      # Try to directly load a material JSON file
      copper_path = Rails.root.join('app', 'data', 'materials', 'processed', 'refined_metals', 'copper.json')
      puts "Copper path: #{copper_path} (exists: #{File.exist?(copper_path)})"
      
      if File.exist?(copper_path)
        begin
          copper_data = JSON.parse(File.read(copper_path))
          puts "Successfully loaded copper data: #{copper_data['id']}"
        rescue => e
          puts "Error parsing copper JSON: #{e.message}"
        end
      end
      
      # Try the load_materials method directly
      material_service = Lookup::MaterialLookupService.new
      puts "Material service loaded #{material_service.instance_variable_get(:@materials).size} materials"
      
      # Test looking up copper
      copper = material_service.find_material('copper')
      puts "Copper lookup result: #{copper ? 'FOUND' : 'NOT FOUND'}"
    rescue => e
      puts "Error in material loading test: #{e.message}"
      puts e.backtrace.join("\n") if ENV['DEBUG']
    end
    puts "===== End Material Loading Test =====\n"
  end

  # Call this after initializing your checker
  test_material_loading

  puts "\n===== Testing Unit Loading ====="
  begin
    # Try looking up solar panel
    unit_service = Lookup::UnitLookupService.new
    puts "Unit service initialized"
    
    # Test looking up solar panel directly
    solar_panel = unit_service.find_unit('solar panel')
    puts "Solar Panel lookup result: #{solar_panel ? 'FOUND' : 'NOT FOUND'}"
    
    # Try with different variants
    ['Solar Panel', 'solar_panel', 'solar panel'].each do |variant|
      result = unit_service.find_unit(variant)
      puts "  - '#{variant}' lookup: #{result ? 'FOUND' : 'NOT FOUND'}"
    end
  rescue => e
    puts "Error in unit lookup test: #{e.message}"
  end
  puts "===== End Unit Loading Test =====\n"

  # --- Path Resolution for Docker Environment ---
  require_relative '../../../../config/initializers/game_data_paths'
  BASE_DIR = GalaxyGame::Paths::JSON_DATA.to_s
  puts "Using BASE_DIR: #{BASE_DIR}"

  # Add this method to help debug path resolution
  def test_paths
    puts "\n===== Testing Path Resolution ====="
    puts "Current directory: #{Dir.pwd}"
    puts "BASE_DIR: #{BASE_DIR}"
    
    # Test important subdirectories
    ['blueprints', 'units', 'materials', 'starship-cargo-manifest'].each do |subdir|
      path = File.join(BASE_DIR, subdir)
      exists = Dir.exist?(path)
      puts "#{subdir} path: #{path} (exists: #{exists})"
      
      if exists
        # List a few files to verify access
        files = Dir.glob(File.join(path, '**', '*.json')).first(3)
        puts "  First few files: #{files.map { |f| File.basename(f) }.join(', ')}" if files.any?
      end
    end
    
    # Test specific files that should exist
    test_files = [
      ['units', 'propulsion', 'raptor_engine_data.json'],
      ['blueprints', 'units', 'propulsion', 'raptor_engine_blueprint.json'],
      ['starship-cargo-manifest', 'ssc-000.json']
    ]
    
    test_files.each do |parts|
      file_path = File.join(BASE_DIR, *parts)
      exists = File.exist?(file_path)
      puts "Test file: #{file_path} (exists: #{exists})"
      
      if exists
        begin
          data = JSON.parse(File.read(file_path))
          puts "  Successfully parsed JSON with keys: #{data.keys.join(', ')}"
        rescue => e
          puts "  Error parsing JSON: #{e.message}"
        end
      end
    end
    
    puts "===== End Path Resolution Test =====\n"
  end

  # Call the test_paths method to verify our path resolution logic
  test_paths

  def find_unit_definition(unit_id)
    # Normalize the unit_id by removing common suffixes
    original_unit_id = unit_id.to_s.downcase.gsub(/\s+/, '_')
    unit_id = original_unit_id
               .gsub(/_unit$/, '')        # Remove _unit suffix
               .gsub(/_module$/, '')      # Remove _module suffix
               .gsub(/_system$/, '')      # Remove _system suffix
  
    # Log the lookup attempt for debugging
    puts "Looking for unit: '#{original_unit_id}' (normalized to '#{unit_id}')" if ENV['DEBUG']
  
    # First, try to find direct matches with both original and normalized IDs
    [original_unit_id, unit_id].each do |id_to_try|
      # Try direct filename match
      unit_paths = Dir.glob(File.join(BASE_DIR, 'units', '**', "#{id_to_try}.json"))
      return unit_paths.first if unit_paths.any?
      
      # Try with _data suffix
      unit_paths = Dir.glob(File.join(BASE_DIR, 'units', '**', "#{id_to_try}_data.json"))
      return unit_paths.first if unit_paths.any?
    end
  
    # If still not found, try more flexible content-based matching
    all_unit_files = Dir.glob(File.join(BASE_DIR, 'units', '**', "*.json"))
  
    all_unit_files.each do |file_path|
      begin
        unit_data = JSON.parse(File.read(file_path))
        
        # Check unit name and aliases against both original and normalized ID
        if [original_unit_id, unit_id].any? { |id| 
             unit_data['id']&.downcase == id ||
             unit_data['name']&.downcase&.gsub(/\s+/, '_') == id ||
             unit_data['unit_type']&.downcase == id ||
             (unit_data['aliases']&.any? { |alias_name| alias_name.downcase.gsub(/\s+/, '_') == id })
           }
          return file_path
        end
      rescue JSON::ParserError
        # Skip files with invalid JSON
        next
      end
    end
    
    # Not found
    nil
  end

  def find_blueprint_definition(unit_id)
    # Normalize the unit_id
    unit_id = unit_id.to_s.downcase.gsub(/\s+/, '_')
    
    # First, try to find a direct match
    blueprint_paths = Dir.glob(File.join(BASE_DIR, 'blueprints', '**', "#{unit_id}.json"))
    
    # If not found, try with _blueprint suffix
    if blueprint_paths.empty?
      blueprint_paths = Dir.glob(File.join(BASE_DIR, 'blueprints', '**', "#{unit_id}_blueprint.json"))
    end
    
    # If still not found, search all blueprint files for unit_type field
    if blueprint_paths.empty?
      all_blueprint_files = Dir.glob(File.join(BASE_DIR, 'blueprints', '**', "*.json"))
      
      all_blueprint_files.each do |file_path|
        begin
          blueprint_data = JSON.parse(File.read(file_path))
          
          # Check for matching unit_type
          if blueprint_data['unit_type']&.to_s&.downcase == unit_id
            blueprint_paths << file_path
            break
          end
        rescue JSON::ParserError
          # Skip files with invalid JSON
          next
        end
      end
    end
    
    # Return the first match if any found
    blueprint_paths.first
  end

  def definition_exists?(item_id)
    # Check if it's a material
    return true if material_exists?(item_id)
    
    # Check if it's a unit (has a data file)
    return true if find_unit_definition(item_id)
    
    # Check if it's a blueprint
    return true if find_blueprint_definition(item_id)
    
    # Not found
    false
  end
rescue StandardError => e
  puts "FATAL ERROR: #{e.message}"
  puts e.backtrace.join("\n") if ARGV.include?('--debug')
  exit 1
end

def check_cargo_manifest(manifest_id)
  manifest_path = File.join(BASE_DIR, 'starship-cargo-manifest', "#{manifest_id}.json")
  
  unless File.exist?(manifest_path)
    puts "Manifest file not found: #{manifest_path}"
    return []
  end
  
  begin
    manifest = JSON.parse(File.read(manifest_path))
    
    puts "Checking cargo manifest: #{File.basename(manifest_path)}"
    puts "Description: #{manifest['description']}"
    
    missing_items = []
    found_items = []
    
    # Check installed units
    if manifest['craft'] && manifest['craft']['installed_units']
      manifest['craft']['installed_units'].each do |unit|
        # Try multiple variations of the unit name
        unit_name = unit['name']
        unit_id = unit['id'] || unit_name.downcase.gsub(/\s+/, '_')
        
        # Create additional search variations
        variations = [
          unit_id,
          unit_id.gsub(/_unit$/, ''),  # Without _unit suffix
          "#{unit_id}_data",           # With _data suffix
          unit_name.downcase           # Plain lowercase name
        ]
        
        found = false
        variations.each do |variation|
          if definition_exists?(variation)
            found_items << { id: unit_id, type: 'installed_unit', name: unit_name }
            found = true
            break
          end
        end
        
        unless found
          missing_items << { id: unit_id, type: 'installed_unit', name: unit_name }
        end
      end
    end
    
    # Check stowed units if they exist
    if manifest['craft'] && manifest['craft']['stowed_units']
      manifest['craft']['stowed_units'].each do |unit|
        unit_id = unit['blueprint_id'] || unit['id'] || unit['name'].downcase.gsub(/\s+/, '_')
        
        if definition_exists?(unit_id)
          found_items << { id: unit_id, type: 'stowed_unit', name: unit['name'] }
        else
          missing_items << { id: unit_id, type: 'stowed_unit', name: unit['name'] }
        end
      end
    end
    
    # Print results
    puts "\nResults:"
    puts "Found #{found_items.size} items:"
    found_items.each do |item|
      puts "  ✓ #{item[:name]} (#{item[:id]}) - #{item[:type]}"
    end
    
    puts "\nMissing #{missing_items.size} items:"
    missing_items.each do |item|
      puts "  ✗ #{item[:name]} (#{item[:id]}) - #{item[:type]}"
    end
    
    # Return missing items for potential auto-generation
    missing_items
  rescue => e
    puts "Error checking manifest: #{e.message}"
    []
  end
end

# Test path resolution
test_paths

# Check the specific cargo manifest
puts "\n===== Checking Cargo Manifest SSC-000 ====="
check_cargo_manifest("ssc-000")
puts "===== End Cargo Manifest Check =====\n"

def material_exists?(material_id)
  # Normalize the material_id
  material_id = material_id.to_s.downcase.gsub(/\s+/, '_')
  
  # Check for material file in various directories
  [
    File.join(BASE_DIR, 'materials', '**', "#{material_id}.json"),
    File.join(BASE_DIR, 'materials', 'processed', 'refined_metals', "#{material_id}.json"),
    File.join(BASE_DIR, 'materials', 'processed', 'chemical_compounds', "#{material_id}.json"),
    File.join(BASE_DIR, 'materials', 'raw', '**', "#{material_id}.json")
  ].each do |pattern|
    matches = Dir.glob(pattern)
    return true if matches.any?
  end
  
  false
end