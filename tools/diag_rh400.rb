require "/home/galaxy_game/config/environment"

registry = AssetRegistry.new
entry = registry.resolve(AssetRegistry::RH400_ASSET_ID)

puts "=== ENTRY ==="
puts "asset_id: #{entry[:asset_id]}"
puts "blueprint_id: #{entry[:blueprint_id]}"
puts "asset_family: #{entry[:asset_family]}"
puts "component_class: #{entry[:component_class]}"
puts "visual_definition_path: #{entry[:visual_definition_path]}"
puts "representations keys: #{(entry[:representations] || {}).keys}"

manifest = entry[:representations] || {}
catalog_rep = manifest["catalog_render"] || manifest[:catalog_render]
puts "catalog_render rep: #{catalog_rep.inspect}"
files = catalog_rep.is_a?(Hash) ? (catalog_rep["files"] || catalog_rep[:files] || []) : []
puts "catalog_render files: #{files.inspect}"

icon_rep = manifest["inventory_icon"] || manifest[:inventory_icon]
puts "inventory_icon rep: #{icon_rep.inspect}"
icon_files = icon_rep.is_a?(Hash) ? (icon_rep["files"] || icon_rep[:files] || []) : []
puts "inventory_icon files: #{icon_files.inspect}"

catalog_service = CatalogService.new
contract = catalog_service.catalog_data(AssetRegistry::RH400_ASSET_ID)

puts "\n=== CONTRACT ==="
puts "catalog_render_path: #{contract[:catalog_render_path].inspect}"
puts "inventory_icon_path: #{contract[:inventory_icon_path].inspect}"
puts "representation_status: #{contract[:representation_status].inspect}"

render_path = contract[:catalog_render_path]
icon_path = contract[:inventory_icon_path]

puts "\n=== FILE EXISTENCE ==="
if render_path
  puts "catalog_render exists: #{File.exist?(render_path)} (#{render_path})"
else
  puts "catalog_render_path is nil"
end

if icon_path
  puts "inventory_icon exists: #{File.exist?(icon_path)} (#{icon_path})"
else
  puts "inventory_icon_path is nil"
end

puts "\n=== BROWSER ACCESSIBLE? ==="
if render_path.nil?
  puts "NO - catalog_render_path is nil, no image will display"
elsif render_path.start_with?("/")
  puts "ABSOLUTE PATH: #{render_path}"
  puts "This is a filesystem path, NOT a URL path."
  puts "image_tag will produce: <img src=\"#{render_path}\">"
  puts "Browser CANNOT access this - it needs to be under public/ or served via Rails asset pipeline."
elsif render_path.start_with?("http")
  puts "URL path - browser accessible"
else
  puts "Relative path: #{render_path}"
end
