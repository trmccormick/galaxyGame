#!/usr/bin/env ruby
require_relative 'config/environment'

earth = CelestialBodies::CelestialBody.find_by(name: 'Earth')
titan = CelestialBodies::CelestialBody.find_by(name: 'Titan')

puts '=== Earth Spheres by Level ==='
earth.spheres_by_level.each do |s|
  puts "Level #{s[:level]}: #{s[:name]} - #{s[:description]}"
end

puts "\n=== Titan Spheres by Level ==="
titan.spheres_by_level.each do |s|
  puts "Level #{s[:level]}: #{s[:name]} - #{s[:description]}"
end

puts "\n=== Earth Max Level: #{earth.max_sphere_level} ==="
puts "=== Titan Max Level: #{titan.max_sphere_level} ==="

puts "\n=== Accessibility Tests ==="
puts "Earth level 2 accessible: #{earth.sphere_level_accessible?(2)}"
puts "Earth level 4 accessible: #{earth.sphere_level_accessible?(4)}"
puts "Titan level 2 accessible: #{titan.sphere_level_accessible?(2)}"