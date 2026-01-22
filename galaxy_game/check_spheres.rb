#!/usr/bin/env ruby
require_relative 'config/environment'

puts "Total celestial bodies: #{CelestialBodies::CelestialBody.count}"
puts "Bodies with hydrospheres: #{CelestialBodies::CelestialBody.joins(:hydrosphere).count}"
puts "Bodies with atmospheres: #{CelestialBodies::CelestialBody.joins(:atmosphere).count}"
puts "Bodies with geospheres: #{CelestialBodies::CelestialBody.joins(:geosphere).count}"
puts "Bodies with biospheres: #{CelestialBodies::CelestialBody.joins(:biosphere).count}"

# Check specific bodies
deimos = CelestialBodies::CelestialBody.find_by(name: 'Deimos')
if deimos
  puts "\nDeimos spheres:"
  puts "  Hydrosphere: #{deimos.hydrosphere.present?}"
  puts "  Atmosphere: #{deimos.atmosphere.present?}"
  puts "  Geosphere: #{deimos.geosphere.present?}"
  puts "  Biosphere: #{deimos.biosphere.present?}"
end

titan = CelestialBodies::CelestialBody.find_by(name: 'Titan')
if titan
  puts "\nTitan spheres:"
  puts "  Hydrosphere: #{titan.hydrosphere.present?}"
  puts "  Atmosphere: #{titan.atmosphere.present?}"
  puts "  Geosphere: #{titan.geosphere.present?}"
  puts "  Biosphere: #{titan.biosphere.present?}"
end