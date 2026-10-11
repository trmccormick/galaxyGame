require "/home/galaxy_game/config/environment"

# 1. Check what AssetRegistry sees for RH-400
registry = AssetRegistry.new
puts "=== ASSET REGISTRY ==="
puts "RH400_ASSET_ID: #{AssetRegistry::RH400_ASSET_ID}"
puts "RH400_BLUEPRINT_ID: #{AssetRegistry::RH400_BLUEPRINT_ID}"

# Check if anything is registered
puts "Registered assets: #{registry.all_assets.map { |e| e[:asset_id] }}"

# Try resolve
entry = registry.resolve(AssetRegistry::RH400_ASSET_ID)
puts "resolve(RH400_ASSET_ID): #{entry.inspect}"

# Check visual definition path resolution
vd_path = registry.send(:find_visual_definition_path, AssetRegistry::RH400_ASSET_ID)
puts "find_visual_definition_path: #{vd_path.inspect}"
puts "VD exists: #{File.exist?(vd_path) if vd_path}"

# Check blueprint path resolution
bp_path = registry.send(:find_blueprint_path, AssetRegistry::RH400_BLUEPRINT_ID)
puts "find_blueprint_path: #{bp_path.inspect}"
puts "BP exists: #{File.exist?(bp_path) if bp_path}"

# 2. Check what CatalogService sees
puts "\n=== CATALOG SERVICE ==="
catalog_service = CatalogService.new
puts "JSON_DATA: #{catalog_service.base_path}"

# Find RH-400 blueprint entry
blueprint_entries = catalog_service.entries.select { |e| e[:source_type] == 'blueprint' && e[:data]['id'] == AssetRegistry::RH400_BLUEPRINT_ID }
puts "Blueprint entries for regolith_harvester_rover: #{blueprint_entries.size}"
blueprint_entries.each do |e|
  puts "  id=#{e[:id]} name=#{e[:name]} file_path=#{e[:file_path]}"
end

# Find RH-400 operational_data entry
op_entries = catalog_service.entries.select { |e| e[:source_type] == 'operational_data' && e[:data]['blueprint_id'] == AssetRegistry::RH400_BLUEPRINT_ID }
puts "Operational data entries for regolith_harvester_rover: #{op_entries.size}"
op_entries.each do |e|
  puts "  id=#{e[:id]} name=#{e[:name]} file_path=#{e[:file_path]}"
end

# 3. Check catalog_data assembly
puts "\n=== CATALOG DATA ASSEMBLY ==="
contract = catalog_service.catalog_data(AssetRegistry::RH400_ASSET_ID)
if contract.nil?
  puts "catalog_data returned nil!"
else
  puts "asset_id: #{contract[:asset_id]}"
  puts "blueprint_id: #{contract[:blueprint_id]}"
  puts "asset_family: #{contract[:asset_family]}"
  puts "component_class: #{contract[:component_class]}"
  puts "catalog_render_path: #{contract[:catalog_render_path].inspect}"
  puts "inventory_icon_path: #{contract[:inventory_icon_path].inspect}"
  puts "representation_status: #{contract[:representation_status].inspect}"
  
  # Check file existence
  if contract[:catalog_render_path]
    puts "\ncatalog_render exists on disk: #{File.exist?(contract[:catalog_render_path])}"
    puts "catalog_render path: #{contract[:catalog_render_path]}"
  end
  
  # Check what image_tag would produce
  if contract[:catalog_render_path]
    puts "\n=== IMAGE_TAG OUTPUT ==="
    puts "image_tag would produce:"
    puts "<img src=\"#{contract[:catalog_render_path]}\" alt=\"RH-400 catalog render\">"
    puts "\nBrowser URL: http://localhost:3000#{contract[:catalog_render_path]}"
    puts "This is #{'browser-accessible' if contract[:catalog_render_path].start_with?('/public/') || contract[:catalog_render_path].include?('public')}."
  end
end

# 4. Check what representations the registry found
puts "\n=== REPRESENTATION MANIFEST ==="
manifest = entry[:representations] if entry
if manifest
  puts "Keys: #{manifest.keys}"
  manifest.each do |profile, info|
    files = info.is_a?(Hash) ? (info['files'] || info[:files] || []) : []
    status = info.is_a?(Hash) ? (info['status'] || info[:status]) : nil
    puts "  #{profile}: status=#{status} files=#{files.size}"
    files.each { |f| puts "    - #{f} (exists: #{File.exist?(f)})" }
  end
else
  puts "No manifest (entry is nil)"
end

# 5. Check what find_representation_files would glob for
puts "\n=== GLOB PATTERNS ==="
prefix = AssetRegistry::RH400_FILE_PREFIX
catalog_images_dir = GalaxyGame::Paths::JSON_DATA.join('images', 'catalog')
puts "Searching: #{catalog_images_dir}"
puts "Prefix: #{prefix}"

patterns = [
  "**/#{prefix}*concept*.png",
  "**/#{prefix}*regolith*.png",
  "**/#{prefix}*catalog*.png"
]
patterns.each do |pattern|
  full_pattern = catalog_images_dir.join(pattern)
  matches = Dir.glob(full_pattern)
  puts "  #{pattern}: #{matches.size} matches"
  matches.each { |f| puts "    - #{f}" }
end

# Check if the actual image files exist
actual_files = Dir.glob("/home/galaxy_game/app/data/images/catalog/crafts/ground/*rh400*.png")
puts "\n=== ACTUAL FILES ON DISK ==="
actual_files.each { |f| puts "  #{f} (exists: #{File.exist?(f)})" }
