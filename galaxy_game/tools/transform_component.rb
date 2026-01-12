#!/usr/bin/env ruby
# transform_component.rb - Transforms old component data to new template format

require 'json'
require 'fileutils'
require_relative '../app/services/game_data_generator'

class ComponentTransformer
  HARVESTABLE_MATERIALS = [
    # Raw geological materials
    'regolith', 'iron_ore', 'copper_ore', 'titanium_ore', 'aluminum_ore', 'silicon_ore',
    # Raw atmospheric
    'carbon_dioxide', 'methane', 'oxygen', 'nitrogen', 'hydrogen',
    # Basic processed
    'metal_plate', 'wire', 'glass', 'circuit_board', 'plastic'
  ].freeze

  # Material substitutions to use when finding unsuitable materials
  MATERIAL_SUBSTITUTIONS = {
    'steel' => { 'default' => 'iron_ore', 'lunar' => 'regolith' },
    'electronics' => { 'default' => 'circuit_board' },
    'silicon_wafer' => { 'default' => 'silicon_ore' }
  }.freeze

  def initialize
    @generator = GameDataGenerator.new
    @material_lookup = Lookup::MaterialLookupService.new
  end

  # Main method to transform a component
  def transform(component_id, component_type, environment = 'default')
    puts "🔄 Transforming component: #{component_id} (#{component_type})"
    
    # Search for component in old data
    old_data = find_old_component_data(component_id, component_type)
    
    if old_data.empty?
      puts "❌ No old data found for #{component_id}"
      return false
    end
    
    # Extract data from old files
    blueprint_data = old_data.find { |d| d[:is_blueprint] }
    operational_data = old_data.find { |d| !d[:is_blueprint] }
    
    puts "📄 Found old data files:"
    puts "  - Blueprint: #{blueprint_data ? blueprint_data[:path] : 'Not found'}"
    puts "  - Operational: #{operational_data ? operational_data[:path] : 'Not found'}"
    
    # Load templates
    blueprint_template = load_template_for(component_type, true)
    operational_template = load_template_for(component_type, false)
    
    # Transform the data
    transformed_blueprint = transform_blueprint(
      blueprint_data, 
      blueprint_template, 
      component_id, 
      environment
    ) if blueprint_data
    
    transformed_operational = transform_operational(
      operational_data, 
      operational_template, 
      component_id
    ) if operational_data
    
    # Check if we're missing either file
    if !blueprint_data || !operational_data
      puts "⚠️ Missing some component data, using generator to fill gaps"
      
      # Extract basic metadata from what we have
      metadata = extract_metadata(blueprint_data || operational_data)
      
      # Generate missing files
      if !blueprint_data && operational_data
        transformed_blueprint = generate_blueprint(metadata, blueprint_template)
      elsif blueprint_data && !operational_data
        transformed_operational = generate_operational(metadata, operational_template)
      end
    end
    
    # Save the transformed data
    save_transformed_data(component_id, component_type, transformed_blueprint, transformed_operational)
    
    true
  end
  
  private
  
  def find_old_component_data(id, type)
    # Search in old data directories properly using the container paths
    results = []
    
    # Define search paths based on component type
    old_data_path = GalaxyGame::Paths::JSON_DATA.join('old-json-data')
    
    # Define old data directories to search in
    old_dirs = [
      old_data_path.join('production_old4'),
      old_data_path.join('production_old3'),
      old_data_path
    ]
    
    # Map component type to directory paths
    blueprints_subfolder = "blueprints/#{type}s"
    operational_subfolder = "operational_data/#{type}s"
    
    # Pluralization handling - try both singular and plural forms
    ids_to_check = [id]
    if id.end_with?('s')
      ids_to_check << id.chomp('s') # Remove trailing 's'
    else
      ids_to_check << "#{id}s" # Add trailing 's'
    end
    
    # Search in each possible old directory
    old_dirs.each do |old_dir|
      next unless Dir.exist?(old_dir.to_s)
      
      # Check in blueprints folder
      blueprint_dir = old_dir.join(blueprints_subfolder)
      if Dir.exist?(blueprint_dir.to_s)
        puts "  🔍 Searching in: #{blueprint_dir}"
        Find.find(blueprint_dir.to_s) do |file_path|
          next unless file_path.end_with?('.json')
          
          begin
            content = JSON.parse(File.read(file_path))
            
            # Check against all possible ID variants
            if ids_to_check.include?(content['id'])
              results << { path: file_path, content: content, is_blueprint: true }
            end
          rescue JSON::ParserError
            # Skip invalid JSON files
          end
        end
      end
      
      # Check in operational_data folder
      operational_dir = old_dir.join(operational_subfolder)
      if Dir.exist?(operational_dir.to_s)
        puts "  🔍 Searching in: #{operational_dir}"
        Find.find(operational_dir.to_s) do |file_path|
          next unless file_path.end_with?('.json')
          
          begin
            content = JSON.parse(File.read(file_path))
            
            # Check against all possible ID variants
            if ids_to_check.include?(content['id'])
              results << { path: file_path, content: content, is_blueprint: false }
            end
          rescue JSON::ParserError
            # Skip invalid JSON files
          end
        end
      end
    end
    
    results
  end
  
  def load_template_for(component_type, is_blueprint)
    template_name = if is_blueprint
      case component_type
      when 'unit'
        'unit_blueprint_v1.3.json'
      when 'module'
        'module_blueprint_v1.2.json'
      when 'rig'
        'rig_blueprint_v1.1.json'
      else
        'base_blueprint.json'
      end
    else
      case component_type
      when 'unit'
        'unit_operational_data_v1.2.json'
      when 'module'
        'module_operational_data_v1.1.json'
      when 'rig'
        'rig_operational_data_v1.1.json'
      else
        'base_operational_data.json'
      end
    end
    
    template_path = GalaxyGame::Paths::TEMPLATE_PATH.join(template_name)
    if File.exist?(template_path.to_s)
      JSON.parse(File.read(template_path))
    else
      puts "⚠️ Template not found: #{template_path}"
      {}
    end
  end
  
  def transform_blueprint(blueprint_data, template, component_id, environment)
    content = blueprint_data[:content]
    result = template.dup
    
    # Copy core metadata
    result['id'] = component_id
    result['name'] = content['name'] || humanize(component_id)
    result['description'] = content['description'] || "A #{humanize(component_id).downcase}."
    result['category'] = content['category'] || extract_category(component_id)
    result['subcategory'] = content['subcategory'] || 'general'
    
    # Physical properties
    if content['physical_properties']
      result['physical_properties'] = content['physical_properties'].dup
    end
    
    # Handle materials - the most complex transformation
    if content.dig('blueprint_data', 'materials')
      result['crafting'] ||= {}
      result['crafting']['materials'] = transform_materials(
        content.dig('blueprint_data', 'materials'),
        environment
      )
      
      # Copy other crafting properties if available
      if content.dig('blueprint_data', 'assembly_time')
        result['crafting']['time_minutes'] = content.dig('blueprint_data', 'assembly_time')
      end
    end
    
    # Remove any nil or empty values
    clean_hash(result)
  end
  
  def transform_operational(operational_data, template, component_id)
    content = operational_data[:content]
    result = template.dup
    
    # Copy core metadata
    result['id'] = component_id
    result['name'] = content['name'] || humanize(component_id)
    result['category'] = content['category'] || extract_category(component_id)
    result['subcategory'] = content['subcategory'] || 'general'
    
    # Operational status
    if content['operational_status']
      result['operational_status'] = content['operational_status'].dup
    end
    
    # Component-specific properties
    case extract_category(component_id)
    when 'power'
      # For power components, copy power generation/consumption
      if content['power']
        result['power'] = content['power'].dup
      end
    when 'propulsion'
      # For propulsion components, copy thrust/fuel data
      if content['propulsion']
        result['propulsion'] = content['propulsion'].dup
      end
    when 'electronics'
      # For electronic components
      if content['computing'] || content['sensor']
        result['electronics'] = {}
        result['electronics']['computing'] = content['computing'] if content['computing']
        result['electronics']['sensor'] = content['sensor'] if content['sensor']
      end
    end
    
    # Remove any nil or empty values
    clean_hash(result)
  end
  
  def transform_materials(materials, environment)
    transformed = []
    
    materials.each do |material|
      material_id = material['id']
      
      # Check if this is a harvestable material
      if HARVESTABLE_MATERIALS.include?(material_id)
        # Use as-is
        transformed << {
          'id' => material_id,
          'amount' => material['amount'],
          'unit' => material['unit'] || 'unit'
        }
      elsif MATERIAL_SUBSTITUTIONS.key?(material_id)
        # Substitute with appropriate material for the environment
        substitute = MATERIAL_SUBSTITUTIONS[material_id][environment] || 
                     MATERIAL_SUBSTITUTIONS[material_id]['default']
        
        transformed << {
          'id' => substitute,
          'amount' => material['amount'],
          'unit' => material['unit'] || 'unit'
        }
      else
        # For unknown materials, use a generic substitute
        transformed << {
          'id' => 'generic_material',
          'amount' => material['amount'],
          'unit' => material['unit'] || 'unit'
        }
        puts "⚠️ Using generic_material for unknown material: #{material_id}"
      end
    end
    
    transformed
  end
  
  def extract_metadata(data)
    content = data[:content]
    {
      id: content['id'],
      name: content['name'] || humanize(content['id']),
      category: content['category'] || extract_category(content['id']),
      subcategory: content['subcategory'] || 'general',
      description: content['description'] || "A #{humanize(content['id']).downcase}."
    }
  end
  
  def generate_blueprint(metadata, template)
    # Use your existing GameDataGenerator to fill in missing blueprint
    result = template.dup
    
    # Apply known metadata
    result['id'] = metadata[:id]
    result['name'] = metadata[:name]
    result['category'] = metadata[:category]
    result['subcategory'] = metadata[:subcategory]
    result['description'] = metadata[:description]
    
    # Generate sensible default materials based on component type
    result['crafting'] = {
      'materials' => generate_default_materials(metadata[:category], metadata[:subcategory]),
      'time_minutes' => 30
    }
    
    # Use AI to enhance/complete the blueprint
    enhanced = enhance_with_ai(result, 'blueprint', metadata)
    
    enhanced || result
  end
  
  def generate_operational(metadata, template)
    # Use your existing GameDataGenerator to fill in missing operational data
    result = template.dup
    
    # Apply known metadata
    result['id'] = metadata[:id]
    result['name'] = metadata[:name]
    result['category'] = metadata[:category]
    result['subcategory'] = metadata[:subcategory]
    
    # Generate basic operational status
    result['operational_status'] = {
      'status' => 'offline',
      'condition' => 100,
      'degradation_rate' => 0.01
    }
    
    # Generate category-specific properties
    case metadata[:category]
    when 'power'
      result['power'] = {
        'generation_kw' => metadata[:id].include?('panel') ? 50.0 : 0.0,
        'consumption_kw' => metadata[:id].include?('panel') ? 0.0 : 5.0,
        'efficiency' => 0.85
      }
    when 'propulsion'
      result['propulsion'] = {
        'thrust_kn' => 10.0,
        'specific_impulse': 280.0,
        'fuel_consumption_rate': 0.5
      }
    when 'electronics'
      result['electronics'] = {
        'power_consumption_kw' => 2.0,
        'heat_generation_kw' => 1.0
      }
    end
    
    # Use AI to enhance/complete the operational data
    enhanced = enhance_with_ai(result, 'operational', metadata)
    
    enhanced || result
  end
  
  def enhance_with_ai(data, data_type, metadata)
    return data if @generator.nil?
    
    begin
      puts "🤖 Using AI to enhance #{data_type} data for #{metadata[:id]}..."
      
      # Use your GameDataGenerator to improve the data
      template_path = GalaxyGame::Paths::TEMPLATE_PATH.join(
        data_type == 'blueprint' ? 'unit_blueprint_v1.3.json' : 'unit_operational_data_v1.2.json'
      ).to_s
      
      temp_output_path = GalaxyGame::Paths::JSON_DATA.join('temp', "#{metadata[:id]}_#{data_type}_enhanced.json").to_s
      
      # Ensure temp directory exists
      FileUtils.mkdir_p(File.dirname(temp_output_path))
      
      result = @generator.generate_item(template_path, temp_output_path, data)
      
      # Clean up temp file
      FileUtils.rm(temp_output_path) if File.exist?(temp_output_path)
      
      result
    rescue => e
      puts "⚠️ AI enhancement failed: #{e.message}"
      nil
    end
  end
  
  def generate_default_materials(category, subcategory)
    case category
    when 'power'
      [
        { 'id' => 'metal_plate', 'amount' => 5, 'unit' => 'unit' },
        { 'id' => 'wire', 'amount' => 10, 'unit' => 'unit' },
        { 'id' => 'circuit_board', 'amount' => 2, 'unit' => 'unit' }
      ]
    when 'propulsion'
      [
        { 'id' => 'metal_plate', 'amount' => 8, 'unit' => 'unit' },
        { 'id' => 'titanium_ore', 'amount' => 3, 'unit' => 'unit' }
      ]
    when 'electronics'
      [
        { 'id' => 'circuit_board', 'amount' => 5, 'unit' => 'unit' },
        { 'id' => 'wire', 'amount' => 8, 'unit' => 'unit' },
        { 'id' => 'plastic', 'amount' => 2, 'unit' => 'unit' }
      ]
    else
      [
        { 'id' => 'metal_plate', 'amount' => 3, 'unit' => 'unit' },
        { 'id' => 'plastic', 'amount' => 2, 'unit' => 'unit' }
      ]
    end
  end
  
  def save_transformed_data(component_id, component_type, blueprint, operational)
    # Get the category from the transformed data
    category = blueprint['category'] || operational['category'] || 'general'
    
    # Use GalaxyGame::Paths for proper path determination
    # Blueprint path
    blueprint_path = if component_type == 'unit'
      GalaxyGame::Paths::UNIT_BLUEPRINTS_PATH.join(category, "#{component_id}_bp.json").to_s
    elsif component_type == 'module'
      GalaxyGame::Paths::MODULE_BLUEPRINTS_PATH.join(category, "#{component_id}_bp.json").to_s
    elsif component_type == 'rig'
      GalaxyGame::Paths::RIG_BLUEPRINTS_PATH.join(category, "#{component_id}_bp.json").to_s
    end
    
    # Operational data path - use the appropriate constant based on type and category
    operational_path = if component_type == 'unit'
      case category
      when 'power'
        GalaxyGame::Paths::ENERGY_UNITS_PATH.join("#{component_id}.json").to_s
      when 'propulsion'
        GalaxyGame::Paths::PROPULSION_UNITS_PATH.join("#{component_id}.json").to_s
      when 'electronics'
        GalaxyGame::Paths::COMPUTER_UNITS_PATH.join("#{component_id}.json").to_s
      when 'storage'
        GalaxyGame::Paths::STORAGE_UNITS_PATH.join("#{component_id}.json").to_s
      when 'life_support'
        GalaxyGame::Paths::LIFE_SUPPORT_UNITS_PATH.join("#{component_id}.json").to_s
      else
        GalaxyGame::Paths::UNITS_PATH.join(category, "#{component_id}.json").to_s
      end
    elsif component_type == 'module'
      case category
      when 'power'
        GalaxyGame::Paths::POWER_MODULES_PATH.join("#{component_id}.json").to_s
      when 'computer'
        GalaxyGame::Paths::COMPUTER_MODULES_PATH.join("#{component_id}.json").to_s
      when 'sensors'
        GalaxyGame::Paths::SENSORS_MODULES_PATH.join("#{component_id}.json").to_s
      else
        GalaxyGame::Paths::MODULES_PATH.join(category, "#{component_id}.json").to_s
      end
    elsif component_type == 'rig'
      case category
      when 'power'
        GalaxyGame::Paths::POWER_RIGS_PATH.join("#{component_id}.json").to_s
      when 'computer'
        GalaxyGame::Paths::COMPUTER_RIGS_PATH.join("#{component_id}.json").to_s
      else
        GalaxyGame::Paths::RIGS_PATH.join(category, "#{component_id}.json").to_s
      end
    end
    
    # Create directories if needed
    FileUtils.mkdir_p(File.dirname(blueprint_path)) if blueprint_path
    FileUtils.mkdir_p(File.dirname(operational_path)) if operational_path
    
    # Save blueprint
    if blueprint && blueprint_path
      File.write(blueprint_path, JSON.pretty_generate(blueprint))
      puts "✅ Saved blueprint to: #{blueprint_path}"
    end
    
    # Save operational data
    if operational && operational_path
      File.write(operational_path, JSON.pretty_generate(operational))
      puts "✅ Saved operational data to: #{operational_path}"
    end
  end
  
  def extract_category(component_id)
    case component_id
    when /panel|power|battery|generator|solar/
      'power'
    when /thruster|engine|propulsion|fuel|tank/
      'propulsion'
    when /sensor|computer|controller|communication/
      'electronics'
    when /shield|armor/
      'defense'
    when /cargo|storage/
      'storage'
    else
      'general'
    end
  end
  
  def humanize(string)
    string.to_s.gsub('_', ' ').gsub(/\b\w/) { $&.upcase }
  end
  
  def clean_hash(hash)
    hash.each do |k, v|
      if v.is_a?(Hash)
        clean_hash(v)
        hash.delete(k) if v.empty?
      elsif v.is_a?(Array)
        v.each { |item| clean_hash(item) if item.is_a?(Hash) }
        hash.delete(k) if v.empty?
      elsif v.nil?
        hash.delete(k)
      end
    end
    hash
  end
end

# Main execution
if __FILE__ == $0
  component_id = ARGV[0]
  component_type = ARGV[1] || 'unit'
  environment = ARGV[2] || 'default'
  
  if component_id.nil?
    puts "Usage: bin/rails r tools/transform_component.rb COMPONENT_ID [COMPONENT_TYPE] [ENVIRONMENT]"
    puts "  COMPONENT_ID: ID of the component to transform (e.g., 'solar_panel')"
    puts "  COMPONENT_TYPE: Type of component ('unit', 'module', or 'rig'). Default: 'unit'"
    puts "  ENVIRONMENT: Environment context ('default', 'lunar', 'mars'). Default: 'default'"
    exit 1
  end
  
  transformer = ComponentTransformer.new
  result = transformer.transform(component_id, component_type, environment)
  
  if result
    puts "\n✅ Successfully transformed component: #{component_id}"
  else
    puts "\n❌ Failed to transform component: #{component_id}"
  end
end