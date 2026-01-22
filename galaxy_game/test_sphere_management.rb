# Test script for sphere management functionality
require './config/environment'

puts "Testing sphere management functionality..."

# Find a test celestial body
celestial_body = CelestialBodies::CelestialBody.first
if celestial_body.nil?
  puts "No celestial bodies found. Creating a test one..."
  solar_system = SolarSystem.create!(name: "Test System", x: 0, y: 0, z: 0)
  celestial_body = CelestialBodies::TerrestrialPlanet.create!(
    name: "Test Planet",
    identifier: "test-planet-001",
    solar_system: solar_system,
    size: 1.0,
    mass: 5.97e24,
    radius: 6371000,
    gravity: 9.81,
    density: 5514
  )
end

puts "Using celestial body: #{celestial_body.name} (ID: #{celestial_body.id})"

# Test spheres collection
spheres = celestial_body.spheres
puts "Current spheres: #{spheres.map { |s| "#{s.class.name.demodulize}: #{s.id}" }.join(', ')}"

# Test creating a cryosphere if it doesn't exist
unless celestial_body.cryosphere
  puts "Creating cryosphere..."
  cryosphere = celestial_body.create_cryosphere!(
    thickness: 5000,
    shell_type: 'ice',
    properties: { thermal_conductivity: 2.2, density: 917 },
    composition: { 'H2O' => 100.0 }
  )
  puts "Created cryosphere with ID: #{cryosphere.id}"
else
  puts "Cryosphere already exists with ID: #{celestial_body.cryosphere.id}"
end

# Test spheres collection again
spheres_after = celestial_body.spheres
puts "Spheres after creation: #{spheres_after.map { |s| "#{s.class.name.demodulize}: #{s.id}" }.join(', ')}"

puts "Test completed successfully!"