# Migration implementation script
class StructureUnitMigration
  def self.run
    # Configure paths
    source_path = File.join(Rails.root.to_s, 'app', 'data', 'units', 'structure')
    target_blueprint_path = File.join(Rails.root.to_s, 'app', 'data', 'blueprints', 'structures')
    target_operational_path = File.join(Rails.root.to_s, 'app', 'data', 'operational_data', 'structures')
    
    # Ensure target directories exist
    FileUtils.mkdir_p(target_blueprint_path)
    FileUtils.mkdir_p(target_operational_path)
    
    # Process each structure unit file
    Dir.glob(File.join(source_path, "*_data.json")).each do |file_path|
      begin
        # Load source data
        data = JSON.parse(File.read(file_path))
        id = data['id']
        
        # Skip if this shouldn't be a structure
        next unless should_be_structure?(data)
        
        # Create blueprint data
        blueprint_data = {
          "template" => "structure_blueprint",
          "id" => "#{id}_bp",
          "name" => "#{data['name']} Blueprint",
          "description" => "Construction plans for #{data['name']}",
          "category" => "structure",
          "subcategory" => determine_subcategory(data),
          "physical_properties" => {
            "footprint_m" => data['footprint_m'] || {"x" => 10, "y" => 10},
            "height_m" => data['height_m'] || 5,
            "mass_kg" => data['mass_kg'] || 10000
          },
          "operational_properties" => {
            "power_consumption_kw" => data['power_consumption_kw'] || 100,
            "crew_capacity" => data['crew_capacity'] || 0,
            "maintenance_interval_hours" => data['maintenance_interval_hours'] || 168
          },
          "unit_slots" => data['unit_slots'] || [],
          "module_slots" => data['module_slots'] || [],
          "compatible_units" => data['compatible_units'] || [],
          "compatible_modules" => data['compatible_modules'] || [],
          "recommended_units" => data['recommended_units'] || [],
          "recommended_modules" => data['recommended_modules'] || [],
          "blueprint_data" => {
            "material_requirements" => data['material_requirements'] || [],
            "construction_time_hours" => data['construction_time_hours'] || 24,
            "required_tools" => data['required_tools'] || [],
            "required_skills" => data['required_skills'] || [],
            "required_technology" => data['required_technology'] || []
          }
        }
        
        # Create operational data
        operational_data = {
          "template" => "structure_operational_data",
          "id" => id,
          "name" => data['name'],
          "description" => data['description'],
          "category" => "structure",
          "subcategory" => determine_subcategory(data),
          "systems" => data['systems'] || default_systems,
          "operational_modes" => data['operational_modes'] || default_operational_modes,
          "resource_management" => data['resource_management'] || {
            "consumables" => {},
            "generated" => {}
          },
          "unit_slots" => data['unit_slots'] || [],
          "module_slots" => data['module_slots'] || []
        }
        
        # Write files
        blueprint_file = File.join(target_blueprint_path, "#{id}_bp.json")
        operational_file = File.join(target_operational_path, "#{id}_data.json")
        
        File.write(blueprint_file, JSON.pretty_generate(blueprint_data))
        File.write(operational_file, JSON.pretty_generate(operational_data))
        
        puts "Migrated: #{id} to structures"
      rescue => e
        puts "Error processing #{file_path}: #{e.message}"
      end
    end
  end
  
  def self.should_be_structure?(data)
    data['footprint_m'].present? || 
    data['construction_time_hours'].present? || 
    data.dig('blueprint_data', 'material_requirements').present? ||
    data['structure_type'] == true
  end
  
  def self.determine_subcategory(data)
    return data['subcategory'] if data['subcategory'].present?
    
    # Try to determine based on keywords in name/description
    name = data['name'].to_s.downcase
    desc = data['description'].to_s.downcase
    
    if name.include?('habitat') || name.include?('living') || desc.include?('living quarters')
      'habitation'
    elsif name.include?('power') || name.include?('generator') || desc.include?('generates power')
      'power_generation'
    elsif name.include?('lab') || name.include?('research') || desc.include?('scientific')
      'science_research'
    elsif name.include?('storage') || name.include?('warehouse') || desc.include?('stores')
      'storage'
    elsif name.include?('mining') || name.include?('extractor') || desc.include?('extraction')
      'resource_extraction'
    elsif name.include?('refinery') || name.include?('processing')
      'resource_processing'
    else
      'manufacturing' # Default
    end
  end
  
  def self.default_systems
    {
      "power_distribution" => {
        "status" => "not_installed",
        "efficiency_percent" => 100
      },
      "life_support" => {
        "status" => "not_installed",
        "efficiency_percent" => 100
      },
      "control_systems" => {
        "status" => "not_installed",
        "efficiency_percent" => 100
      }
    }
  end
  
  def self.default_operational_modes
    {
      "current_mode" => "standby",
      "available_modes" => [
        {"name" => "standby", "energy_usage_multiplier" => 0.2},
        {"name" => "operational", "energy_usage_multiplier" => 1.0},
        {"name" => "maintenance", "energy_usage_multiplier" => 0.5}
      ]
    }
  end
end

# Run the migration
StructureUnitMigration.run