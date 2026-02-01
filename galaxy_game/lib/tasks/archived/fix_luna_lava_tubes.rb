#!/usr/bin/env ruby
require 'json'

file_path = 'app/data/star_systems/sol/celestial_bodies/earth/luna/geological_features/lava_tubes.json'
data = JSON.parse(File.read(file_path))

puts "File-level tier: #{data['tier']}"
puts "Number of features: #{data['features'].length}"

data['features'].each_with_index do |feature, i|
  puts "Feature #{i}: #{feature['name']} - has tier? #{feature.key?('tier')} - tier value: #{feature['tier'].inspect}"
end

# Force add tier to all features
data['features'].each do |feature|
  feature['tier'] = 'strategic'
end

File.write(file_path, JSON.pretty_generate(data))
puts "\n✅ Forced tier='strategic' on all #{data['features'].length} features"
