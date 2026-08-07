require_relative '../config/environment'

# Create test data
ss = SolarSystem.first || create(:solar_system)
star = Star.first || create(:star, luminosity: 3.846e26, solar_system: ss)

body = CelestialBody.create!(
  name: 'Test Mars',
  solar_system: ss,
  has_magnetosphere: false,
  mass: 4.372e24,
  radius: 3389500.0
)
CelestialBodies::StarDistance.create!(celestial_body: body, star: star, distance: 2.279e11)

atm = CelestialBodies::Spheres::Atmosphere.create!(celestial_body: body)
gas = CelestialBodies::Materials::Gas.create!(atmosphere: atm, name: 'CO2', percentage: 95.0, mass: 1000.0)

puts "Before simulate:"
puts "  Gas ID: #{gas.id}, mass: #{gas.mass}"
puts "  Star distance (m): #{body.star_distances.first.distance}"
puts "  Star distance (km): #{body.star_distances.first.distance / 1000.0}"

svc = TerraSim::AtmosphereSimulationService.new(body)
factor = svc.send(:calculate_solar_wind_factor)
puts "  Solar wind factor: #{factor}"

# Manually calculate what should happen
loss_rate = factor * 1.0  # CO2 factor
new_mass = gas.mass - gas.mass * loss_rate
puts "  Expected new mass (manual calc): #{new_mass}"

svc.simulate

body.reload
gas.reload
puts "After simulate:"
puts "  Gas ID: #{gas.id}, mass: #{gas.mass}"

# Cleanup
gas.destroy
atm.destroy
CelestialBodies::StarDistance.where(celestial_body: body).destroy_all
body.destroy
