#!/usr/bin/env ruby
require 'json'

BASE = 'app/data/star_systems/sol/celestial_bodies'

def add_tier(file_path)
  full_path = File.join(BASE, file_path)
  return puts "  ⚠ Not found: #{file_path}" unless File.exist?(full_path)
  
  data = JSON.parse(File.read(full_path))
  file_tier = data['tier']
  changed = 0
  
  if data['features'].is_a?(Array)
    data['features'].each do |feature|
      unless feature.key?('tier')
        feature['tier'] = file_tier
        changed += 1
      end
    end
    
    if changed > 0
      File.write(full_path, JSON.pretty_generate(data))
      filename = File.basename(file_path)
      puts "  ✓ Updated #{changed} features in #{filename}"
    else
      filename = File.basename(file_path)
      puts "  - Already has tier: #{filename}"
    end
  end
end

puts "Adding tier field to features..."
add_tier('earth/luna/geological_features/lava_tubes.json')
add_tier('earth/luna/geological_features/craters.json')
add_tier('earth/luna/geological_features/craters_catalog.json')
add_tier('mars/geological_features/craters.json')
add_tier('mars/geological_features/craters_catalog.json')
add_tier('mars/geological_features/lava_tubes.json')
add_tier('mars/geological_features/valles.json')
add_tier('earth/geological_features/canyons.json')
puts "✅ Done!"
