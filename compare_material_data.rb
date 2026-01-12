#!/usr/bin/env ruby
require 'json'
require 'pathname'
require 'set'

# Script to compare old JSON material data with newly generated data
class MaterialDataComparator
  def initialize
    @old_base_paths = [
      Pathname.new('/Users/tam0013/Documents/git/galaxyGame/data/json-data/old-json-data/production_old3/materials'),
      Pathname.new('/Users/tam0013/Documents/git/galaxyGame/data/json-data/old-json-data/production_old3/materials_new/raw'),
      Pathname.new('/Users/tam0013/Documents/git/galaxyGame/data/json-data/old-json-data/production_old4/materials')
    ]
    @new_base_path = Pathname.new('/Users/tam0013/Documents/git/galaxyGame/data/json-data/resources/materials')
  end

  def compare_all
    puts "=== MATERIAL DATA COMPARISON REPORT ===\n\n"

    # Collect all materials from old and new sources
    old_materials = collect_all_materials(@old_base_paths)
    new_materials = collect_all_materials([@new_base_path])

    puts "OLD DATA SUMMARY:"
    puts "- Total materials found: #{old_materials.size}"
    puts "- Categories: #{old_materials.keys.sort.join(', ')}"
    puts ""

    puts "NEW DATA SUMMARY:"
    puts "- Total materials found: #{new_materials.size}"
    puts "- Categories: #{new_materials.keys.sort.join(', ')}"
    puts ""

    # Compare by category
    all_categories = (old_materials.keys + new_materials.keys).uniq.sort

    all_categories.each do |category|
      compare_category(category, old_materials[category] || {}, new_materials[category] || {})
    end

    # Overall comparison
    puts "\n=== OVERALL COMPARISON ==="
    old_total = old_materials.values.sum(&:size)
    new_total = new_materials.values.sum(&:size)

    puts "Total materials - Old: #{old_total}, New: #{new_total}"

    if old_total > new_total
      puts "⚠️  POTENTIAL DATA LOSS: #{old_total - new_total} materials missing from new data"
    elsif new_total > old_total
      puts "ℹ️  Additional materials in new data: #{new_total - old_total}"
    else
      puts "✅ Material counts match"
    end
  end

  private

  def collect_all_materials(base_paths)
    materials = {}

    base_paths.each do |base_path|
      next unless base_path.exist?

      base_path.find do |path|
        next unless path.file? && path.extname == '.json'

        begin
          data = JSON.parse(path.read)
          category = extract_category_from_path(path, base_path)
          materials[category] ||= {}
          materials[category][data['id'] || data['name']&.downcase&.gsub(' ', '_')] = {
            path: path,
            data: data
          }
        rescue JSON::ParserError => e
          puts "Error parsing #{path}: #{e.message}"
        end
      end
    end

    materials
  end

  def extract_category_from_path(path, base_path)
    relative_path = path.relative_path_from(base_path)
    parts = relative_path.to_s.split('/')

    # Extract meaningful category from path
    if parts.include?('gases') || parts.include?('gas')
      'gases'
    elsif parts.include?('liquids') || parts.include?('liquid')
      'liquids'
    elsif parts.include?('raw') && (parts.include?('ore') || parts.include?('meteorites') || parts.include?('geological'))
      'raw_materials'
    elsif parts.include?('chemicals') || parts.include?('processed')
      'processed_materials'
    else
      parts.first || 'other'
    end
  end

  def compare_category(category, old_mats, new_mats)
    puts "\n--- #{category.upcase} ---"

    old_ids = old_mats.keys.to_set
    new_ids = new_mats.keys.to_set

    missing_in_new = old_ids - new_ids
    new_only = new_ids - old_ids
    common = old_ids & new_ids

    puts "Common materials: #{common.size}"
    puts "Missing in new data: #{missing_in_new.size}"
    puts "New materials: #{new_only.size}"

    if missing_in_new.any?
      puts "⚠️  Missing materials: #{missing_in_new.to_a.sort.join(', ')}"
    end

    # Compare properties of common materials
    if common.any?
      puts "\nProperty comparison for common materials:"
      sample_comparison(common.first, old_mats, new_mats)
    end
  end

  def sample_comparison(material_id, old_mats, new_mats)
    old_data = old_mats[material_id]&.dig('data')
    new_data = new_mats[material_id]&.dig('data')

    return unless old_data && new_data

    old_props = extract_properties(old_data)
    new_props = extract_properties(new_data)

    puts "  Sample: #{material_id}"
    puts "  Old properties count: #{old_props.size}"
    puts "  New properties count: #{new_props.size}"

    missing_props = old_props.keys - new_props.keys
    if missing_props.any?
      puts "  ⚠️  Missing properties in new data: #{missing_props.sort.join(', ')}"
    end

    # Check for real scientific data
    scientific_indicators = ['thermal_conductivity', 'specific_heat_capacity', 'density', 'viscosity', 'boiling_point', 'melting_point']
    old_scientific = old_props.keys & scientific_indicators
    new_scientific = new_props.keys & scientific_indicators

    puts "  Scientific properties - Old: #{old_scientific.size}, New: #{new_scientific.size}"
  end

  def extract_properties(data)
    properties = {}

    # Top-level properties
    data.each do |key, value|
      next if ['id', 'name', 'category', 'type', 'description', 'template', 'metadata'].include?(key)
      properties[key] = value
    end

    # Nested properties
    if data['properties']
      properties.merge!(data['properties'])
    end

    properties
  end
end

# Run the comparison
if __FILE__ == $0
  comparator = MaterialDataComparator.new
  comparator.compare_all
end