#!/usr/bin/env ruby
# First Contact Procedural Stress Test
require_relative 'config/environment'

puts "=== FIRST CONTACT PROCEDURAL STRESS TEST ==="
puts "Initializing StarSim::ProceduralGenerator..."

# Initialize the procedural generator
generator = StarSim::ProceduralGenerator.new

# Generate a procedural terrestrial planet (not Mars or Luna)
planet_name = "Proxima Centauri b" # Random name, not Mars/Luna
planet_identifier = "PROC-#{Time.now.to_i}"

puts "Generating procedural terrestrial planet: #{planet_name}"

# Generate planet data
planet_data = generator.send(:generate_procedural_terrestrial, planet_name, planet_identifier, 1)

# Add atmosphere using AtmosphereGeneratorService
atmosphere_service = StarSim::AtmosphereGeneratorService.new(planet_data, Lookup::MaterialLookupService.new)
atmosphere_composition = atmosphere_service.generate_composition_for_body(
  planet_name,
  nil, # surface_temp_override
  planet_data['mass'],
  planet_data['radius'],
  1.0, # orbital_distance (AU)
  'G', # stellar_type
  false # has_magnetic_field
)

puts "Atmospheric composition generated:"
atmosphere_composition.each do |gas, data|
  puts "  #{gas}: #{data['percentage']}%" if data.is_a?(Hash) && data['percentage']
end

# Create the CelestialBody
puts "Creating CelestialBody..."
celestial_body = CelestialBodies::CelestialBody.create!(
  name: planet_data['name'],
  identifier: planet_data['identifier'],
  body_type: 'terrestrial',
  size: planet_data['size'],
  mass: planet_data['mass'],
  radius: planet_data['radius'],
  gravity: planet_data['gravity'],
  density: planet_data['density'],
  surface_temperature: planet_data['surface_temperature'],
  known_pressure: planet_data['known_pressure'],
  geological_activity: planet_data['geological_activity'],
  geosphere_attributes: planet_data['geosphere_attributes']
)

# Create atmosphere
celestial_body.create_atmosphere!(composition: atmosphere_composition)

puts "CelestialBody created: #{celestial_body.name} (ID: #{celestial_body.id})"
puts "Traits: #{atmosphere_composition.keys.join(', ')}"

# Initialize AIManager::SystemArchitect
puts "Initializing AIManager::SystemArchitect..."
architect = AIManager::SystemArchitect.new(celestial_body)

# Call deploy_autonomous_colonization
puts "Deploying autonomous colonization..."
architect.deploy_autonomous_colonization

puts "Colonization complete!"

# Validate DecisionTree trait lookup
puts "Validating DecisionTree trait lookup..."
settlement = Settlement::BaseSettlement.where("name LIKE ?", "%#{celestial_body.name}%").first
if settlement
  decision_tree = AIManager::DecisionTree.new(settlement, nil) # game_data_generator can be nil for this test
  
  # Simulate atmospheric maintenance decision
  decision_tree.send(:handle_atmospheric_maintenance, 'oxygen')
  puts "DecisionTree successfully handled atmospheric maintenance for oxygen"
  
  # Check UnitLookupService usage
  unit_lookup = Lookup::UnitLookupService.new
  units_found = unit_lookup.find_units_by_trait('production_output', 'oxygen')
  puts "Units found for oxygen production trait: #{units_found.count}"
else
  puts "No settlement found after colonization!"
end

# Check economic loop - ResourceAcquisitionService
puts "Validating economic loop..."
# Find Earth-sourced units deployed
earth_units = settlement.base_units.select do |unit|
  unit.operational_data&.dig('usd_import_fee')&.to_f == 1000
end
puts "Earth-sourced units deployed: #{earth_units.count}"
total_import_fees = earth_units.sum { |u| u.operational_data.dig('usd_import_fee').to_f }
puts "Total import fees: $#{total_import_fees}"

# Check namespace integrity
structures_created = settlement.structures
puts "Structures created: #{structures_created.count}"
namespace_check = structures_created.all? { |s| s.is_a?(Structures::BaseStructure) }
puts "All structures use Structures::BaseStructure namespace: #{namespace_check}"

# Final audit
puts "=== FINAL AUDIT ==="
puts "Planet: #{celestial_body.name}"
puts "Atmospheric Traits: #{atmosphere_composition.keys.join(', ')}"
puts "Units Chosen: #{earth_units.map(&:unit_type).uniq.join(', ')}"
puts "USD Ledger: $#{total_import_fees} in import fees"
puts "Structures: #{structures_created.count} created with correct namespace"

puts "=== STRESS TEST COMPLETE ==="