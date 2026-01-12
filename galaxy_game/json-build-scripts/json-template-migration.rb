require 'fileutils'
require 'json'

# Paths - CORRECTED
OLD_TEMPLATE_PATH = "/home/galaxy_game/app/data/old-json-data/production_old4/templates"
NEW_TEMPLATE_PATH = "/home/galaxy_game/app/data/templates"

# Ensure the new template directory exists
FileUtils.mkdir_p(NEW_TEMPLATE_PATH) unless Dir.exist?(NEW_TEMPLATE_PATH)

# Template mapping - old filename to new filename
TEMPLATE_MAPPING = {
  # Base templates
  "base_blueprint.json" => "base_blueprint.json",
  "base_material.json" => "base_resource.json",
  "base_unit.json" => "base_unit.json",
  "base_module.json" => "base_module.json",
  
  # Specialized blueprint templates
  "base_facility_blueprint.json" => "structure_blueprint.json",
  "base_module_blueprint.json" => "module_blueprint.json",
  "base_fuel_production_blueprint.json" => "unit_blueprint.json",
  
  # Operational data templates
  "base_facility_operational_data.json" => "structure_operational_data.json",
  
  # Game object templates
  "base_craft.json" => "craft_blueprint.json",
  "base_celestial_body.json" => "celestial_body.json",
  "base_facility_unit.json" => "unit_operational_data.json",
  "base_mission_manifest.json" => "mission_manifest.json",
  "base_technology_category.json" => "technology_category.json"
}

# New templates to create
NEW_TEMPLATES = [
  "rig_blueprint.json",
  "component_blueprint.json",
  "material.json",
  "fuel.json",
  "chemical.json",
  "base_operational_data.json",
  "craft_operational_data.json",
  "module_operational_data.json",
  "rig_operational_data.json",
  "base_item.json",
  "component_item.json",
  "consumable_item.json",
  "container_item.json",
  "equipment_item.json",
  "tool_item.json",
  "furniture_item.json"
]

# Migrate existing templates
def migrate_existing_templates
  puts "Migrating existing templates..."
  TEMPLATE_MAPPING.each do |old_file, new_file|
    old_path = File.join(OLD_TEMPLATE_PATH, old_file)
    new_path = File.join(NEW_TEMPLATE_PATH, new_file)
    
    if File.exist?(old_path)
      begin
        # Read the old template
        json_content = File.read(old_path)
        template_data = JSON.parse(json_content)
        
        # Add template type field if it doesn't exist
        template_data["template"] = new_file.sub(".json", "") unless template_data.has_key?("template")
        
        # Write to new location
        File.write(new_path, JSON.pretty_generate(template_data))
        puts "  ✓ Migrated: #{old_file} -> #{new_file}"
      rescue => e
        puts "  ✗ Error migrating #{old_file}: #{e.message}"
      end
    else
      puts "  ! Missing source file: #{old_file}"
    end
  end
end

# Create new template files
def create_new_templates
  puts "\nCreating new templates..."
  
  NEW_TEMPLATES.each do |template_name|
    template_path = File.join(NEW_TEMPLATE_PATH, template_name)
    
    # Skip if already exists
    if File.exist?(template_path)
      puts "  ! Template already exists: #{template_name}"
      next
    end
    
    # Base template structure
    template_data = {
      "template" => template_name.sub(".json", ""),
      "id" => "",
      "name" => "",
      "description" => "",
      "category" => "",
      "subcategory" => ""
    }
    
    # Add specific fields based on template type
    case template_name
    when /blueprint/
      template_data["blueprint_data"] = {
        "material_requirements" => [],
        "construction_time_hours" => 0,
        "required_tools" => [],
        "required_skills" => [],
        "required_technology" => []
      }
    when /operational_data/
      template_data["operational_properties"] = {
        "power_consumption_kw" => 0,
        "maintenance_interval_hours" => 0,
        "efficiency" => 1.0
      }
    when /item/
      template_data["physical_properties"] = {
        "mass_kg" => 0,
        "volume_m3" => 0
      }
      template_data["game_properties"] = {
        "value" => 0,
        "rarity" => "common",
        "stackable" => true,
        "max_stack" => 100
      }
    end
    
    # Write the new template
    begin
      File.write(template_path, JSON.pretty_generate(template_data))
      puts "  ✓ Created: #{template_name}"
    rescue => e
      puts "  ✗ Error creating #{template_name}: #{e.message}"
    end
  end
end

# Run the migration
puts "=== Template Migration ==="
migrate_existing_templates
create_new_templates
puts "\nMigration complete! #{TEMPLATE_MAPPING.size} templates migrated, #{NEW_TEMPLATES.size} new templates created."
puts "Template directory: #{NEW_TEMPLATE_PATH}"