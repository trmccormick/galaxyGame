puts 'Testing find_available_maps...'
require './app/controllers/admin/celestial_bodies_controller.rb'
controller = Admin::CelestialBodiesController.new
maps = controller.send(:find_available_maps)
puts "Found #{maps.size} maps"
maps.each { |m| puts "- #{m[:name]} (#{m[:type]}) - #{m[:file_path]}" }
