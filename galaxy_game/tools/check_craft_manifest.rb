# tools/check_craft_manifest.rb

# ===========================
# Usage:
#   rails runner tools/check_craft_manifest.rb <manifest_path_or_id> [--migrate]
#
# Example:
#   rails runner tools/check_craft_manifest.rb starship_precursor_manifest_v1.json
#   rails runner tools/check_craft_manifest.rb starship_precursor_manifest_v1.json --migrate
#   rails runner tools/check_craft_manifest.rb starship_precursor_mission --migrate
# ===========================

require 'json'
require 'securerandom'
require 'fileutils'

puts "\n🔍 Starting Manifest Inventory Checker..."

manifest_arg = nil
auto_migrate = false

ARGV.each do |arg|
  if arg == '--migrate'
    auto_migrate = true
  else
    manifest_arg ||= arg
  end
end

if manifest_arg.nil?
  puts "❌ ERROR: Please provide a manifest path or craft id."
  exit 1
end

# Use GalaxyGame::Paths::JSON_DATA for all data lookups
DATA_PATH = GalaxyGame::Paths::JSON_DATA

# Find manifest file by path or by searching missions folder
manifest_path =
  if File.exist?(manifest_arg)
    manifest_arg
  else
    # Search recursively for any file that matches the argument (filename or partial)
    search_pattern = File.join(DATA_PATH, 'missions', '**', '*')
    found = Dir[search_pattern].find { |f| File.basename(f) == manifest_arg || File.basename(f).include?(manifest_arg) }
    found
  end

unless manifest_path && File.exist?(manifest_path)
  puts "❌ ERROR: Manifest file not found for '#{manifest_arg}'."
  exit 1
end

puts "Using manifest: #{manifest_path}"

manifest = JSON.parse(File.read(manifest_path))
inventory = manifest['inventory'] || {}

# Lookup services
unit_lookup = Lookup::UnitLookupService.new
craft_lookup = Lookup::CraftLookupService.new
rig_lookup = defined?(Lookup::RigLookupService) ? Lookup::RigLookupService.new : nil
modules_lookup = defined?(Lookup::ModuleLookupService) ? Lookup::ModuleLookupService.new : nil
item_lookup = Lookup::ItemLookupService.new

missing = []
generated = []

def generate_item_with_llm(item_id, item_name, category)
  # Replace this with your actual LLM/generator integration
  generator = GameDataGenerator.new
  generator.generate_item(item_id, item_name, category: category)
end

puts "\n🧾 Checking manifest inventory..."

inventory.each do |category, items|
  next unless items.is_a?(Array)
  items.each do |item_config|
    item_id = item_config['id']
    item_name = item_config['name'] || item_id
    found = false

    case category
    when 'units'
      found = !!unit_lookup.find_unit(item_id)
    when 'craft'
      found = !!craft_lookup.find_craft(item_id)
    when 'rigs'
      found = rig_lookup&.find_rig(item_id)
    when 'modules'
      found = modules_lookup&.find_module(item_id)
    else # supplies, consumables, items, etc.
      found = !!item_lookup.find_item(item_id)
    end

    if found
      puts "  ✅ [#{category.singularize}] #{item_name} (#{item_id})"
    else
      puts "  ❌ [#{category.singularize}] #{item_name} (#{item_id}) is missing"
      missing << {category: category, id: item_id, name: item_name}
      if auto_migrate
        path = generate_item_with_llm(item_id, item_name, category)
        puts "     🛠️ Generated: #{path}"
        generated << {category: category, id: item_id, name: item_name, path: path}
      end
    end
  end
end

puts "\n📊 Summary:"
puts "  Missing: #{missing.size}"
missing.each { |m| puts "    - [#{m[:category]}] #{m[:name]} (#{m[:id]})" }
if generated.any?
  puts "  Generated: #{generated.size}"
  generated.each { |g| puts "    - [#{g[:category]}] #{g[:name]} (#{g[:id]}) → #{g[:path]}" }
end

if missing.any? && !auto_migrate
  puts "\n❗ Some manifest items are missing. Run with --migrate to auto-generate missing items."
elsif missing.any?
  puts "\n⚠️ Some items were generated, but you should review them for completeness."
else
  puts "\n✅ All manifest inventory items are present."
end
