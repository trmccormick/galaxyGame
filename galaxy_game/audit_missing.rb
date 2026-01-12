
require 'json'
require_relative 'config/initializers/game_data_paths'

existing = Dir.glob(GalaxyGame::Paths::MATERIALS_PATH.join('**', '*.json')).map do |f|
  begin
    JSON.parse(File.read(f))['id']
  rescue
    nil
  end
end.compact.sort.uniq

required = []
Dir.glob(GalaxyGame::Paths::BLUEPRINTS_PATH.join('units', '**', '*.json')).each do |f|
  begin
    data = JSON.parse(File.read(f))
    if data['required_materials'].is_a?(Hash)
      required.concat(data['required_materials'].keys)
    end
  rescue
    # skip
  end
end
required = required.compact.sort.uniq

missing = required - existing
puts "Missing materials (\#{missing.size}):"
missing.each { |m| puts m }
