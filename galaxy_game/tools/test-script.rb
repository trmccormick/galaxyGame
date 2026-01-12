#!/usr/bin/env ruby
# Test script for the GameDataGenerator

require 'fileutils'
require 'json'
require_relative '../app/services/game_data_generator'

puts "🧪 Starting Game Data Generator Test..."

# Initialize the generator with the model
generator = GameDataGenerator.new('llama3')

# Create an array to track what we've generated
generated_files = []

# ===== TEST 1: Generate a power unit (solar panel) =====
puts "\n🔆 TEST 1: Generating power unit (solar panel)"
begin
  paths = generator.generate_unit(
    'improved_solar_panel',
    'power',
    'generation',
    {
      description: "An enhanced solar panel with improved energy conversion efficiency. Designed for use in space environments with limited sunlight.",
      physical_properties: {
        mass_kg: 120,
        volume_m3: 2.5,
        dimensions: { length_m: 5, width_m: 3, height_m: 0.1 }
      },
      power: {
        generation_kw: 75.0,
        efficiency: 0.92
      }
    }
  )
  
  puts "✅ Generated solar panel files:"
  puts "  - Blueprint: #{paths[0]}"
  puts "  - Operational data: #{paths[1]}"
  
  generated_files.concat(paths)
rescue => e
  puts "❌ Error generating solar panel: #{e.message}"
end

# ===== TEST 2: Generate an electronics unit (basic sensor) =====
puts "\n🔌 TEST 2: Generating electronics unit (basic sensor)"
begin
  paths = generator.generate_unit(
    'basic_sensor',
    'electronics',
    'sensors',
    {
      description: "A fundamental sensor array capable of detecting nearby objects and basic environmental conditions.",
      physical_properties: {
        mass_kg: 10,
        volume_m3: 0.05
      },
      electronics: {
        power_consumption_kw: 1.2,
        data_processing_rate: "50 MB/s",
        detection_range_km: 5
      },
      crafting: {
        materials: [
          { id: "circuit_board", amount: 2, unit: "unit" },
          { id: "wire", amount: 5, unit: "unit" },
          { id: "metal_plate", amount: 1, unit: "unit" }
        ],
        time_minutes: 20
      }
    }
  )
  
  puts "✅ Generated basic sensor files:"
  puts "  - Blueprint: #{paths[0]}"
  puts "  - Operational data: #{paths[1]}"
  
  generated_files.concat(paths)
rescue => e
  puts "❌ Error generating basic sensor: #{e.message}"
end

# ===== TEST 3: Generate a propulsion unit (ion thruster) =====
puts "\n🚀 TEST 3: Generating propulsion unit (ion thruster)"
begin
  paths = generator.generate_unit(
    'advanced_ion_thruster',
    'propulsion',
    'thrusters',
    {
      description: "A high-efficiency ion thruster using xenon propellant. Provides low thrust but excellent specific impulse for long-duration missions.",
      physical_properties: {
        mass_kg: 85,
        volume_m3: 0.75
      },
      propulsion: {
        thrust_kn: 2.5,
        specific_impulse: 3200,
        fuel_type: "xenon",
        fuel_consumption_rate: 0.1
      }
    }
  )
  
  puts "✅ Generated ion thruster files:"
  puts "  - Blueprint: #{paths[0]}"
  puts "  - Operational data: #{paths[1]}"
  
  generated_files.concat(paths)
rescue => e
  puts "❌ Error generating ion thruster: #{e.message}"
end

# ===== TEST 4: Generate a structure (mining facility) =====
puts "\n⛏️ TEST 4: Generating structure (mining facility)"
begin
  results = generator.generate_structure(
    'regolith_mining_facility',
    'resource_extraction',
    'Regolith Mining Facility',
    'An automated mining facility designed to extract regolith from the lunar surface for processing into construction materials.'
  )
  
  blueprint_path = results[0]['id'] ? GalaxyGame::Paths::STRUCTURE_BLUEPRINTS_PATH.join('resource_extraction', "regolith_mining_facility_bp.json").to_s : nil
  operational_path = results[1]['id'] ? GalaxyGame::Paths::STRUCTURES_PATH.join('resource_extraction', "regolith_mining_facility.json").to_s : nil
  
  puts "✅ Generated mining facility files:"
  puts "  - Blueprint: #{blueprint_path}"
  puts "  - Operational data: #{operational_path}"
  
  generated_files << blueprint_path if blueprint_path
  generated_files << operational_path if operational_path
rescue => e
  puts "❌ Error generating mining facility: #{e.message}"
end

# ===== TEST 5: Generate a material template for lunar regolith =====
puts "\n🌑 TEST 5: Generating material template for lunar regolith"
begin
  template_path = GalaxyGame::Paths::TEMPLATE_PATH.join('material_v1.1.json').to_s
  output_path = GalaxyGame::Paths::RAW_GEOLOGICAL_MATERIALS_PATH.join('lunar_regolith.json').to_s
  
  regolith = generator.generate_item(
    template_path,
    output_path,
    {
      id: "lunar_regolith",
      name: "Lunar Regolith",
      description: "Fine, powdery material covering the lunar surface. Can be processed into construction materials or separated for mineral extraction.",
      category: "raw",
      subcategory: "geological",
      physical_properties: {
        state: "solid",
        density_kg_per_m3: 1500,
        color: "gray"
      },
      game_properties: {
        value: 5,
        rarity: "common",
        harvestable: true
      },
      composition: [
        { "material": "silicon_dioxide", "percentage": 45 },
        { "material": "iron_oxide", "percentage": 15 },
        { "material": "calcium_oxide", "percentage": 10 },
        { "material": "aluminum_oxide", "percentage": 10 },
        { "material": "magnesium_oxide", "percentage": 10 },
        { "material": "titanium_dioxide", "percentage": 5 },
        { "material": "trace_elements", "percentage": 5 }
      ]
    }
  )
  
  puts "✅ Generated lunar regolith material file:"
  puts "  - Material: #{output_path}"
  
  generated_files << output_path
rescue => e
  puts "❌ Error generating lunar regolith material: #{e.message}"
end

# ===== SUMMARY =====
puts "\n📊 TEST SUMMARY:"
puts "Successfully generated #{generated_files.count} files:"
generated_files.each { |path| puts "  - #{path}" }

puts "\n✅ Test script completed."
puts "👀 Check the generated files to ensure they contain appropriate content."