
require 'json'
require 'fileutils'
require_relative 'config/initializers/game_data_paths'

# Create one test material
id = 'actuators'
category = 'processed'
eap = { amount: 5.0, hazard: 1.0, category: 'standard' }

material_data = {
  'template' => 'material_v1.6',
  'category' => category,
  'id' => id,
  'name' => id.split('_').map(&:capitalize).join(' '),
  'description' => 'Auto-generated material for actuators',
  'density' => nil,
  'boiling_point' => nil,
  'melting_point' => nil,
  'state_at_stp' => 'solid',
  'appearance' => nil,
  'color' => nil,
  'odor' => nil,
  'taste' => nil,
  'toxicity' => nil,
  'flammability' => nil,
  'reactivity' => nil,
  'storage' => {
    'pressure' => 'standard',
    'temperature' => 'standard',
    'stability' => 'stable',
    'incompatible_with' => []
  },
  'handling' => {
    'ppe_required' => [],
    'hazard_class' => [],
    'disposal' => 'standard'
  },
  'properties' => {
    'transparent' => false,
    'oxidizer' => false,
    'radioactive' => false,
    'chemical_formula' => nil,
    'molar_mass' => nil
  },
  'metadata' => {
    'version' => '1.6',
    'last_updated' => '2026-01-02',
    'is_procedural' => true,
    'standard' => 'Earth STP (273.15K, 101.325 kPa)',
    'aliases' => []
  },
  'cost_data' => {
    'purchase_cost' => {
      'currency' => 'USD',
      'amount' => eap[:amount]
    },
    'import_config' => {
      'mass_per_unit_kg' => 1.0,
      'transport_category' => eap[:category],
      'hazard_multiplier' => eap[:hazard]
    }
  }
}

dir = GalaxyGame::Paths::MATERIALS_PATH.join('processed', 'auto_generated')
FileUtils.mkdir_p(dir)
file_path = File.join(dir, "#{id}.json")
json_content = JSON.pretty_generate(material_data)
File.write(file_path, json_content)
puts "Created #{file_path}"
