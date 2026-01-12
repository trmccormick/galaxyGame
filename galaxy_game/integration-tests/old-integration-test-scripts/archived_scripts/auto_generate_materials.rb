#!/usr/bin/env ruby
require File.expand_path('../../config/environment', __dir__) rescue nil
require_relative 'check_blueprint_materials' # Use your existing checker

class MaterialGenerator
  require_relative '../../../../config/initializers/game_data_paths'
  attr_reader :generated_count, :validated_count, :needs_manual_count

  BASE_DIR = GalaxyGame::Paths::MATERIALS_PATH.to_s
  
  PERIODIC_TABLE = {
    'hydrogen' => { symbol: 'H', atomic_number: 1, category: 'gas', state: 'Gas', description: 'Lightest element, abundant in the universe', melting_point: -259.14, boiling_point: -252.87 },
    'helium' => { symbol: 'He', atomic_number: 2, category: 'gas', state: 'Gas', description: 'Noble gas, second most abundant element in the universe', melting_point: -272.2, boiling_point: -268.9 },
    'carbon' => { symbol: 'C', atomic_number: 6, category: 'nonmetal', state: 'Solid', description: 'Basis for all known life, forms many compounds', melting_point: 3550, boiling_point: 4027 },
    'oxygen' => { symbol: 'O', atomic_number: 8, category: 'gas', state: 'Gas', description: 'Highly reactive nonmetal essential for respiration', melting_point: -218.79, boiling_point: -182.95 },
    'aluminum' => { symbol: 'Al', atomic_number: 13, category: 'metal', state: 'Solid', description: 'Low density metal used in aerospace', melting_point: 660.32, boiling_point: 2519 },
    'silicon' => { symbol: 'Si', atomic_number: 14, category: 'metalloid', state: 'Solid', description: 'Semiconductor used in electronics', melting_point: 1414, boiling_point: 3265 },
    'iron' => { symbol: 'Fe', atomic_number: 26, category: 'metal', state: 'Solid', description: 'Most common element forming the Earth, essential for blood production', melting_point: 1538, boiling_point: 2862 },
    'copper' => { symbol: 'Cu', atomic_number: 29, category: 'metal', state: 'Solid', description: 'Excellent conductor of heat and electricity', melting_point: 1085, boiling_point: 2927 },
    'gold' => { symbol: 'Au', atomic_number: 79, category: 'metal', state: 'Solid', description: 'Precious metal highly valued throughout human history', melting_point: 1064, boiling_point: 2970 },
    'titanium' => { symbol: 'Ti', atomic_number: 22, category: 'metal', state: 'Solid', description: 'Strong, lightweight metal resistant to corrosion', melting_point: 1668, boiling_point: 3287 },
    # Add more elements as needed
  }
  
  # Base celestial materials - avoids hardcoding specific planetary regoliths
  CELESTIAL_MATERIALS = {
    'regolith' => { 
      category: 'geological_materials', 
      type: 'raw_material', 
      description: 'Fine particles of crushed rock covering the surface of a celestial body', 
      properties: {
        'extraction_difficulty': 'low',
        'processing_requirements': { 
          'temperature_range': { 'min': 600, 'max': 1200 },
          'pressure_range': { 'min': 0.8, 'max': 1.2 }
        }
      }
    },
    'ice' => { 
      category: 'liquid', 
      type: 'raw_material', 
      description: 'Frozen water and other volatiles found on celestial bodies', 
      properties: {
        'extraction_difficulty': 'medium',
        'melting_point': 273,
        'composition': ['H2O', 'CO2', 'NH3', 'CH4']
      }
    },
    'silicate' => { 
      category: 'geological_materials', 
      type: 'raw_material', 
      description: 'Silicon-based minerals common throughout the solar system', 
      properties: {
        'extraction_difficulty': 'medium',
        'processing_temperature': 1500,
        'typical_composition': ['Silicon', 'Oxygen', 'Aluminum', 'Calcium']
      }
    },
    'carbonaceous_material' => { 
      category: 'geological_materials', 
      type: 'raw_material', 
      description: 'Carbon-rich material found in certain asteroids and comets', 
      properties: {
        'extraction_difficulty': 'medium',
        'organic_content': 'high',
        'typical_composition': ['Carbon', 'Hydrogen', 'Oxygen', 'Nitrogen']
      }
    }
  }

  def initialize
    @missing_materials = []
    @generated_count = 0
    @validated_count = 0
    @needs_manual_count = 0
    @generated_files = []
    @issues_found = []
  end

  def run
    # Get missing materials from your existing checker
    puts "Running blueprint checker to find missing materials..."
    
    # Run in 'check' mode (non-destructive)
    checker = UniversalDefinitionChecker.new
    
    # Collect missing definitions directly from the checker
    # (You can modify this to use your existing checker's output)
    all_materials_from_blueprints = collect_materials_from_blueprints(checker)
    
    # Filter to find only missing materials
    @missing_materials = find_missing_materials(all_materials_from_blueprints, checker)
    
    puts "Found #{@missing_materials.size} missing materials."
    
    # Categorize and generate
    generate_missing_materials
    
    # Validate existing materials
    validate_existing_materials
    
    # Report results
    report_results
  end
  
  def collect_materials_from_blueprints(checker)
    materials = Set.new
    
    # Use the blueprint lookup service to get all blueprints
    blueprint_service = checker.lookup_services[:blueprint]
    return [] unless blueprint_service
    
    blueprints = blueprint_service.all_blueprints
    
    blueprints.each do |blueprint|
      # Extract materials from various blueprint fields
      if blueprint['materials'].is_a?(Array)
        blueprint['materials'].each do |material|
          materials.add(material['material']) if material['material']
        end
      end
      
      # Add more extraction logic as needed based on your blueprint structure
    end
    
    materials.to_a
  end
  
  def find_missing_materials(materials, checker)
    missing = []
    
    materials.each do |material|
      missing << material unless checker.definition_exists?(material)
    end
    
    missing
  end

  def generate_missing_materials
    puts "Analyzing missing materials..."
    
    @missing_materials.each do |material|
      # Normalize the material name
      material_id = material.downcase.gsub(/\s+/, '_')
      
      if can_auto_generate?(material_id)
        # Generate the appropriate JSON file
        if generate_material(material_id)
          @generated_count += 1
        else
          @needs_manual_count += 1
        end
      else
        puts "Material '#{material}' needs manual creation."
        @needs_manual_count += 1
      end
    end
  end

  def can_auto_generate?(material_id)
    # Check if it's a basic element
    return true if PERIODIC_TABLE.key?(material_id)
    
    # Check if it's a generic celestial material
    return true if CELESTIAL_MATERIALS.key?(material_id)
    
    # Check if it's an ore of a known element
    if material_id.end_with?('_ore')
      element = material_id.gsub(/_ore$/, '')
      return true if PERIODIC_TABLE.key?(element)
    end
    
    # Check if it's a compound of known elements
    if material_id.include?('_compound') || material_id.include?('_oxide') || 
       material_id.include?('_sulfide') || material_id.include?('_silicate')
      # Extract potential elements from compound name
      PERIODIC_TABLE.keys.each do |element|
        return true if material_id.include?(element)
      end
    end
    
    false
  end

  def generate_material(material_id)
    # Determine the material type and appropriate template
    if PERIODIC_TABLE.key?(material_id)
      generate_element(material_id)
    elsif CELESTIAL_MATERIALS.key?(material_id)
      generate_celestial_material(material_id)
    elsif material_id.end_with?('_ore')
      generate_ore(material_id)
    elsif material_id.include?('_compound') || material_id.include?('_oxide') || 
          material_id.include?('_sulfide') || material_id.include?('_silicate')
      generate_compound(material_id)
    else
      return false
    end
    
    true
  end

  def generate_element(element_id)
    element_data = PERIODIC_TABLE[element_id]
    
    # Determine appropriate directory
    if element_data[:state] == 'Gas'
      directory = File.join(BASE_DIR, 'raw', 'gases')
    elsif ['metal', 'metalloid'].include?(element_data[:category])
      directory = File.join(BASE_DIR, 'processed', 'refined_metals')
    else
      directory = File.join(BASE_DIR, 'raw', 'other')
    end
    
    # Create material JSON
    material = {
      "id" => element_id,
      "name" => element_id.capitalize,
      "category" => element_data[:category],
      "type" => "raw_material",
      "description" => element_data[:description],
      "properties" => {
        "chemical_symbol" => element_data[:symbol],
        "atomic_number" => element_data[:atomic_number],
        "unit_of_measurement" => "kilogram",
        "state_at_room_temp" => element_data[:state],
        "melting_point" => element_data[:melting_point],
        "boiling_point" => element_data[:boiling_point]
      },
      "applications" => [
        "various_industrial_uses",
        "scientific_research"
      ],
      "trade_value" => calculate_trade_value(element_data)
    }
    
    save_material(material, directory)
  end

  def generate_celestial_material(material_id)
    material_data = CELESTIAL_MATERIALS[material_id]
    
    # Determine appropriate directory
    directory = File.join(BASE_DIR, 'raw', material_data[:category])
    
    # Create material JSON - but designed for your flexible approach
    material = {
      "id" => material_id,
      "name" => material_id.capitalize,
      "category" => material_data[:category].gsub(/_materials$/, ''),
      "type" => material_data[:type],
      "description" => material_data[:description],
      "properties" => material_data[:properties] || {
        "unit_of_measurement" => "kilogram",
        "state_at_room_temp" => "Solid"
      },
      "processing_output" => [
        {
          "method" => "heating",
          "temperature" => material_data[:properties]&.dig("processing_requirements", "temperature_range", "min") || 800,
          "outputs" => [
            {
              "material" => "Oxygen",
              "percentage" => 10 + rand(20),
              "state" => "Gas"
            },
            {
              "material" => "Various Metals",
              "percentage" => 30 + rand(20),
              "state" => "Solid"
            }
          ]
        }
      ],
      "trade_value" => 25 + rand(25)
    }
    
    save_material(material, directory)
  end

  def generate_ore(material_id)
    element = material_id.gsub(/_ore$/, '')
    
    # Skip if we don't know this element
    return false unless PERIODIC_TABLE.key?(element)
    
    element_data = PERIODIC_TABLE[element]
    
    # Create ores/{element} directory
    directory = File.join(BASE_DIR, 'raw', 'ores', element)
    
    # Determine ore properties based on element
    ore_name = "#{element.capitalize} Ore"
    
    # Create a generic ore name for the element
    primary_mineral = case element
      when 'iron' then 'hematite'
      when 'copper' then 'chalcopyrite'
      when 'aluminum' then 'bauxite'
      when 'gold' then 'native gold'
      when 'titanium' then 'ilmenite'
      else "#{element}_mineral"
    end
    
    # Create material JSON
    material = {
      "id" => material_id,
      "name" => ore_name,
      "category" => "ore",
      "type" => "raw_material",
      "subtype" => "#{element}_ore",
      "description" => "Raw, unprocessed ore containing #{element.capitalize}.",
      "properties" => {
        "unit_of_measurement" => "metric_ton",
        "state_at_room_temp" => "Solid",
        "primary_mineral" => primary_mineral
      },
      "composition" => [
        {
          "element" => element.capitalize,
          "percentage" => 15 + rand(40),
          "form" => primary_mineral
        },
        {
          "element" => "Various minerals",
          "percentage" => 40 + rand(30)
        }
      ],
      "extraction_methods" => [
        "Mining",
        "Crushing",
        "Concentration"
      ],
      "smelting_output" => [
        {
          "material" => element,
          "yield_percentage" => 10 + rand(40)
        }
      ],
      "locations" => [
        "Various planetary bodies",
        "Asteroid belts"
      ],
      "trade_value" => 30 + rand(30)
    }
    
    save_material(material, directory)
  end

  def generate_compound(material_id)
    # Create a basic compound
    words = material_id.split('_')
    
    # Try to identify the elements in this compound
    involved_elements = []
    PERIODIC_TABLE.keys.each do |element|
      involved_elements << element if words.include?(element)
    end
    
    # Default to chemical compounds directory
    directory = File.join(BASE_DIR, 'processed', 'chemical_compounds')
    
    # Create material JSON
    material = {
      "id" => material_id,
      "name" => words.map(&:capitalize).join(' '),
      "category" => "chemical_compound",
      "type" => "processed_material",
      "description" => "A compound containing #{involved_elements.map(&:capitalize).join(', ')}.",
      "properties" => {
        "unit_of_measurement" => "kilogram",
        "state_at_room_temp" => "Solid" # Default to solid
      },
      "composition" => involved_elements.map { |element| 
        { "element" => element.capitalize, "percentage" => rand(20..60) }
      },
      "applications" => [
        "industrial_processes",
        "manufacturing"
      ],
      "trade_value" => 45 + rand(30)
    }
    
    save_material(material, directory)
  end

  def save_material(material, directory)
    # Ensure directory exists
    FileUtils.mkdir_p(directory) unless Dir.exist?(directory)
    
    # Create the file path
    file_path = File.join(directory, "#{material['id']}.json")
    
    # Save the file
    File.write(file_path, JSON.pretty_generate(material))
    
    # Mark as auto-generated
    File.write("#{file_path}.generated", Time.now.to_s)
    
    @generated_files << file_path
    puts "Generated material: #{material['id']} → #{file_path}"
  end

  def validate_existing_materials
    puts "\nValidating existing material files..."
    
    # Find all material JSON files
    all_material_files = Dir.glob(File.join(BASE_DIR, '**', '*.json'))
    
    all_material_files.each do |file_path|
      # Skip if this is a newly generated file
      next if @generated_files.include?(file_path)
      
      begin
        # Try to parse the JSON
        material = JSON.parse(File.read(file_path))
        
        # Check for required fields
        required_fields = ['id', 'name', 'type', 'description']
        missing_fields = required_fields.reject { |field| material.key?(field) }
        
        if missing_fields.any?
          @issues_found << "#{file_path}: Missing required fields: #{missing_fields.join(', ')}"
        else
          @validated_count += 1
        end
      rescue JSON::ParserError => e
        @issues_found << "#{file_path}: Invalid JSON: #{e.message}"
      rescue => e
        @issues_found << "#{file_path}: Error: #{e.message}"
      end
    end
  end

  def report_results
    puts "\n=== Material Generation Report ==="
    puts "Missing materials found: #{@missing_materials.size}"
    puts "Materials auto-generated: #{@generated_count}"
    puts "Existing materials validated: #{@validated_count}"
    puts "Materials needing manual creation: #{@needs_manual_count}"
    
    if @issues_found.any?
      puts "\nIssues found in existing material files:"
      @issues_found.each { |issue| puts "- #{issue}" }
    end
    
    puts "\nGenerated material files:"
    @generated_files.each { |file| puts "- #{file}" }
  end

  private

  def calculate_trade_value(element_data)
    # Simple algorithm to determine value based on properties
    base_value = 50
    
    # Rarer elements are worth more
    if element_data[:atomic_number] > 70
      base_value += 100
    elsif element_data[:atomic_number] > 30
      base_value += 50
    end
    
    # Metals are generally more valuable
    base_value += 30 if element_data[:category] == 'metal'
    
    # Add some randomness
    base_value + rand(20)
  end
end

# Run the generator if called directly
if __FILE__ == $0
  generator = MaterialGenerator.new
  generator.run
end