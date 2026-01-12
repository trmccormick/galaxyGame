require 'json'

# Known EAP values
eap_values = {
  'methane' => { amount: 1.85, hazard: 1.5, category: 'hazardous' },
  'oxygen' => { amount: 0.20, hazard: 1.3, category: 'hazardous' },
  'superalloy' => { amount: 4.50, hazard: 1.0, category: 'standard' },
  'high_purity_silicon' => { amount: 25.00, hazard: 1.1, category: 'standard' },
  'regolith' => { amount: 0.00, hazard: 1.0, category: 'standard' }
}

# Estimate for others
def estimate_eap(material_id, data)
  category = data.dig('classification', 'category') || 'processed'
  case category
  when 'raw'
    { amount: 0.1, hazard: 1.0, category: 'standard' }
  when 'processed'
    case material_id
    when /alloy/
      { amount: 5.0, hazard: 1.0, category: 'standard' }
    when /silicon|electronic/
      { amount: 20.0, hazard: 1.1, category: 'standard' }
    when /polymer|plastic/
      { amount: 3.0, hazard: 1.0, category: 'standard' }
    when /chemical/
      { amount: 10.0, hazard: 1.2, category: 'hazardous' }
    else
      { amount: 2.0, hazard: 1.0, category: 'standard' }
    end
  when 'gases'
    { amount: 1.0, hazard: 1.4, category: 'hazardous' }
  when 'liquids'
    { amount: 2.0, hazard: 1.3, category: 'hazardous' }
  else
    { amount: 1.0, hazard: 1.0, category: 'standard' }
  end
end

require_relative 'config/initializers/game_data_paths'
Dir.glob(GalaxyGame::Paths::MATERIALS_PATH.join('**', '*.json')).each do |file|
  begin
    data = JSON.parse(File.read(file))
    id = data['id']
    
    # Update template
    data['template'] = 'material_v1.6'
    data['metadata'] ||= {}
    data['metadata']['version'] = '1.6'
    data['metadata']['last_updated'] = '2026-01-02'
    data['metadata']['is_procedural'] = false
    data['metadata']['standard'] = 'Earth STP (273.15K, 101.325 kPa)'
    data['metadata']['aliases'] ||= []
    
    # Add cost_data
    eap = eap_values[id] || estimate_eap(id, data)
    data['cost_data'] = {
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
    
    # Remove old pricing if exists
    data.delete('pricing') if data['pricing']
    
    File.write(file, JSON.pretty_generate(data))
  rescue => e
    puts "Error processing #{file}: #{e.message}"

  end
end

puts 'Migration complete'

