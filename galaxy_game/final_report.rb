
require 'json'
require_relative 'config/initializers/game_data_paths'

# Get all materials with their cost data
materials = {}
Dir.glob(GalaxyGame::Paths::MATERIALS_PATH.join('**', '*.json')) do |f|
  begin
    data = JSON.parse(File.read(f))
    id = data['id']
    if data['cost_data']
      eap = data['cost_data']['purchase_cost']['amount']
      hazard = data['cost_data']['import_config']['hazard_multiplier']
      materials[id] = { eap: eap, hazard: hazard }
    end
  rescue
    # skip
  end
end

# Get blueprint linkages
blueprint_links = {}
Dir.glob(GalaxyGame::Paths::BLUEPRINTS_PATH.join('units', '**', '*.json')) do |f|
  begin
    data = JSON.parse(File.read(f))
    blueprint_id = data['id'] || File.basename(f, '.json')
    if data['required_materials'].is_a?(Hash)
      data['required_materials'].keys.each do |material_id|
        blueprint_links[material_id] ||= []
        blueprint_links[material_id] << blueprint_id
      end
    end
  rescue
    # skip
  end
end

# Generate report
puts 'Material ID | EAP (USD/kg) | Hazard Multiplier | Linked Blueprints'
puts '-' * 80

materials.sort.each do |id, data|
  linked = blueprint_links[id]&.uniq&.join(', ') || 'None'
  puts #{id}
