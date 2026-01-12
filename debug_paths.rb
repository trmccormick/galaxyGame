puts "RAILS_ROOT: #{Rails.root}"
default_path = Rails.root.join('app', 'data', 'json-data')
puts "default_path: #{default_path}"
puts "default_path exists: #{default_path.exist?}"
puts "resources exists: #{default_path.join('resources').exist?}"
container_path = Pathname.new('/home/galaxy_game/app/data')
puts "container_path: #{container_path}"
puts "container_path exists: #{container_path.exist?}"
puts "container resources exists: #{container_path.join('resources').exist?}"
puts "JSON_DATA: #{GalaxyGame::Paths::JSON_DATA}"
