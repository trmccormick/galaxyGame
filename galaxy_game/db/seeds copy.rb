# Method to calculate gravity based on mass and radius
def calculate_gravity(mass, radius)
  gravitational_constant = 6.67430e-11 # in m^3 kg^-1 s^-2
  radius_in_meters = radius * 1000 # Convert km to meters
  (gravitational_constant * mass) / (radius_in_meters ** 2)
end

# Create Celestial Bodies with total atmospheric mass estimation
celestial_bodies = [
  { model_class: CelestialBody, name: 'Mercury', mass: 3.30e23, radius: 2.44e6, density: 5.427, distance_from_star: 5.79e7, size: 0.3829, orbital_period: 87.97, atmosphere_composition: {}, surface_temperature: 440, gravity: calculate_gravity(3.30e23, 2.44e6), albedo: 0.12, insolation: 9126, known_pressure: 0 },
  { model_class: CelestialBody, name: 'Venus', mass: 4.87e24, radius: 6.05e6, density: 5.243, distance_from_star: 1.08e8, size: 0.9499, orbital_period: 224.7, atmosphere_composition: { CO2: 96.5, N2: 3.5 }, known_pressure: 92.0, total_atmospheric_mass: 4.8e20, surface_temperature: 737, gravity: calculate_gravity(4.87e24, 6.05e6), albedo: 0.65, insolation: 2613 },
  { model_class: CelestialBody, name: 'Earth', mass: 5.97e24, radius: 6.37e6, density: 5.514, distance_from_star: 1.496e8, size: 1.0, orbital_period: 365.25, atmosphere_composition: { N2: 78.08, O2: 20.95, Ar: 0.93, CO2: 0.04 }, known_pressure: 1.000, total_atmospheric_mass: 5.1e18, surface_temperature: 288, gravity: calculate_gravity(5.97e24, 6.37e6), albedo: 0.30, insolation: 1361 },
  { model_class: Moon, name: 'Moon', mass: 7.35e22, radius: 1.74e6, density: 3.344, distance_from_star: 1.496e8, size: 0.273, orbital_period: 27.32, atmosphere_composition: {}, surface_temperature: 220, gravity: calculate_gravity(7.35e22, 1.74e6), albedo: 0.12, insolation: 1361, known_pressure: 0 },
  { model_class: CelestialBody, name: 'Mars', mass: 6.42e23, radius: 3.39e6, density: 3.9335, distance_from_star: 2.279e8, size: 0.5320, orbital_period: 686.98, atmosphere_composition: { CO2: 95.32, N2: 2.7, Ar: 1.6, O2: 0.13 }, known_pressure: 0.006, total_atmospheric_mass: 2.5e16, surface_temperature: 210, gravity: calculate_gravity(6.42e23, 3.39e6), albedo: 0.25, insolation: 586 },
  { model_class: GasGiant, name: 'Jupiter', mass: 1.90e27, radius: 6.99e7, density: 1.326, distance_from_star: 7.785e8, size: 11.209, orbital_period: 4331, atmosphere_composition: { H2: 89.8, He: 10.2 }, total_atmospheric_mass: 1.9e27, surface_temperature: 165, gravity: calculate_gravity(1.90e27, 6.99e7), albedo: 0.52, insolation: 50.5, known_pressure: 0 },
  { model_class: Moon, name: 'Io', mass: 8.93e22, radius: 1.82e6, density: 3.528, distance_from_star: 7.785e8, size: 0.286, orbital_period: 1.77, atmosphere_composition: { SO2: 90.0, SO: 10.0 }, surface_temperature: 130, gravity: calculate_gravity(8.93e22, 1.82e6), albedo: 0.63, insolation: 50.5, known_pressure: 0 },
  { model_class: Moon, name: 'Europa', mass: 4.8e22, radius: 1.56e6, density: 3.013, distance_from_star: 7.785e8, size: 0.245, orbital_period: 3.55, atmosphere_composition: {}, surface_temperature: 102, gravity: calculate_gravity(4.8e22, 1.56e6), albedo: 0.68, insolation: 50.5, known_pressure: 0 },
  { model_class: Moon, name: 'Ganymede', mass: 1.48e23, radius: 2.63e6, density: 1.936, distance_from_star: 7.785e8, size: 0.413, orbital_period: 7.15, atmosphere_composition: {}, surface_temperature: 110, gravity: calculate_gravity(1.48e23, 2.63e6), albedo: 0.43, insolation: 50.5, known_pressure: 0 },
  { model_class: Moon, name: 'Callisto', mass: 1.08e23, radius: 2.41e6, density: 1.834, distance_from_star: 7.785e8, size: 0.378, orbital_period: 16.69, atmosphere_composition: {}, surface_temperature: 134, gravity: calculate_gravity(1.08e23, 2.41e6), albedo: 0.17, insolation: 50.5, known_pressure: 0 },
  { model_class: GasGiant, name: 'Saturn', mass: 5.68e26, radius: 5.82e7, density: 0.687, distance_from_star: 1.433e9, size: 9.449, orbital_period: 10747, atmosphere_composition: { H2: 96.3, He: 3.7 }, total_atmospheric_mass: 1.2e27, surface_temperature: 134, gravity: calculate_gravity(5.68e26, 5.82e7), albedo: 0.47, insolation: 15.0, known_pressure: 0 },
  { model_class: Moon, name: 'Titan', mass: 1.345e23, radius: 2.575e6, density: 1.88, distance_from_star: 1.433e9, size: 0.400, orbital_period: 15.95, atmosphere_composition: { N2: 95.0, CH4: 5.0 }, known_pressure: 1.5, surface_temperature: 94, gravity: calculate_gravity(1.345e23, 2.575e6), albedo: 0.22, insolation: 15.0 },
  { model_class: IceGiant, name: 'Uranus', mass: 8.68e25, radius: 2.54e7, density: 1.27, distance_from_star: 2.872e9, size: 4.007, orbital_period: 30589, atmosphere_composition: { H2: 82.5, He: 15.2, CH4: 2.3 }, total_atmospheric_mass: 8.0e24, surface_temperature: 76, gravity: calculate_gravity(8.68e25, 2.54e7), albedo: 0.51, insolation: 3.7, known_pressure: 0 },
  { model_class: IceGiant, name: 'Neptune', mass: 1.02e26, radius: 2.46e7, density: 1.638, distance_from_star: 4.495e9, size: 3.883, orbital_period: 59800, atmosphere_composition: { H2: 80.0, He: 19.0, CH4: 1.5 }, total_atmospheric_mass: 7.6e24, surface_temperature: 72, gravity: calculate_gravity(1.02e26, 2.46e7), albedo: 0.41, insolation: 1.5, known_pressure: 0 },
  { model_class: Moon, name: 'Triton', mass: 2.14e22, radius: 1.35e6, density: 2.061, distance_from_star: 4.495e9, size: 0.212, orbital_period: 5.88, atmosphere_composition: { N2: 99.0, CH4: 1.0 }, total_atmospheric_mass: 2.0e21, surface_temperature: 38, gravity: calculate_gravity(2.14e22, 1.35e6), albedo: 0.76, insolation: 1.5, known_pressure: 0 },
  { model_class: DwarfPlanet, name: 'Pluto', mass: 1.31e22, radius: 1.19e6, density: 1.854, distance_from_star: 5.906e9, size: 0.1868, orbital_period: 90560, atmosphere_composition: { N2: 90.0, CH4: 9.0, CO: 1.0 }, total_atmospheric_mass: 1.3e15, surface_temperature: 44, gravity: calculate_gravity(1.31e22, 1.19e6), albedo: 0.52, insolation: 0.9, known_pressure: 0 },
  { model_class: DwarfPlanet, name: 'Charon', mass: 1.52e21, radius: 6.07e5, density: 1.702, distance_from_star: 5.906e9, size: 0.095, orbital_period: 90560, atmosphere_composition: {}, surface_temperature: 53, gravity: calculate_gravity(1.52e21, 6.07e5), albedo: 0.35, insolation: 0.9, known_pressure: 0 },
  { model_class: DwarfPlanet, name: 'Ceres', mass: 9.39e20, radius: 4.73e5, density: 2.09, distance_from_star: 4.14e8, size: 0.148, orbital_period: 1680, atmosphere_composition: {}, surface_temperature: 167, gravity: calculate_gravity(9.39e20, 4.73e5), albedo: 0.09, insolation: 150, known_pressure: 0 },
  { model_class: DwarfPlanet, name: 'Haumea', mass: 4.01e21, radius: 8.16e5, density: 1.885, distance_from_star: 6.45e9, size: 0.1, orbital_period: 103774, atmosphere_composition: {}, surface_temperature: 32, gravity: calculate_gravity(4.01e21, 8.16e5), albedo: 0.7, insolation: 0.6, known_pressure: 0 },
  { model_class: DwarfPlanet, name: 'Makemake', mass: 3.1e21, radius: 7.15e5, density: 1.7, distance_from_star: 6.85e9, size: 0.1, orbital_period: 112897, atmosphere_composition: {}, surface_temperature: 30, gravity: calculate_gravity(3.1e21, 7.15e5), albedo: 0.77, insolation: 0.5, known_pressure: 0 },
  { model_class: DwarfPlanet, name: 'Eris', mass: 1.66e22, radius: 1.16e6, density: 2.52, distance_from_star: 1.01e10, size: 0.18, orbital_period: 203830, atmosphere_composition: {}, surface_temperature: 30, gravity: calculate_gravity(1.66e22, 1.16e6), albedo: 0.96, insolation: 0.4, known_pressure: 0 }
]

# Method to calculate total atmospheric pressure based on gas quantities
def calculate_total_pressure(gas_quantities)
  gas_quantities.values.sum
end

# Method to calculate gas mass based on percentage and total atmospheric mass
def calculate_gas_mass(percentage, total_atmospheric_mass)
  return 0 if total_atmospheric_mass.nil? # Handle nil case
  (percentage / 100.0) * total_atmospheric_mass
end

# Helper method to create celestial body data
def create_celestial_body(model_class:, **attributes)
  # Handle model-specific logic
  case model_class.name
  when 'DwarfPlanet'
    attributes[:mass] = attributes[:mass].to_f
    attributes[:radius] = attributes[:radius].to_f
    attributes[:density] = attributes[:density].to_f
    attributes[:distance_from_star] = attributes[:distance_from_star].to_f
    attributes[:size] = attributes[:size].to_f
    attributes[:orbital_period] = attributes[:orbital_period].to_f
    attributes[:gravity] ||= calculate_gravity(attributes[:mass], attributes[:radius])
    attributes[:total_atmospheric_mass] ||= 0
    model_class.create!(attributes)
  else
    # Default handling for other celestial bodies
    model_class.create!(attributes)
  end
end

# Create the Sun
sun = Star.create!(
  name: 'Sun',
  luminosity: 3.828e26,
  mass: 1.989e30,
  life: 'Main Sequence',
  age: 4.6e9,
  r_ecosphere: 1.496e8,
  type_of_star: 'Main Sequence',
  radius: 6.9634e8,
  temperature: 5778
)
sun.save!

# Create the Solar System
solar_system = SolarSystem.create!(name: 'Sol', current_star: sun)

# Iterate through each celestial body and create the appropriate records
celestial_bodies.each do |body|
  celestial_body = create_celestial_body(**body.merge(solar_system: solar_system))

  # Initialize the atmosphere for celestial bodies with atmosphere_composition
  if body[:atmosphere_composition] && !body[:atmosphere_composition].empty?
    Atmosphere.create!(
      celestial_body: celestial_body,
      temperature: body[:surface_temperature],
      pressure: body[:known_pressure] || calculate_total_pressure(body[:atmosphere_composition]),
      atmosphere_composition: body[:atmosphere_composition],
      total_atmospheric_mass: body[:total_atmospheric_mass]
    )
  end

  # Initialize the materials for celestial bodies with materials
  # if body[:crust_composition] && !body[:crust_composition].empty?
  #   Geosphere.create!(
  #     celestial_body: celestial_body,
  #     materials: body[:crust_composition]
  #   )
  # end

  # Initialize the hydrosphere for celestial bodies with water_ice
  # if body[:crust_composition] && body[:crust_composition].key?(:water_ice)
  #   Hydrosphere.create!(
  #     celestial_body: celestial_body,
  #     water_ice: body[:crust_composition][:water_ice]
  #   )
  # end

  # Initialize the biosphere for celestial bodies with known biosphere data
  # if body[:biosphere_data]
  #   Biosphere.create!(
  #     celestial_body: celestial_body,
  #     **body[:biosphere_data]
  #   )
  # end
end