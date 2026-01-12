#!/usr/bin/env ruby
require 'json'
require 'pathname'
require 'fileutils'

# Script to migrate old JSON material data to v1.3 template format
class MaterialMigrationTool
  def initialize
    @old_base_paths = [
      Pathname.new('/Users/tam0013/Documents/git/galaxyGame/data/json-data/old-json-data/production_old3/materials'),
      Pathname.new('/Users/tam0013/Documents/git/galaxyGame/data/json-data/old-json-data/production_old3/materials_new/raw'),
      Pathname.new('/Users/tam0013/Documents/git/galaxyGame/data/json-data/old-json-data/production_old4/materials')
    ]
    @new_base_path = Pathname.new('/Users/tam0013/Documents/git/galaxyGame/data/json-data/resources/materials')
  end

  def migrate_all
    puts "=== MATERIAL MIGRATION TO V1.3 TEMPLATE ===\n"

    migrated_count = 0
    error_count = 0

    @old_base_paths.each do |old_base|
      next unless old_base.exist?

      old_base.find do |old_path|
        next unless old_path.file? && old_path.extname == '.json'

        begin
          old_data = JSON.parse(old_path.read)
          new_data = migrate_material(old_data)
          new_path = get_new_path(old_path, old_base)

          # Create directory if needed
          FileUtils.mkdir_p(new_path.dirname)

          # Write new file
          File.write(new_path, JSON.pretty_generate(new_data))
          migrated_count += 1

          puts "✅ Migrated: #{old_data['name']} (#{old_data['id']})"

        rescue JSON::ParserError => e
          puts "❌ Error parsing #{old_path}: #{e.message}"
          error_count += 1
        rescue => e
          puts "❌ Error migrating #{old_path}: #{e.message}"
          error_count += 1
        end
      end
    end

    puts "\n=== MIGRATION COMPLETE ==="
    puts "Successfully migrated: #{migrated_count} materials"
    puts "Errors: #{error_count}"
    puts "Total processed: #{migrated_count + error_count}"
  end

  private

  def migrate_material(old_data)
    # Start with v1.3 template structure
    new_data = {
      "template" => "material",
      "metadata" => {
        "version" => "1.3",
        "type" => "material",
        "template_compliance" => "material_v1.3"
      },
      "properties" => {
        "unit_of_measurement" => old_data.dig('properties', 'unit_of_measurement') || "kg",
        "state_at_room_temp" => get_state_at_stp(old_data),
        "purity" => "high"
      },
      "storage" => {
        "pressure" => "atmospheric",
        "temperature" => "room",
        "stability" => "stable",
        "incompatible_with" => []
      },
      "handling" => {
        "ppe_required" => [],
        "hazard_class" => [],
        "disposal" => "standard"
      }
    }

    # Basic identification
    new_data["id"] = old_data["id"]
    new_data["name"] = old_data["name"]
    new_data["description"] = old_data["description"]

    # Category and type mapping
    new_data["category"] = map_category(old_data["category"])
    new_data["subcategory"] = map_subcategory(old_data["category"], old_data["type"])
    new_data["type"] = old_data["type"] || "material"

    # Chemical properties at top level
    if old_data["chemical_formula"]
      new_data["chemical_formula"] = old_data["chemical_formula"]
    end
    
    if old_data.dig("properties", "molar_mass")
      new_data["molar_mass"] = old_data["properties"]["molar_mass"]
    end
    
    if old_data.dig("properties", "boiling_point")
      new_data["boiling_point"] = old_data["properties"]["boiling_point"]
    end
    
    if old_data.dig("properties", "freezing_point")
      new_data["freezing_point"] = old_data["properties"]["freezing_point"]
    end

    # Preserve all original properties in properties section, but exclude chemical properties that are now at top level
    if old_data["properties"]
      new_data["properties"] = {
        "unit_of_measurement" => old_data.dig('properties', 'unit_of_measurement') || "kg",
        "state_at_room_temp" => get_state_at_stp(old_data),
        "purity" => "high"
      }
      old_data["properties"].each do |key, value|
        unless ["molar_mass", "boiling_point", "freezing_point", "chemical_formula", "unit_of_measurement", "state_at_room_temp", "purity"].include?(key)
          new_data["properties"][key] = value
        end
      end
    end

    # Add state_at_stp based on state_at_room_temp
    if old_data.dig("properties", "state_at_room_temp")
      new_data["state_at_stp"] = old_data["properties"]["state_at_room_temp"].downcase
    end

    # Preserve additional sections
    ["sources", "production", "applications", "hazards", "trade_value"].each do |key|
      if old_data[key]
        new_data[key] = old_data[key]
      end
    end

    # Handle applications array
    if old_data["applications"] && old_data["applications"].is_a?(Array)
      new_data["applications"] = old_data["applications"]
    end

    new_data
  end

  def get_state_at_stp(material)
    state = material.dig("properties", "state_at_room_temp")
    return "solid" unless state
    state.downcase
  end

  def map_category(old_category)
    case old_category
    when "gas" then "gases"
    when "liquid" then "liquids"
    when "metal", "processed_material" then "processed"
    when "raw_material" then "raw"
    when "byproduct" then "byproducts"
    else old_category || "other"
    end
  end

  def map_subcategory(category, type)
    case category
    when "gas"
      case type
      when "atmospheric_gas" then "atmospheric"
      when "elemental_gas" then "elemental"
      else "compound"
      end
    when "liquid" then "chemical"
    when "metal" then "metal"
    when "processed_material"
      case type
      when "refined_metal" then "refined_metals"
      when "electronic" then "electronics"
      when "polymer" then "polymers"
      else "processed"
      end
    else "general"
    end
  end

  def get_new_path(old_path, old_base)
    relative_path = old_path.relative_path_from(old_base)
    parts = relative_path.to_s.split('/')

    # Map old structure to new structure
    new_parts = []
    parts.each do |part|
      case part
      when "raw" then new_parts << "raw"
      when "processed" then new_parts << "processed"
      when "gases" then new_parts << "gases" << "compound"
      when "liquids" then new_parts << "liquids" << "chemical"
      when "byproducts" then new_parts << "byproducts" << "waste"
      when "solids" then new_parts << "chemicals" << "solid"
      when "meteorites" then new_parts << "raw" << "meteoritic" << "Stony Meteorite"
      when "ores" then new_parts << "raw" << "geological" << "ore"
      when "geological_materials" then new_parts << "raw" << "geological" << "rock"
      else
        # Keep filename as-is
        if part.end_with?('.json')
          new_parts << part
        else
          new_parts << part
        end
      end
    end

    @new_base_path.join(*new_parts)
  end
end

# Run the migration
if __FILE__ == $0
  migrator = MaterialMigrationTool.new
  migrator.migrate_all
end