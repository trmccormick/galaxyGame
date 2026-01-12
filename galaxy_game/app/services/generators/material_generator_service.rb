# app/services/generators/material_generator_service.rb

require 'net/http'
require 'json'
require 'fileutils'
require 'active_support/core_ext/string/inflections' # For .titleize
require 'yaml' 
require_relative 'game_data_generator' 

module Generators
  class MaterialGeneratorService
    # Current, structured location for v1.3 materials
    BASE_DIR = GalaxyGame::Paths::JSON_DATA.join('resources', 'materials')
    
    # FOCUSED LEGACY DIRECTORY (Corrected path based on user input)
    # This targets the specific folder we are validating the migration against.
    LEGACY_DIRS = [
      GalaxyGame::Paths::JSON_DATA.join('old-json-data', 'production_old4', 'materials')
    ].freeze

    TARGET_VERSION = "1.3"
    
    # --- PUBLIC API ---
    
    def self.generate_material(material_id)
    material_id = material_id.to_s.downcase.gsub(/\s+/, '_')
    
    # 1. Check for material in current BASE_DIR or the focused LEGACY_DIRS
    existing_file = find_existing_material_file(material_id)
    
    if existing_file
      data = load_material(existing_file)
      version = data.dig("metadata", "version") || "0.0"

      is_legacy_file = LEGACY_DIRS.any? { |dir| existing_file.to_s.start_with?(dir.to_s) }
      
      if Gem::Version.new(version) < Gem::Version.new(TARGET_VERSION)
        
        if is_legacy_file
          # Migration for files from the specific old directory structure
          Rails.logger.info "Migrating FOCUSED LEGACY material '#{material_id}' to v#{TARGET_VERSION}."
          data = migrate_legacy_to_v1_2(data)
        else
          # Migration for files from the current directory that might be v1.0 or v1.1
          Rails.logger.info "Migrating standard material '#{material_id}' from v#{version} to v#{TARGET_VERSION}."
          data = migrate_standard_to_v1_2(data)
        end
        
        # Resave the migrated file to its *new*, correct location within BASE_DIR
        save_material(data) 
      end
      return data
    end
    
    # If not found, generate it fresh (will be v1.2 compliant immediately)
    material_data = fetch_material_data(material_id)
    save_material(material_data)
    material_data
  end
  
  # --- PERSISTENCE & LOADING ---

  def self.find_existing_material_file(material_id)
    # 1. Search in the current BASE_DIR first
    current_file = Dir.glob(File.join(BASE_DIR, '**', "#{material_id}.json")).first
    return current_file if current_file
    
    # 2. Search in the focused LEGACY_DIRS
    LEGACY_DIRS.each do |dir|
      legacy_file = Dir.glob(File.join(dir, "#{material_id}.json")).first 
      return legacy_file if legacy_file
    end
    
    nil
  end
  
  def self.load_material(file_path)
    # Attempt JSON parse
    JSON.parse(File.read(file_path))
  rescue JSON::ParserError
    Rails.logger.warn "JSON parse failed for #{file_path}, attempting YAML."
    YAML.load_file(file_path)
  rescue => e
    Rails.logger.error "Error loading material from #{file_path}: #{e.message}"
    nil
  end
  
  def self.save_material(material_data, custom_path = nil)
    relative_path = custom_path || determine_save_path(material_data)
    full_path = File.join(BASE_DIR, relative_path)
    
    FileUtils.mkdir_p(File.dirname(full_path)) unless Dir.exist?(File.dirname(full_path))
    File.write(full_path, JSON.pretty_generate(material_data))
    File.write("#{full_path}.generated", Time.now.to_s)
    Rails.logger.info "Generated/Updated material: #{full_path}"
  end
  
  # --- MIGRATION LOGIC ---

  def self.migrate_standard_to_v1_2(old_data)
    # This handles migration for files that were already partially structured (e.g., from PubChem)
    new_data = {
      "template" => "material",
      "id" => old_data["id"],
      "name" => old_data["name"],
      "description" => old_data["description"],
      "category" => old_data["category"],
      "subcategory" => old_data["subcategory"] || "general",
      "metadata" => { "version" => TARGET_VERSION, "type" => "material" },
      "trade_value" => old_data["trade_value"] || 0,
      # Initialize complex sections for enrichment
      "properties" => old_data["properties"] || {},
      "sources" => {},
      "composition" => [],
      "applications" => old_data["applications"] || [],
      "production" => {},
      "requirements" => { "technology" => [], "facilities" => [] },
      "pricing" => {}
    }
    
    enrich_data_with_llm(new_data)
  end
  
  def self.migrate_legacy_to_v1_2(legacy_data)
    # Handles migration from the old, simple structure (like 'acetylene')
    new_data = {
      "template" => "material",
      "id" => legacy_data["id"],
      "name" => legacy_data["name"],
      "description" => legacy_data["description"],
      "category" => legacy_data["category"] || determine_category(legacy_data["id"]),
      "subcategory" => legacy_data["subtype"] || "general", # Map old 'subtype'
      "metadata" => {
        "version" => TARGET_VERSION,
        "type" => "material"
      },
      "properties" => {
        # Map simple properties to the new structured properties
        "unit_of_measurement" => "kg", 
        "purity" => "99.9%",
        # Directly map 'state_at_room_temp'
        "state_at_room_temp" => legacy_data.dig("properties", "state_at_room_temp") || "solid", 
        "color" => legacy_data.dig("properties", "color") || "unknown",
        "electrical_conductivity" => "unknown" 
      },
      # Preserve simple list data
      "applications" => legacy_data["applications"] || [],
      
      # Initialize complex sections for LLM to fill
      "sources" => {}, 
      "composition" => [],
      "production" => {},
      "requirements" => { "technology" => [], "facilities" => [] },
      "pricing" => {},
      "trade_value" => 0 
    }
    
    # CRITICAL: Pass the entire legacy data (including 'chemical_formula', 'hazards', 'processing', and detailed 'properties') 
    # as old_context for the LLM to intelligently generate the production, requirements, and composition blocks.
    enrich_data_with_llm(new_data, legacy_data)
  end
  
  def self.enrich_data_with_llm(data, old_context = {})
    Rails.logger.info "Enriching material data with LLM for: #{data['id']}"
    
    generator = GameDataGenerator.new 
    
    custom_prompt_params = {
      description: "Complete the full v1.3 JSON schema for this material. Use the existing data to preserve basic fields and intelligently fill in all missing details like 'composition', 'production', and 'pricing' based on the material's identity. CRITICAL: Factor in the following legacy information into your decision-making for production and pricing: #{JSON.generate(old_context)}",
      category: data['category'],
      id: data['id'],
      name: data['name'],
      existing_data: JSON.generate(data) 
    }

    template_path = GalaxyGame::Paths::JSON_DATA.join('templates', 'material_v1.3.json').to_s
    
    # Note: The GameDataGenerator uses a separate LLM call to generate a complete JSON object 
    # based on the material_v1.3 schema compliance requirement.
    enriched_json_string = generator.generate_item(
      template_path,
      BASE_DIR.join('temp', "#{data['id']}_enriched.json").to_s, 
      custom_prompt_params.merge({ 
        metadata: { "template_compliance" => "material_v1.3", "type" => "material" }
      })
    )

    JSON.parse(enriched_json_string)
  rescue => e
    Rails.logger.error "LLM enrichment failed for material #{data['id']}: #{e.message}"
    data 
  end

  # --- DATA FETCHING & GENERATION ---
  
  def self.fetch_material_data(material_id)
    # Fallback to full synthetic generation if not found in current or legacy directories
    data = generate_synthetic_data_full(material_id)
    
    # Ensure newly generated data is saved in the correct v1.3 format
    # data = migrate_standard_to_v1_3(data) if data && data.dig("metadata", "version").to_s != TARGET_VERSION
    data
  end
  
  def self.generate_synthetic_data_full(material_id)
    Rails.logger.warn "Using LLM to generate FULL synthetic data for: #{material_id}"
    
    generator = GameDataGenerator.new 
    
    template_path = GalaxyGame::Paths::JSON_DATA.join('templates', 'material_v1.3.json').to_s
    
    template = {
      "metadata" => { "template_compliance" => "material_v1.3", "type" => "material" },
      "id" => material_id,
      "name" => material_id.gsub('_', ' ').titleize,
    }

    temp_output_path = BASE_DIR.join('temp', "#{material_id}.json").to_s
    
    generator.generate_item(
      template_path, 
      temp_output_path, 
      template.merge({ category: determine_category(material_id), description: "A synthetically generated compound or material." })
    )
  rescue => e
    Rails.logger.error "Synthetic data generation (LLM) failed for #{material_id}: #{e.message}"
    nil
  end
  
  # --- HELPER METHODS ---

  def self.determine_save_path(material)
    category = material["category"]
    id = material["id"]
    
    case category
    when "ore"
      "raw/#{id}.json"
    when "element", "metal", "alloy"
      "processed/#{id}.json"
    when "component"
      "components/#{id}.json"
    when "chemical_compound", "synth_resource"
      "chemicals/#{id}.json"
    when "gas"
      "gases/#{id}.json"
    when "liquid"
      "liquids/#{id}.json"
    when "building"
      "building/#{id}.json"
    when "byproduct"
      "byproducts/#{id}.json"
    else
      "processed/#{id}.json"
    end
  end

  def self.determine_category(material_id)
    case material_id
    when /_ore$/ then "ore"
    when /steel|titanium|gold|alloy/ then "alloy"
    when /water|liquid|acid|solution/ then "liquid"
    when /gas|oxygen|hydrogen|nitrogen|helium/ then "gas"
    when /chemical|compound|acid|polymer/ then "chemical_compound"
    when /component|circuit|module|panel/ then "component"
    when /building|structure|facility/ then "building"
    when /byproduct|waste|slag/ then "byproduct"
    else "element"
    end
  end
  end
end