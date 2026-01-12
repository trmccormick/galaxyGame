require 'json'
require 'fileutils'
require 'rails'
require File.expand_path('../../config/environment', __FILE__)


require_relative '../../config/initializers/game_data_paths'
# Use GalaxyGame::Paths for consistent path handling
OLD_DATA_ROOT = GalaxyGame::Paths::JSON_DATA.join('old-json-data', 'production_old3').to_s

# Define absolute paths for template files
TEMPLATES_PATH = GalaxyGame::Paths::TEMPLATE_PATH.to_s

# Load templates - use consistent path handling
STRUCTURE_TEMPLATE = JSON.parse(File.read(File.join(TEMPLATES_PATH, 'structure_blueprint.json')))
UNIT_TEMPLATE = JSON.parse(File.read(File.join(TEMPLATES_PATH, 'unit_blueprint.json')))
MODULE_TEMPLATE = JSON.parse(File.read(File.join(TEMPLATES_PATH, 'module_blueprint.json')))

# Define classifications
STRUCTURE_FILES = [
  'large_hab_dome.json',
  'large_docking_bay.json',
  'small_landing_pad.json',
  'advanced_assembly_line.json',
  'basic_fabricator.json',
  'large_solar_farm.json',
  'regolith_refinery_basic.json',
  'metal_smelter_mk1.json',
  'water_ice_processor.json',
  'advanced_research_center.json',
  'basic_research_lab.json',
  'raw_materials_silo.json',
  'internal_transport_hub.json'
]

MODULE_FILES = [
  'basic_hab_module.json',
  'crew_quarters_module.json'
]

UNIT_FILES = [
  'atmosphere_control_unit_mk1.json',
  'food_production_unit_hydroponics.json',
  'water_recycling_unit_basic.json',
  'rtg_unit.json',
  'compact_solar_array_fitting.json',
  'basic_regolith_harvester.json',
  'ice_drill_unit.json',
  'large_pressurized_tank.json',
  'small_storage_container.json',
  'automated_rover_dock.json'
]

def generate_structure_blueprint(file_path, category)
  filename = File.basename(file_path, '.json')
  id = filename
  name = filename.split('_').map(&:capitalize).join(' ')
  
  data = STRUCTURE_TEMPLATE.dup
  data['id'] = "#{id}_bp"
  data['name'] = "#{name} Blueprint"
  data['description'] = "Construction plans for a #{name}"
  data['category'] = 'structure'
  data['subcategory'] = category
  
  # Add more structure-specific details here...
  
  # Ensure target directory exists - using GalaxyGame::Paths
  target_dir = File.join(Rails.root.to_s, GalaxyGame::Paths::STRUCTURE_BLUEPRINTS_PATH, category)
  FileUtils.mkdir_p(target_dir)
  
  # Write blueprint file
  target_file = File.join(target_dir, "#{id}_bp.json")
  File.write(target_file, JSON.pretty_generate(data))
  
  # Also generate operational data
  generate_structure_operational_data(id, name, category)
  
  puts "Generated structure blueprint: #{target_file}"
end

def generate_structure_operational_data(id, name, category)
  data = {
    'template' => 'structure_operational_data',
    'id' => id,
    'name' => name,
    'description' => "Operational data for #{name}",
    'category' => 'structure',
    'subcategory' => category,
    'status' => 'planned',
    'systems' => {
      'power' => { 'status' => 'not_installed' },
      'life_support' => { 'status' => 'not_installed' },
      'computing' => { 'status' => 'not_installed' }
    },
    'operational_modes' => {
      'current' => 'standby',
      'available' => ['standby', 'active', 'maintenance']
    }
  }
  
  # Ensure target directory exists - using GalaxyGame::Paths
  category_structures_path = File.join(GalaxyGame::Paths::STRUCTURES_PATH, category)
  target_dir = File.join(Rails.root.to_s, category_structures_path)
  FileUtils.mkdir_p(target_dir)
  
  # Write operational data file
  target_file = File.join(target_dir, "#{id}_data.json")
  File.write(target_file, JSON.pretty_generate(data))
  
  puts "Generated structure operational data: #{target_file}"
end

def generate_unit_blueprint(file_path, category)
  filename = File.basename(file_path, '.json')
  id = filename
  name = filename.split('_').map(&:capitalize).join(' ')
  
  data = UNIT_TEMPLATE.dup
  data['id'] = "#{id}_bp"
  data['name'] = "#{name} Blueprint"
  data['description'] = "Construction plans for a #{name}"
  data['category'] = 'unit'
  data['subcategory'] = category
  
  # Add more unit-specific details here...
  
  # Ensure target directory exists - using GalaxyGame::Paths
  target_dir = File.join(Rails.root.to_s, GalaxyGame::Paths::UNIT_BLUEPRINTS_PATH, category)
  FileUtils.mkdir_p(target_dir)
  
  # Write blueprint file
  target_file = File.join(target_dir, "#{id}_bp.json")
  File.write(target_file, JSON.pretty_generate(data))
  
  puts "Generated unit blueprint: #{target_file}"
end

def generate_module_blueprint(file_path, category)
  filename = File.basename(file_path, '.json')
  id = filename
  name = filename.split('_').map(&:capitalize).join(' ')
  
  data = MODULE_TEMPLATE.dup
  data['id'] = "#{id}_bp"
  data['name'] = "#{name} Blueprint"
  data['description'] = "Construction plans for a #{name}"
  data['category'] = 'module'
  data['subcategory'] = category
  
  # Add more module-specific details here...
  
  # Ensure target directory exists - using GalaxyGame::Paths
  target_dir = File.join(Rails.root.to_s, GalaxyGame::Paths::MODULE_BLUEPRINTS_PATH, category)
  FileUtils.mkdir_p(target_dir)
  
  # Write blueprint file
  target_file = File.join(target_dir, "#{id}_bp.json")
  File.write(target_file, JSON.pretty_generate(data))
  
  puts "Generated module blueprint: #{target_file}"
end

# Process all files in the old structure directory
Dir.glob(File.join(OLD_DATA_ROOT, 'blueprints', 'structures', '**', '*.json')).each do |file_path|
  filename = File.basename(file_path)
  category = File.basename(File.dirname(file_path))
  
  if STRUCTURE_FILES.include?(filename)
    generate_structure_blueprint(file_path, category)
  elsif MODULE_FILES.include?(filename)
    generate_module_blueprint(file_path, category)
  elsif UNIT_FILES.include?(filename)
    generate_unit_blueprint(file_path, category)
  else
    puts "Unknown file type: #{file_path}"
  end
end

puts "\nGeneration complete!"