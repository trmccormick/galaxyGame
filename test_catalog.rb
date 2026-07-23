service = CatalogService.new
puts "Base path: #{service.base_path}"
puts "Exists: #{service.base_path.exist?}"
puts "Blueprints path: #{service.base_path.join('blueprints')}"
puts "Blueprints exists: #{service.base_path.join('blueprints').exist?}"
puts "Total entries: #{service.entries.size}"
solar_results = service.entries_for(search: 'solar')
puts "Solar search: #{solar_results.size} results"
