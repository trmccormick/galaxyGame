require 'json'

# Load circuit boards data
material_file = '/home/galaxy_game/data/json-data/resources/materials/processed/components/circuit_boards.json'
material_data = JSON.parse(File.read(material_file))

puts '=== Circuit Boards Material Data ==='
puts "Unit of measurement: #{material_data.dig('properties', 'unit_of_measurement')}"
puts "Earth price per unit: 0\{material_data.dig('pricing', 'earth_usd', 'base_price_per_unit')\}"
puts "Mass per unit kg: #{material_data.dig('cost_data', 'import_config', 'mass_per_unit_kg')} kg"
puts "Transport category: #{material_data.dig('pricing', 'earth_usd', 'transport_category')}"
puts "Lunar production cost per unit: 0\{material_data.dig('pricing', 'lunar_production', 'cost_per_unit')\}"

# Simulate transport cost calculation (simplified)
transport_cost_per_kg = 50.0  # Simplified assumption
mass_per_unit = material_data.dig('cost_data', 'import_config', 'mass_per_unit_kg') || 1.0
earth_price = material_data.dig('pricing', 'earth_usd', 'base_price_per_unit')

transport_cost = transport_cost_per_kg * mass_per_unit
total_import_cost = earth_price + transport_cost

puts "\n=== Pricing Calculations ==="
puts "Transport cost per kg: 0\{transport_cost_per_kg\}"
puts "Transport cost for 1 unit (#\{mass_per_unit\}kg): 0\{transport_cost\}"
puts "Total Earth import cost per unit: 0\{total_import_cost\}"

local_cost = material_data.dig('pricing', 'lunar_production', 'cost_per_unit')
if local_cost
  puts "Local lunar production cost per unit: 0\{local_cost\}"
  puts "Local production advantage: 0\{(total_import_cost - local_cost).round(2)\} savings per unit"
end

puts "\n=== Validation ==="
if material_data.dig('properties', 'unit_of_measurement') == 'unit'
  puts "✓ Correctly identified as unit-based material"
else
  puts "✗ Should be unit-based material"
end

if material_data.dig('pricing', 'earth_usd', 'base_price_per_unit')
  puts "✓ Has Earth pricing per unit"
else
  puts "✗ Missing Earth pricing per unit"
end

if material_data.dig('cost_data', 'import_config', 'mass_per_unit_kg')
  puts "✓ Has mass per unit for transport calculations"
else
  puts "✗ Missing mass per unit for transport calculations"
end
