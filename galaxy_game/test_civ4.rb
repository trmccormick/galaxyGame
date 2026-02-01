require './app/services/import/civ4_wbs_import_service'
require './app/services/import/civ4_to_galaxy_converter'

# Test import service
service = Import::Civ4WbsImportService.new('/home/galaxy_game/tmp/luna.wbs')
result = service.import
if result
  puts 'Import parsed successfully'
  puts "Grid size: #{result[:height]}x#{result[:width]}"
  puts "Biome counts: #{result[:biome_counts]}"
  
  # Test converter
  converter = Import::Civ4ToGalaxyConverter.new(result)
  planet_data = converter.convert_to_planetary_body
  puts ''
  puts 'Conversion successful'
  puts "Planet type: #{planet_data[:type]}"
  puts "Atmosphere: #{planet_data[:atmosphere]}"
  puts "Hydrosphere: #{planet_data[:hydrosphere]}"
  puts "Temperature: #{planet_data[:temperature]}"
else
  puts 'Import failed'
  puts "Errors: #{service.errors}"
end
