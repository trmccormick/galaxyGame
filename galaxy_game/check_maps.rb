puts 'FREECIV_PATH: #{GalaxyGame::Paths::FREECIV_MAPS_PATH}'
puts 'Exists: #{Dir.exist?(GalaxyGame::Paths::FREECIV_MAPS_PATH)}'
puts 'Contents:'
Dir.glob(GalaxyGame::Paths::FREECIV_MAPS_PATH.join('**/*.sav')).each { |f| puts "  #{f}" }
