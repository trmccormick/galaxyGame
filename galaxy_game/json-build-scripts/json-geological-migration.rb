require 'json'
require 'fileutils'
require_relative '../app/services/game_data_generator'

class GeologicalMaterialMigration
  # Always use container paths since we're running in Docker
  SOURCE_ROOT = '/home/galaxy_game/app/data/old-json-data/production_old3/materials/raw/geological_materials'
  TARGET_ROOT = '/home/galaxy_game/app/data/resources/materials/raw/geological'
  
  # Templates path for Ollama generation
  TEMPLATES_PATH = '/home/galaxy_game/app/data/templates'
  
  # Template definitions
  GEOLOGICAL_TEMPLATE_PATH = "#{TEMPLATES_PATH}/geological_material_template.json"
  ORE_TEMPLATE_PATH = "#{TEMPLATES_PATH}/ore_material_template.json"
  
  def initialize
    # Initialize the Ollama-based data generator
    @generator = GameDataGenerator.new('llama3')
    
    # Make sure template directory exists
    FileUtils.mkdir_p(TEMPLATES_PATH) unless File.directory?(TEMPLATES_PATH)
    
    # Create templates if they don't exist
    create_templates
    
    puts "Running migration in Docker container environment"
    puts "Source root: #{SOURCE_ROOT}"
    puts "Target root: #{TARGET_ROOT}"
  end

  def run
    puts "Starting geological material migration..."
    migrate_geological_materials
    puts "Migration complete!"
  end

  def migrate_geological_materials
    migrated_count = 0
    error_count = 0
    
    # Check if source directory exists
    unless File.directory?(SOURCE_ROOT)
      puts "WARNING: Source directory #{SOURCE_ROOT} does not exist! Creating geological materials from scratch."
      generate_essential_materials
      return true
    end
    
    # Create target directories if they don't exist
    ['ore', 'stone', 'soil', 'mineral', 'gem'].each do |subdir|
      dir_path = File.join(TARGET_ROOT, subdir)
      FileUtils.mkdir_p(dir_path)
      puts "Created directory: #{dir_path}"
    end
    
    # Handle ores in their nested structure
    ores_dir = File.join(SOURCE_ROOT, 'ores')
    puts "Checking if ores directory exists: #{File.directory?(ores_dir)}"
    if File.directory?(SOURCE_ROOT)
      puts "Available directories in SOURCE_ROOT:"
      Dir.entries(SOURCE_ROOT).each { |entry| puts "  - #{entry}" }
    end
    if File.directory?(ores_dir)
      puts "Found ores directory at #{ores_dir}"
      
      # Get a direct list of subdirectories
      metal_dirs = Dir.glob(File.join(ores_dir, '*')).select do |path|
        File.directory?(path) && !File.basename(path).start_with?('.')
      end.map { |path| File.basename(path) }
      
      puts "Found #{metal_dirs.size} metal directories: #{metal_dirs.join(', ')}"
      
      migrated_count = 0
      error_count = 0
      
      metal_dirs.each do |metal_dir|
        metal_path = File.join(ores_dir, metal_dir)
        puts "Processing ores in #{metal_path}"
        
        # Find all JSON files for this metal
        ore_files = Dir.glob(File.join(metal_path, '*.json'))
        puts "Found #{ore_files.size} ore files in #{metal_dir}/"
        
        ore_files.each do |file_path|
          begin
            filename = File.basename(file_path)
            material_id = filename.gsub('.json', '')
            
            # Read source file
            json_data = JSON.parse(File.read(file_path))
            
            # Add metal information if not already present
            json_data["primary_element"] ||= metal_dir unless metal_dir == "multi_metal"
            
            # Force material type to 'ore'
            material_type = 'ore'
            
            # Migrate the data
            target_path = File.join(TARGET_ROOT, material_type, filename)
            migrate_material(json_data, material_id, material_type, target_path)
            
            puts "Migrated: #{metal_dir}/#{material_id} to #{material_type}/#{filename}"
            migrated_count += 1
          rescue => e
            puts "ERROR processing #{file_path}: #{e.message}"
            error_count += 1
          end
        end
      end
      
      puts "Nested ore migration complete: #{migrated_count} migrated, #{error_count} errors"
    else
      puts "No nested ores directory found at #{ores_dir}"
    end
    
    # Ensure essential materials exist
    ensure_essential_materials_exist
    
    # Process files from root directory
    material_files = Dir.glob(File.join(SOURCE_ROOT, '*.json'))
    material_files.each do |file_path|
      begin
        filename = File.basename(file_path)
        material_id = filename.gsub('.json', '')
        
        # Read source file
        json_data = JSON.parse(File.read(file_path))
        
        # Determine material type if not explicitly set
        material_type = json_data["type"] || determine_material_type(material_id, json_data)
        
        # Migrate the data
        target_path = File.join(TARGET_ROOT, material_type, filename)
        migrate_material(json_data, material_id, material_type, target_path)
        
        puts "Migrated: #{material_id} to #{material_type}/#{filename}"
        migrated_count += 1
      rescue => e
        puts "ERROR processing #{file_path}: #{e.message}"
        error_count += 1
      end
    end
    
    puts "Geological material migration complete: #{migrated_count} migrated, #{error_count} errors"
  end
  
  def migrate_material(json_data, material_id, material_type, target_path)
    # Choose the right template based on material type
    template_path = material_type == 'ore' ? ORE_TEMPLATE_PATH : GEOLOGICAL_TEMPLATE_PATH
    
    # Prepare parameters for generation
    params = {
      id: material_id,
      name: json_data["name"] || material_id.gsub('_', ' ').capitalize,
      type: material_type,
      description: json_data["description"] || "A #{material_type} found on various celestial bodies."
    }
    
    # Add additional parameters if available
    ["density", "hardness", "appearance", "color", "formation", "composition", "rarity"].each do |prop|
      params[prop.to_sym] = json_data[prop] if json_data[prop]
    end
    
    # For ores, set primary element based on composition or name
    if material_type == 'ore'
      if json_data["composition"] && json_data["composition"].is_a?(Array)
        params[:primary_element] = json_data["composition"].first
      else
        # Try to infer from name
        params[:primary_element] = infer_primary_element(material_id)
      end
    end
    
    # Generate the material data
    @generator.generate_item(template_path, target_path, params)
  end
  
  def infer_primary_element(material_id)
    case material_id.downcase
      when /iron/i, /hematite/i, /magnetite/i then "iron"
      when /copper/i, /chalcopyrite/i then "copper"
      when /aluminum/i, /bauxite/i then "aluminum"
      when /titanium/i, /ilmenite/i then "titanium"
      when /uranium/i, /uraninite/i then "uranium"
      when /gold/i then "gold"
      when /silver/i then "silver"
      when /platinum/i then "platinum"
      when /lead/i, /galena/i then "lead"
      when /zinc/i, /sphalerite/i then "zinc"
      when /nickel/i, /pentlandite/i then "nickel"
      when /cobalt/i, /cobaltite/i then "cobalt"
      when /lithium/i, /spodumene/i then "lithium"
      else "unknown"
    end
  end
  
  def determine_material_type(material_id, json_data)
    # Material-specific overrides
    case material_id
      when "lunar_regolith", "martian_regolith", "generic_regolith", "regolith", "clay"
        return "soil"
      when "anorthosite", "basalt", "granite", "limestone", "marble", "obsidian", "peridotite", "sandstone", "shale"
        return "stone"
      when "calcium_sulfate", "gypsum", "graphite", "silica", "sulfur"
        return "mineral"
      when "hydrocarbon_reservoirs"
        return "resource_deposit"
    end
    
    # Map old types to new types
    type_mapping = {
      "raw_material" => "stone",
      "solid" => "mineral",
      "raw_material_source" => "mineral"
    }
    
    # Check if the source has a type and map it
    if json_data["type"] && type_mapping[json_data["type"]]
      return type_mapping[json_data["type"]]
    end
    
    ores = [
      /iron/i, /copper/i, /gold/i, /silver/i, /aluminum/i, /titanium/i, 
      /uranium/i, /lead/i, /zinc/i, /nickel/i, /cobalt/i, /lithium/i,
      /rare_earth/i, /platinum/i, /hematite/i, /magnetite/i, /chalcopyrite/i,
      /bauxite/i, /ilmenite/i, /uraninite/i, /galena/i, /sphalerite/i,
      /pentlandite/i, /cobaltite/i, /spodumene/i, /cassiterite/i
    ]
    
    stones = [
      /granite/i, /basalt/i, /marble/i, /sandstone/i, /limestone/i,
      /slate/i, /obsidian/i, /pumice/i, /anorthosite/i
    ]
    
    soils = [
      /soil/i, /regolith/i, /dirt/i, /clay/i, /loam/i, /silt/i, /sand/i
    ]
    
    minerals = [
      /quartz/i, /feldspar/i, /mica/i, /calcite/i, /gypsum/i, /fluorite/i,
      /talc/i, /pyrite/i, /sulfur/i, /graphite/i, /diamond/i
    ]
    
    gems = [
      /diamond/i, /ruby/i, /sapphire/i, /emerald/i, /topaz/i, /amethyst/i,
      /opal/i, /jade/i, /turquoise/i, /garnet/i
    ]
    
    # Check against each category
    return 'ore' if ores.any? { |pattern| material_id =~ pattern }
    return 'stone' if stones.any? { |pattern| material_id =~ pattern }
    return 'soil' if soils.any? { |pattern| material_id =~ pattern }
    return 'gem' if gems.any? { |pattern| material_id =~ pattern }
    return 'mineral' if minerals.any? { |pattern| material_id =~ pattern }
    
    # Default to generic geological material
    return 'mineral'
  end
  
  def ensure_essential_materials_exist
    # List of essential materials for the game
    essential_materials = [
      {id: 'hematite', type: 'ore', name: 'Hematite', primary_element: 'iron'},
      {id: 'iron_ore', type: 'ore', name: 'Iron Ore', primary_element: 'iron'},
      {id: 'copper_ore', type: 'ore', name: 'Copper Ore', primary_element: 'copper'},
      {id: 'titanium_ore', type: 'ore', name: 'Titanium Ore', primary_element: 'titanium'},
      {id: 'lunar_regolith', type: 'soil', name: 'Lunar Regolith'},
      {id: 'martian_regolith', type: 'soil', name: 'Martian Regolith', color: 'reddish-brown'}
    ]
    
    essential_materials.each do |material|
      material_path = File.join(TARGET_ROOT, material[:type], "#{material[:id]}.json")
      
      unless File.exist?(material_path)
        puts "Creating essential material: #{material[:name]}"
        template_path = material[:type] == 'ore' ? ORE_TEMPLATE_PATH : GEOLOGICAL_TEMPLATE_PATH
        @generator.generate_item(template_path, material_path, material)
      end
    end
  end

  def generate_essential_materials
    puts "Generating essential geological materials from scratch using Ollama..."
    
    # Create target directories
    ['ore', 'stone', 'soil', 'mineral', 'gem'].each do |subdir|
      dir_path = File.join(TARGET_ROOT, subdir)
      FileUtils.mkdir_p(dir_path)
    end
    
    # Generate a basic set of materials
    ensure_essential_materials_exist
    
    # Additional materials to generate
    additional_materials = [
      # More ores
      {id: 'gold_ore', type: 'ore', name: 'Gold Ore', primary_element: 'gold', rarity: 'rare'},
      {id: 'silver_ore', type: 'ore', name: 'Silver Ore', primary_element: 'silver'},
      {id: 'aluminum_ore', type: 'ore', name: 'Aluminum Ore', primary_element: 'aluminum'},
      {id: 'uranium_ore', type: 'ore', name: 'Uranium Ore', primary_element: 'uranium', radioactive: true},
      
      # Stones
      {id: 'basalt', type: 'stone', name: 'Basalt', color: 'dark gray to black'},
      {id: 'granite', type: 'stone', name: 'Granite'},
      {id: 'lunar_anorthosite', type: 'stone', name: 'Lunar Anorthosite', color: 'light gray to white'},
      
      # Minerals
      {id: 'quartz', type: 'mineral', name: 'Quartz', color: 'clear to white'},
      {id: 'feldspar', type: 'mineral', name: 'Feldspar'},
      {id: 'silicon_dioxide', type: 'mineral', name: 'Silicon Dioxide'}
    ]
    
    # Generate all the additional materials
    additional_materials.each do |material|
      material_path = File.join(TARGET_ROOT, material[:type], "#{material[:id]}.json")
      
      puts "Generating additional material: #{material[:name]}"
      template_path = material[:type] == 'ore' ? ORE_TEMPLATE_PATH : GEOLOGICAL_TEMPLATE_PATH
      @generator.generate_item(template_path, material_path, material)
    end
  end
  
  def create_templates
    # Create geological material template if it doesn't exist
    unless File.exist?(GEOLOGICAL_TEMPLATE_PATH)
      geological_template = {
        "template" => "material",
        "category" => "geological",
        "id" => "geological_material_template",
        "name" => "Geological Material Template",
        "type" => "mineral", # Default, will be overridden
        "description" => "A geological material found on various celestial bodies.",
        "composition" => ["element1", "element2"],
        "density" => 3.5, # g/cm³
        "hardness" => 4.5, # Mohs scale
        "appearance" => "Crystalline",
        "color" => "Gray",
        "yield_rate" => 0.7,
        "formation" => "Forms under specific geological conditions",
        "common_locations" => ["Mars", "Moon", "Asteroids"],
        "extraction" => {
          "difficulty" => "moderate",
          "method" => "mining",
          "processing_required" => true,
          "hazards" => []
        },
        "properties" => {
          "radioactive" => false,
          "magnetic" => false,
          "conductive" => false,
          "flammable" => false
        },
        "resource_value" => {
          "rarity" => "common",
          "base_value" => 10,
          "industrial_uses" => ["construction", "manufacturing"]
        },
        "storage" => {
          "container_type" => "bulk",
          "stability" => "stable",
          "incompatible_with" => []
        }
      }
      
      File.write(GEOLOGICAL_TEMPLATE_PATH, JSON.pretty_generate(geological_template))
      puts "Created geological material template"
    end
    
    # Create ore template if it doesn't exist
    unless File.exist?(ORE_TEMPLATE_PATH)
      ore_template = {
        "template" => "material",
        "category" => "geological",
        "id" => "ore_template",
        "name" => "Ore Template",
        "type" => "ore",
        "description" => "A metal-bearing mineral of value.",
        "composition" => ["primary_element", "other_elements"],
        "primary_element" => "iron", # The main metal in the ore
        "density" => 4.5, # g/cm³
        "hardness" => 5.0, # Mohs scale
        "appearance" => "Crystalline",
        "color" => "Dark gray with metallic luster",
        "yield_rate" => 0.6,
        "formation" => "Forms in igneous or metamorphic environments",
        "common_locations" => ["Mars", "Asteroids", "Earth"],
        "extraction" => {
          "difficulty" => "hard",
          "method" => "mining",
          "processing_required" => true,
          "hazards" => ["dust"]
        },
        "properties" => {
          "radioactive" => false,
          "magnetic" => false, 
          "conductive" => false,
          "flammable" => false
        },
        "purity" => 65, # Percentage of target element
        "processing" => {
          "refining_method" => "smelting",
          "byproducts" => ["slag"],
          "energy_requirement" => 5000, # kWh per ton
          "refined_output_ratio" => 0.65, # How much refined product per raw ore
          "pollution_factor" => "moderate" # Environmental impact of processing
        },
        "resource_value" => {
          "rarity" => "uncommon",
          "base_value" => 25,
          "industrial_uses" => ["metal production", "construction"]
        },
        "storage" => {
          "container_type" => "bulk",
          "stability" => "stable",
          "incompatible_with" => []
        }
      }
      
      File.write(ORE_TEMPLATE_PATH, JSON.pretty_generate(ore_template))
      puts "Created ore template"
    end
  end
end

# Run the migration
migration = GeologicalMaterialMigration.new
migration.run
