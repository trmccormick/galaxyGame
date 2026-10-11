# frozen_string_literal: true

# Diagnostic script for C3 RH-400 catalog image path verification
require 'json'

registry = AssetRegistry.new
entry = registry.resolve(AssetRegistry::RH400_ASSET_ID)

puts "=== ENTRY ==="
puts "asset_id: #{entry[:asset_id]}"
puts "blueprint_id: #{entry[:blueprint_id]}"
puts "asset_family: #{entry[:asset_family]}"
puts "component_class: #{entry[:component_class]}"
puts "visual_definition_path: #{entry[:visual_definition_path]}"
puts "representations: #{entry[:representations].inspect}"
puts

catalog_service = CatalogService.new
contract = catalog_service.catalog_data(AssetRegistry::RH400_ASSET_ID)

puts "=== CONTRACT ==="
puts "asset_id: #{contract[:asset_id]}"
puts "blueprint_id: #{contract[:blueprint_id]}"
puts "asset_family: #{contract[:asset_family]}"
puts "component_class: #{contract[:component_class]}"
puts "catalog_render_path: #{contract[:catalog_render_path].inspect}"
puts "inventory_icon_path: #{contract[:inventory_icon_path].inspect}"
puts "representation_status: #{contract[:representation_status].inspect}"
puts "blueprint_data present: #{!contract[:blueprint_data].nil?}"
puts "operational_data present: #{contract.key?(:operational_data) && !contract[:operational_data].nil?}"
puts

render_path = contract[:catalog_render_path]
icon_path = contract[:inventory_icon_path]

puts "=== FILE EXISTENCE ==="
if render_path
  puts "catalog_render exists on disk: #{File.exist?(render_path)} (#{render_path})"
else
  puts "catalog_render_path is nil"
end

if icon_path
  puts "inventory_icon exists on disk: #{File.exist?(icon_path)} (#{icon_path})"
else
  puts "inventory_icon_path is nil"
end

puts
puts "=== BROWSER ACCESSIBLE? ==="
if render_path.nil?
  puts "NO - catalog_render_path is nil, no image will display"
elsif render_path.start_with?('/')
  puts "Path: #{render_path}"
  puts "Would be served at http://host#{render_path}"
  # Check if it's under public/ or a known asset path
  full_path = Rails.root.join('..', render_path.lstrip('/')).to_s
  puts "Resolved from Rails root: #{full_path}"
  puts "Accessible via Rails: #{File.exist?(full_path)}"
else
  puts "Relative path (not browser-accessible without fix): #{render_path}"
end
