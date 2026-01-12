#!/usr/bin/env ruby
require 'yaml'
require 'json'
require 'fileutils'
require 'pathname'
require_relative 'config/environment'  # Load Rails environment for paths

# Script to convert YAML material definitions to JSON format
class MaterialConverter
  def initialize
    @base_dir = GalaxyGame::Paths::JSON_DATA.join('resources', 'materials')
    @template = {
      "template" => "material",
      "metadata" => {
        "version" => "1.3",
        "type" => "material",
        "template_compliance" => "material_v1.3"
      },
      "properties" => {
        "unit_of_measurement" => "kg",
        "state_at_room_temp" => "solid",
        "purity" => "variable"
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
  end

  def convert_raw_ores
    data = YAML.load_file(Rails.root.join('config', 'raw_materials', 'raw_ores.yml'))
    data['raw_ores'].each do |ore|
      material = @template.dup
      material['id'] = ore['name'].downcase.gsub(' ', '_')
      material['name'] = ore['name']
      material['description'] = ore['description']
      material['category'] = 'raw'
      material['subcategory'] = 'geological'
      material['type'] = 'ore'

      # Add smelting information if available
      if ore['smelting_output'] && !ore['smelting_output'].empty?
        material['production'] = {
          'smelting' => {
            'outputs' => ore['smelting_output'],
            'waste' => ore['waste_material']
          }
        }
      end

      save_material(material)
    end
  end

  def convert_meteorites
    data = YAML.load_file(Rails.root.join('config', 'raw_materials', 'meteorites.yml'))
    data['meteorites'].each do |meteorite|
      material = @template.dup
      material['id'] = meteorite['name'].downcase.gsub(' ', '_').gsub('-', '_')
      material['name'] = meteorite['name']
      material['description'] = meteorite['description']
      material['category'] = 'raw'
      material['subcategory'] = 'meteoritic'
      material['type'] = meteorite['type']

      if meteorite['smelting_output'] && !meteorite['smelting_output'].empty?
        material['production'] = {
          'processing' => {
            'outputs' => meteorite['smelting_output'],
            'waste' => meteorite['waste_material']
          }
        }
      end

      save_material(material)
    end
  end

  def convert_materials
    data = YAML.load_file(Rails.root.join('config', 'raw_materials', 'materials.yml'))
    data['materials'].each do |mat|
      material = @template.dup
      material['id'] = mat['name'].downcase.gsub(' ', '_')
      material['name'] = mat['name']
      material['description'] = mat['description']
      material['category'] = determine_category(mat)
      material['type'] = 'compound'

      # Add chemical properties
      material['chemical_formula'] = mat['chemical_formula'] if mat['chemical_formula']
      material['molar_mass'] = mat['molar_mass'] if mat['molar_mass']
      material['boiling_point'] = mat['boiling_point'] if mat['boiling_point']
      material['freezing_point'] = mat['freezing_point'] if mat['freezing_point']
      material['state_at_stp'] = mat['state_at_room_temp'].downcase
      material['properties'].merge!({
        'chemical_formula' => mat['chemical_formula'],
        'molar_mass' => mat['molar_mass'],
        'boiling_point' => mat['boiling_point'],
        'freezing_point' => mat['freezing_point'],
        'state_at_room_temp' => mat['state_at_room_temp'].downcase,
        'color' => mat['color']
      })

      # Add aliases if present
      if mat['aliases']
        material['aliases'] = mat['aliases']
      end

      # Add uses
      if mat['uses']
        material['applications'] = mat['uses']
      end

      save_material(material)
    end
  end

  def convert_geological
    data = YAML.load_file(Rails.root.join('config', 'raw_materials', 'geological_materials.yml'))
    data['geological_materials'].each do |rock|
      material = @template.dup
      material['id'] = rock['name'].downcase
      material['name'] = rock['name']
      material['description'] = rock['description']
      material['category'] = 'raw'
      material['subcategory'] = 'geological'
      material['type'] = rock['type'].downcase

      if rock['use_cases']
        material['applications'] = rock['use_cases']
      end

      save_material(material)
    end
  end

  private

  def determine_category(material)
    name = material['name'].downcase
    formula = material['chemical_formula']

    if ['water', 'ethanol', 'glycerol', 'sulfuric_acid', 'mercury'].include?(name) ||
       material['state_at_room_temp'] == 'Liquid'
      'liquids'
    elsif material['state_at_room_temp'] == 'Gas' ||
          ['oxygen', 'nitrogen', 'hydrogen', 'helium', 'argon', 'neon', 'methane', 'carbon_dioxide', 'ammonia', 'sulfur_dioxide', 'carbon_monoxide', 'hydrogen_sulfide', 'sulfur_hexafluoride', 'nitrous_oxide', 'ozone', 'acetylene'].include?(name)
      'gases'
    else
      'chemicals'
    end
  end

  def save_material(material)
    # Determine save path based on category
    category = material['category']
    subcategory = material['subcategory']
    type = material['type']
    id = material['id']

    case category
    when 'raw'
      if subcategory == 'meteoritic'
        path = "raw/meteoritic/#{type}/#{id}.json"
      else
        path = "raw/geological/#{type}/#{id}.json"
      end
    when 'gases'
      path = "gases/#{id}.json"
    when 'liquids'
      path = "liquids/#{id}.json"
    when 'chemicals'
      path = "chemicals/#{id}.json"
    else
      path = "processed/#{id}.json"
    end

    full_path = @base_dir.join(path)
    FileUtils.mkdir_p(File.dirname(full_path))

    File.write(full_path, JSON.pretty_generate(material))
    puts "Saved: #{full_path}"
  end
end

# Run the conversion
converter = MaterialConverter.new
puts "Converting raw ores..."
converter.convert_raw_ores
puts "Converting meteorites..."
converter.convert_meteorites
puts "Converting materials..."
converter.convert_materials
puts "Converting geological materials..."
converter.convert_geological
puts "Conversion complete!"