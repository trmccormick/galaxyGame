#!/usr/bin/env ruby
# Dry run test script for the GameDataGenerator - DOES NOT SAVE ANY FILES

require 'fileutils'
require 'json'
require_relative '../app/services/game_data_generator'

# Command line arguments
WRITE_MODE = ARGV.include?('--write')
FORCE_OVERWRITE = ARGV.include?('--force')
VERBOSE = ARGV.include?('--verbose')

puts "🧪 Starting Game Data Generator #{WRITE_MODE ? '' : 'Dry Run '}Test..."
puts "📢 #{WRITE_MODE ? 'FILES WILL BE GENERATED' : 'NO FILES WILL BE SAVED'} IN THIS TEST"
puts "⚠️ Existing files will be #{FORCE_OVERWRITE ? 'overwritten' : 'skipped'}" if WRITE_MODE

class DryRunGenerator
  attr_reader :would_generate, :would_skip
  
  def initialize(original_generator)
    @generator = original_generator
    @would_generate = []
    @would_skip = []
  end
  
  # Check if a file exists and should be skipped
  def should_skip?(path)
    return false unless File.exist?(path)
    return false if FORCE_OVERWRITE
    
    puts "  ⚠️ File already exists: #{path}" if VERBOSE
    true
  end
  
  # Intercept the generate_unit method
  def generate_unit(unit_id, category, subcategory, properties = {})
    # Map categories to ensure consistent directory names
    category_mapping = {
      'power' => { blueprint: 'power', operational: 'power' },
      'electronics' => { blueprint: 'electronics', operational: 'electronics' },
      'propulsion' => { blueprint: 'propulsion', operational: 'propulsion' }
    }
    
    # Use mapped categories or defaults
    bp_category = category_mapping.dig(category, :blueprint) || category
    op_category = category_mapping.dig(category, :operational) || category
    
    # Determine paths with consistent categories
    blueprint_path = GalaxyGame::Paths::UNIT_BLUEPRINTS_PATH.join(bp_category, "#{unit_id}_bp.json").to_s
    operational_path = GalaxyGame::Paths::UNITS_PATH.join(op_category, "#{unit_id}_data.json").to_s
    
    puts "\n🔍 Would generate unit: #{unit_id} (#{category}/#{subcategory})"
    
    # Check if files already exist
    blueprint_exists = should_skip?(blueprint_path)
    operational_exists = should_skip?(operational_path)
    
    # Build metadata about what would be generated
    # Build more comprehensive blueprint data
    blueprint_data = {
      id: unit_id,
      name: properties[:name] || unit_id.split('_').map(&:capitalize).join(' '),
      category: category,
      subcategory: subcategory,
      description: properties[:description] || "A #{unit_id.split('_').map(&:capitalize).join(' ')}.",
      physical_properties: properties[:physical_properties] || {},
      crafting: properties[:crafting] || {
        materials: [],
        time_minutes: 30,
        facility_required: "manufacturing_facility"
      },
      metadata: {
        version: "1.0",
        generator: "GameDataGenerator",
        generated_at: Time.now.utc.iso8601
      }
    }
    
    # Build more comprehensive operational data
    operational_data = {
      id: unit_id,
      name: properties[:name] || unit_id.split('_').map(&:capitalize).join(' '),
      category: 'energy', # Always use 'energy' for consistency
      subcategory: subcategory,
      description: properties[:description],
      operational_parameters: {
        power_generation_kw: properties.dig(:power, :generation_kw) || 75.0,
        efficiency: properties.dig(:power, :efficiency) || 0.92,
        operational_temperature: {
          min_c: -150,
          max_c: 120
        },
        lifespan_hours: 50000,
        maintenance_interval_hours: 2000
      },
      physical_properties: properties[:physical_properties] || {
        mass_kg: 120,
        volume_m3: 2.5,
        dimensions: { length_m: 5, width_m: 3, height_m: 0.1 }
      },
      connections: {
        electrical_output: {  # Changed from power_output to electrical_output
          type: "electrical",
          voltage: 28,
          max_current_a: 150
        },
        mounting: {
          type: "standard_frame",
          points: 4
        }
      },
      metadata: {
        version: "1.0",
        generated_at: Time.now.utc.iso8601
      }
    }
    
    # Add category-specific operational properties
    case category
    when 'energy', 'power'  # Handle both for backwards compatibility
      operational_data[:operational_properties] = {
        energy_generation: properties.dig(:energy, :generation_kw) || properties.dig(:power, :generation_kw) || 50.0,
        efficiency: properties.dig(:energy, :efficiency) || properties.dig(:power, :efficiency) || 0.85,
        operational_temperature: { min: -150, max: 120, unit: "C" },
        lifespan_hours: 50000
      }
    when 'electronics'
      operational_data[:operational_properties] = {
        power_consumption: properties.dig(:electronics, :power_consumption_kw) || 1.0,
        data_processing: properties.dig(:electronics, :data_processing_rate) || "25 MB/s",
        range: properties.dig(:electronics, :detection_range_km) || 2
      }
    when 'propulsion'
      operational_data[:operational_properties] = {
        thrust: properties.dig(:propulsion, :thrust_kn) || 1.0,
        specific_impulse: properties.dig(:propulsion, :specific_impulse) || 2800,
        fuel_type: properties.dig(:propulsion, :fuel_type) || "xenon",
        fuel_consumption: properties.dig(:propulsion, :fuel_consumption_rate) || 0.05
      }
    end
    
    # Track the files that would be generated or skipped
    if blueprint_exists || operational_exists
      puts "  ⚠️ Some files already exist:"
      puts "     - Blueprint: #{blueprint_exists ? '⏭️ Would skip (exists)' : '✅ Would generate'}"
      puts "     - Operational data: #{operational_exists ? '⏭️ Would skip (exists)' : '✅ Would generate'}"
      
      @would_skip << {
        type: 'unit',
        id: unit_id,
        blueprint_path: blueprint_exists ? blueprint_path : nil,
        operational_path: operational_exists ? operational_path : nil
      }
    end
    
    # Print paths only for files that would be generated
    puts "  🗂️ Would save blueprint to: #{blueprint_path}" unless blueprint_exists
    puts "  🗂️ Would save operational data to: #{operational_path}" unless operational_exists
    
    # Add to tracking list only for files that would be generated
    file_count = 0
    unless blueprint_exists && operational_exists
      @would_generate << {
        type: 'unit',
        id: unit_id,
        blueprint_path: blueprint_exists ? nil : blueprint_path,
        operational_path: operational_exists ? nil : operational_path,
        blueprint_data: blueprint_data,
        operational_data: operational_data
      }
      file_count += 1 unless blueprint_exists
      file_count += 1 unless operational_exists
    end
    
    # If in write mode, actually write the files
    if WRITE_MODE
      begin
        unless blueprint_exists
          FileUtils.mkdir_p(File.dirname(blueprint_path))
          File.write(blueprint_path, JSON.pretty_generate(blueprint_data))
          puts "  ✅ Saved blueprint to: #{blueprint_path}"
        end
        
        unless operational_exists
          FileUtils.mkdir_p(File.dirname(operational_path))
          File.write(operational_path, JSON.pretty_generate(operational_data))
          puts "  ✅ Saved operational data to: #{operational_path}"
        end
      rescue => e
        puts "  ❌ Error writing files: #{e.message}"
      end
    end
    
    # Return the paths that would be generated
    [blueprint_path, operational_path]
  end
  
  # Intercept the generate_structure method (with file existence checks)
  def generate_structure(structure_id, category, name = nil, description = nil)
    puts "\n🔍 Would generate structure: #{structure_id} (#{category})"
    
    # Determine what paths would be generated - fixed _data.json convention
    blueprint_path = GalaxyGame::Paths::STRUCTURE_BLUEPRINTS_PATH.join(category, "#{structure_id}_bp.json").to_s
    operational_path = GalaxyGame::Paths::STRUCTURES_PATH.join(category, "#{structure_id}_data.json").to_s
    
    # Check if files already exist
    blueprint_exists = should_skip?(blueprint_path)
    operational_exists = should_skip?(operational_path)
    
    # Build metadata about what would be generated
    blueprint_data = {
      id: structure_id,
      name: name || structure_id.split('_').map(&:capitalize).join(' '),
      category: category,
      description: description || "A #{structure_id.split('_').map(&:capitalize).join(' ')}."
    }
    
    operational_data = {
      id: structure_id,
      name: name || structure_id.split('_').map(&:capitalize).join(' '),
      category: category
    }
    
    # Track the files that would be generated or skipped
    if blueprint_exists || operational_exists
      puts "  ⚠️ Some files already exist:"
      puts "     - Blueprint: #{blueprint_exists ? '⏭️ Would skip (exists)' : '✅ Would generate'}"
      puts "     - Operational data: #{operational_exists ? '⏭️ Would skip (exists)' : '✅ Would generate'}"
      
      @would_skip << {
        type: 'structure',
        id: structure_id,
        blueprint_path: blueprint_exists ? blueprint_path : nil,
        operational_path: operational_exists ? operational_path : nil
      }
    end
    
    # Print paths only for files that would be generated
    puts "  🗂️ Would save blueprint to: #{blueprint_path}" unless blueprint_exists
    puts "  🗂️ Would save operational data to: #{operational_path}" unless operational_exists
    
    # Add to tracking list only for files that would be generated
    unless blueprint_exists && operational_exists
      @would_generate << {
        type: 'structure',
        id: structure_id,
        blueprint_path: blueprint_exists ? nil : blueprint_path,
        operational_path: operational_exists ? nil : operational_path,
        blueprint_data: blueprint_data,
        operational_data: operational_data
      }
    end
    
    # If in write mode, actually write the files
    if WRITE_MODE
      begin
        unless blueprint_exists
          FileUtils.mkdir_p(File.dirname(blueprint_path))
          File.write(blueprint_path, JSON.pretty_generate(blueprint_data))
          puts "  ✅ Saved blueprint to: #{blueprint_path}"
        end
        
        unless operational_exists
          FileUtils.mkdir_p(File.dirname(operational_path))
          File.write(operational_path, JSON.pretty_generate(operational_data))
          puts "  ✅ Saved operational data to: #{operational_path}"
        end
      rescue => e
        puts "  ❌ Error writing files: #{e.message}"
      end
    end
    
    # Return the data that would be generated
    [blueprint_data, operational_data]
  end
  
  # Intercept the generate_item method (with file existence checks)
  def generate_item(template_path, output_path, data = {})
    puts "\n🔍 Would generate item from template: #{File.basename(template_path)}"
    
    # Check if file already exists
    file_exists = should_skip?(output_path)
    
    # Print path only if the file would be generated
    puts "  🗂️ Would save to: #{output_path}" unless file_exists
    
    # Track the file that would be generated or skipped
    if file_exists
      puts "  ⏭️ Would skip (file exists): #{output_path}"
      @would_skip << {
        type: 'item',
        output_path: output_path
      }
    else
      # Add this to our tracking list
      @would_generate << {
        type: 'item',
        template: template_path,
        output_path: output_path,
        data: data
      }
      
      # If in write mode, actually write the file
      if WRITE_MODE
        begin
          FileUtils.mkdir_p(File.dirname(output_path))
          File.write(output_path, JSON.pretty_generate(data))
          puts "  ✅ Saved to: #{output_path}"
        rescue => e
          puts "  ❌ Error writing file: #{e.message}"
        end
      end
    end
    
    # Return the data that would be generated
    data
  end
  
  # Enhanced method for material transformation that actually reads files
  def transform_material(source_path, output_path)
    # Check if the source file exists
    unless File.exist?(source_path)
      puts "  ❌ Source file does not exist: #{source_path}"
      return nil
    end
    
    # Check if output file already exists and should be skipped
    file_exists = should_skip?(output_path)
    
    # Print path only if the file would be generated
    puts "  🗂️ Would save to: #{output_path}" unless file_exists
    
    begin
      # Read the old data from the file
      old_data = JSON.parse(File.read(source_path))
      
      # Validate the old data has the expected structure
      unless old_data["id"] && old_data["sources"] && old_data["sources"]["raw_materials"]
        puts "  ❌ Source file does not have the expected structure: #{source_path}"
        return nil
      end
      
      # Transform to new format following the material_v1.1.json template
      # with metadata at the end for better readability
      transformed_data = {
        "template" => "material",
        "id" => old_data["id"],
        "name" => old_data["name"],
        "description" => old_data["description"],
        "category" => "processed",
        "subcategory" => "alloys",
        "properties" => {
          "unit_of_measurement" => "kg",
          "purity" => "standard",
          "state_at_room_temp" => "solid",
          "color" => "metallic gray",
          "electrical_conductivity" => "medium"
        },
        "sources" => {
          "primary_material" => old_data["sources"]["raw_materials"].keys.first,
          "refining_unit" => old_data["sources"]["refining_unit"],
          "purification_method" => "smelting",
          "purification_unit" => "industrial_furnace"
        },
        "composition" => old_data["sources"]["raw_materials"].map { |material, amount| 
          { 
            "material" => material, 
            "amount" => (amount.to_f / old_data["sources"]["raw_materials"].values.sum).round(2)
          }
        },
        "applications" => old_data["applications"] || [],
        "production" => {
          "time" => 30,
          "facility" => "smelting_facility",
          "energy" => old_data["sources"]["energy_cost"],
          "output" => 1
        },
        "requirements" => {
          "technology" => [
            { "name" => "metallurgy", "level" => 1 }
          ],
          "facilities" => ["smelting_facility"]
        },
        "trade_value" => 25,
        "metadata" => {
          "version" => "1.1",
          "type" => "material",
          "original_file" => source_path
        }
      }
      
      # Display the transformation details
      puts "  📝 Transformed from old format to new format:"
      puts "    - Source file: #{source_path}"
      puts "    - Composition conversion:"
      old_data["sources"]["raw_materials"].each do |material, amount|
        percentage = (amount.to_f / old_data["sources"]["raw_materials"].values.sum * 100).round
        puts "      - #{material}: #{amount} units → #{percentage}% by composition"
      end
      
      if file_exists
        @would_skip << {
          type: 'material',
          id: old_data["id"],
          output_path: output_path
        }
      else
        # Add this to our tracking list
        @would_generate << {
          type: 'material',
          id: old_data["id"],
          output_path: output_path,
          data: transformed_data
        }
        
        # If in write mode, actually write the file
        if WRITE_MODE
          begin
            FileUtils.mkdir_p(File.dirname(output_path))
            File.write(output_path, JSON.pretty_generate(transformed_data))
            puts "  ✅ Saved to: #{output_path}"
          rescue => e
            puts "  ❌ Error writing file: #{e.message}"
          end
        end
      end
      
      # Return the transformed data
    rescue JSON::ParserError => e
      puts "  ❌ Error parsing JSON from source file: #{e.message}"
      nil
    rescue => e
      puts "  ❌ Error in transformation: #{e.message}"
      nil
    end
  end
  
  # Add this method to the DryRunGenerator class
  def generate_module(module_id, category, subcategory, properties = {})
    puts "\n🔍 Would generate module: #{module_id} (#{category}/#{subcategory})"
    
    # Mapping of categories for consistent naming
    category_to_blueprint_dir = {
      'electronics' => 'electronics',
      'sensors' => 'electronics',  # Map sensors to electronics category
      'computers' => 'electronics'
    }
    
    category_to_operational_dir = {
      'electronics' => 'electronics',
      'sensors' => 'sensors',  # Keep sensors as its own operational subcategory
      'computers' => 'computers'
    }
    
    # Determine blueprint directory based on mapping
    blueprint_dir = category_to_blueprint_dir[category] || category
    blueprint_path = GalaxyGame::Paths::MODULE_BLUEPRINTS_PATH.join(blueprint_dir, "#{module_id}_bp.json").to_s
    
    # Determine operational directory based on mapping
    operational_dir = category_to_operational_dir[category] || category
    operational_path = GalaxyGame::Paths::SENSORS_MODULES_PATH.join("#{module_id}_data.json").to_s
    
    # Check if files already exist
    blueprint_exists = should_skip?(blueprint_path)
    operational_exists = should_skip?(operational_path)
    
    # Build more comprehensive blueprint data
    blueprint_data = {
      id: module_id,
      name: properties[:name] || module_id.split('_').map(&:capitalize).join(' '),
      category: category,
      subcategory: subcategory,
      description: properties[:description] || "A #{module_id.split('_').map(&:capitalize).join(' ')}.",
      physical_properties: properties[:physical_properties] || {},
      crafting: properties[:crafting] || {
        materials: [],
        time_minutes: 15,  # Modules generally take less time than full units
        facility_required: "electronics_lab" 
      },
      metadata: {
        version: "1.0",
        generator: "GameDataGenerator",
        generated_at: Time.now.utc.iso8601
      }
    }
    
    # Build more comprehensive operational data
    operational_data = {
      id: module_id,
      name: properties[:name] || module_id.split('_').map(&:capitalize).join(' '),
      category: category,
      subcategory: subcategory,
      description: properties[:description],
      operational_parameters: {
        energy_consumption_kw: properties.dig(:electronics, :energy_consumption_kw) || 0.3,
        data_processing_rate: properties.dig(:electronics, :data_processing_rate) || "25 MB/s",
        detection_range_km: properties.dig(:electronics, :detection_range_km) || 2,
        scanning_precision: properties.dig(:electronics, :scanning_precision) || "medium",
        specialized_detection: properties.dig(:electronics, :specialized_detection) || nil
      },
      physical_properties: properties[:physical_properties] || {
        mass_kg: 3.5,
        volume_m3: 0.02,
        dimensions: { length_m: 0.25, width_m: 0.15, height_m: 0.05 }
      },
      connections: {
        data_interface: {
          type: "standard_data_bus",
          bandwidth: "100 MB/s",
          protocol: "unified_space_protocol"
        },
        energy_input: {
          type: "electrical",
          voltage: 5,
          max_current_a: 2
        },
        mounting: {
          type: "module_rack",
          size: "small",
          points: 2
        }
      },
      compatibility: {
        unit_types: properties[:compatibility]&.dig(:unit_types) || ["spacecraft", "rover", "station"],
        environments: properties[:compatibility]&.dig(:environments) || ["vacuum", "atmosphere", "radiation"]
      },
      metadata: {
        version: "1.0",
        generated_at: Time.now.utc.iso8601
      }
    }
    
    # Same file generation logic as other methods
    if blueprint_exists || operational_exists
      puts "  ⚠️ Some files already exist:"
      puts "     - Blueprint: #{blueprint_exists ? '⏭️ Would skip (exists)' : '✅ Would generate'}"
      puts "     - Operational data: #{operational_exists ? '⏭️ Would skip (exists)' : '✅ Would generate'}"
      
      @would_skip << {
        type: 'module',
        id: module_id,
        blueprint_path: blueprint_exists ? blueprint_path : nil,
        operational_path: operational_exists ? operational_path : nil
      }
    end
    
    # Print paths only for files that would be generated
    puts "  🗂️ Would save blueprint to: #{blueprint_path}" unless blueprint_exists
    puts "  🗂️ Would save operational data to: #{operational_path}" unless operational_exists
    
    # Add to tracking list only for files that would be generated
    file_count = 0
    unless blueprint_exists && operational_exists
      @would_generate << {
        type: 'module',
        id: module_id,
        blueprint_path: blueprint_exists ? nil : blueprint_path,
        operational_path: operational_exists ? nil : operational_path,
        blueprint_data: blueprint_data,
        operational_data: operational_data
      }
      file_count += 1 unless blueprint_exists
      file_count += 1 unless operational_exists
    end
    
    # If in write mode, actually write the files
    if WRITE_MODE
      begin
        unless blueprint_exists
          FileUtils.mkdir_p(File.dirname(blueprint_path))
          File.write(blueprint_path, JSON.pretty_generate(blueprint_data))
          puts "  ✅ Saved blueprint to: #{blueprint_path}"
        end
        
        unless operational_exists
          FileUtils.mkdir_p(File.dirname(operational_path))
          File.write(operational_path, JSON.pretty_generate(operational_data))
          puts "  ✅ Saved operational data to: #{operational_path}"
        end
      rescue => e
        puts "  ❌ Error writing files: #{e.message}"
      end
    end
    
    # Return the paths that would be generated
    [blueprint_path, operational_path]
  end
  
  # Method to get summary of what would be generated
  def would_generate_summary
    @would_generate
  end
  
  # Method to get summary of what would be skipped
  def would_skip_summary
    @would_skip
  end
  
  # Forward any other methods to the original generator
  def method_missing(method, *args, &block)
    if @generator.respond_to?(method)
      puts "  ⚠️ Would call #{method} on real generator - not intercepted in dry run"
      @generator.send(method, *args, &block)
    else
      super
    end
  end
  
  def respond_to_missing?(method, include_private = false)
    @generator.respond_to?(method, include_private) || super
  end
end

# Create the real generator and wrap it in our dry run wrapper
real_generator = GameDataGenerator.new('llama3')
generator = DryRunGenerator.new(real_generator)

# ===== TEST 1: Generate an energy unit (solar panel) =====
puts "\n🔆 TEST 1: Generating energy unit (solar panel)"
begin
  paths = generator.generate_unit(
    'improved_solar_panel',
    'energy',  # Using 'energy' not 'power'
    'generation',
    {
      description: "An enhanced solar panel with improved energy conversion efficiency. Designed for use in space environments with limited sunlight.",
      physical_properties: {
        mass_kg: 120,
        volume_m3: 2.5,
        dimensions: { length_m: 5, width_m: 3, height_m: 0.1 }
      },
      energy: {  # Using 'energy' not 'power'
        generation_kw: 75.0,
        efficiency: 0.92
      }
    }
  )
rescue => e
  puts "❌ Error in solar panel test: #{e.message}"
end

# ===== TEST 2: Generate a sensor module (basic sensor) =====
puts "\n🔌 TEST 2: Generating sensor module (basic sensor)"
begin
  paths = generator.generate_module(
    'basic_sensor',
    'sensors',  # Changed from 'electronics' to 'sensors'
    'detection',
    {
      description: "A fundamental sensor array capable of detecting nearby objects and basic environmental conditions.",
      physical_properties: {
        mass_kg: 3.5,
        volume_m3: 0.02,
        dimensions: { length_m: 0.25, width_m: 0.15, height_m: 0.05 }
      },
      electronics: {
        energy_consumption_kw: 0.3,
        data_processing_rate: "50 MB/s",
        detection_range_km: 5,
        scanning_precision: "medium"
      },
      compatibility: {
        unit_types: ["spacecraft", "rover", "station", "satellite"],
        environments: ["vacuum", "thin_atmosphere", "radiation"]
      },
      crafting: {
        materials: [
          { id: "circuit_board", amount: 1, unit: "unit" },
          { id: "wire", amount: 3, unit: "unit" },
          { id: "sensor_element", amount: 2, unit: "unit" }
        ],
        time_minutes: 15
      }
    }
  )
rescue => e
  puts "❌ Error in basic sensor test: #{e.message}"
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
rescue => e
  puts "❌ Error in ion thruster test: #{e.message}"
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
rescue => e
  puts "❌ Error in mining facility test: #{e.message}"
end

# ===== TEST 5: Transform metal_alloy to new format =====
puts "\n🧪 TEST 5: Transforming metal_alloy to new format"
begin
  source_path = "/home/galaxy_game/app/data/old-json-data/production_old3/materials/processed/metals/metal_alloy.json"
  output_path = GalaxyGame::Paths::PROCESSED_ALLOYS_MATERIALS_PATH.join('metal_alloy.json').to_s
  
  # Use the enhanced transform_material method that reads the actual file
  transformed_data = generator.transform_material(source_path, output_path)
  
  if transformed_data.nil?
    puts "  ⚠️ Source file not found or invalid. Using GameDataGenerator to create a new material instead."
    
    # Use the generator to create a new material from scratch instead of using sample data
    template_path = GalaxyGame::Paths::TEMPLATE_PATH.join('material_v1.1.json').to_s
    
    # Generate a new material using the generator
    material_data = {
      id: "metal_alloy",
      name: "Metal Alloy",
      description: "A durable composite metal used for structural integrity and mechanical parts.",
      category: "processed",
      subcategory: "alloys",
      properties: {
        unit_of_measurement: "kg",
        purity: "standard",
        state_at_room_temp: "solid",
        color: "metallic gray",
        electrical_conductivity: "medium"
      },
      composition: [
        { material: "iron", amount: 0.67 },
        { material: "nickel", amount: 0.22 },
        { material: "carbon", amount: 0.11 }
      ],
      applications: [
        "industrial_machinery",
        "structural_supports"
      ],
      metadata: {
        version: "1.1",
        type: "material",
        note: "Generated as new material due to missing source file"
      }
    }
    
    puts "  🔄 Generating new material instead of transformation:"
    puts "    - Using GameDataGenerator to create: #{output_path}"
    
    # Use the regular generate_item method instead of transforming
    generator.generate_item(template_path, output_path, material_data)
  end
rescue => e
  puts "❌ Error in metal alloy test: #{e.message}"
  puts e.backtrace.join("\n") if VERBOSE
end

# ===== SUMMARY =====
puts "\n📊 #{WRITE_MODE ? 'GENERATION' : 'DRY RUN'} SUMMARY:"

# Summary of generated files
generate_summary = generator.would_generate_summary
puts "Would #{WRITE_MODE ? 'generate' : 'have generated'} #{generate_summary.count} files:"

# Group by type for a cleaner summary
by_type = generate_summary.group_by { |item| item[:type] }
by_type.each do |type, items|
  puts "\n  #{type.capitalize}s (#{items.count}):"
  items.each do |item|
    case type
    when 'unit', 'structure'
      puts "    - #{item[:id]}:"
      if item[:blueprint_path]
        puts "      - Blueprint: #{item[:blueprint_path]}" 
      end
      if item[:operational_path]
        puts "      - Operational: #{item[:operational_path]}"
      end
    when 'item', 'material'
      puts "    - #{item[:data][:id] || item[:id] || 'Unknown'}: #{item[:output_path]}"
    end
  end
end

# Summary of skipped files
skip_summary = generator.would_skip_summary
if !skip_summary.empty?
  puts "\n⏭️ Would skip #{skip_summary.count} existing files:"
  
  # Group by type for a cleaner summary
  by_type = skip_summary.group_by { |item| item[:type] }
  by_type.each do |type, items|
    puts "\n  #{type.capitalize}s (#{items.count}):"
    items.each do |item|
      case type
      when 'unit', 'structure'
        puts "    - #{item[:id]}:"
        if item[:blueprint_path]
          puts "      - Blueprint: #{item[:blueprint_path]}" 
        end
        if item[:operational_path]
          puts "      - Operational: #{item[:operational_path]}"
        end
      when 'item', 'material'
        puts "    - #{item[:id] || 'Unknown'}: #{item[:output_path]}"
      end
    end
  end
end

puts "\n✅ #{WRITE_MODE ? 'Generation' : 'Dry run'} test script completed."
puts "👀 #{WRITE_MODE ? 'Check the generated files' : 'Review the output to ensure the paths look correct'}."
puts "\nTo actually write files, run with: bin/rails r tools/test-script-dry-run.rb --write"
puts "To force overwrite existing files, add: --force"
puts "For more detailed output, add: --verbose"