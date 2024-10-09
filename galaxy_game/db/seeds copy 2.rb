# Method to calculate gravity based on mass and radius
def calculate_gravity(mass, radius)
  gravitational_constant = 6.67430e-11 # in m^3 kg^-1 s^-2
  radius_in_meters = radius * 1000 # Convert km to meters
  (gravitational_constant * mass) / (radius_in_meters ** 2)
end

# Create Celestial Bodies with total atmospheric mass estimation
celestial_bodies = [
  { model_class: CelestialBodies::CelestialBody, name: 'Mercury', mass: '3.30e23', radius: 2.44e6, density: 5.427, distance_from_star: 5.79e7, size: 0.3829, orbital_period: 87.97, surface_temperature: 440, gravity: calculate_gravity(3.30e23, 2.44e6), albedo: 0.12, insolation: 9126, known_pressure: 0 },
  { model_class: CelestialBodies::CelestialBody, name: 'Venus', mass: '4.87e24', radius: 6.05e6, density: 5.243, distance_from_star: 1.08e8, size: 0.9499, orbital_period: 224.7, surface_temperature: 737, gravity: calculate_gravity(4.87e24, 6.05e6), albedo: 0.65, insolation: 2613, known_pressure: 92.0 },
  { model_class: CelestialBodies::CelestialBody, name: 'Earth', mass: '5.97e24', radius: 6.37e6, density: 5.514, distance_from_star: 1.496e8, size: 1.0, orbital_period: 365.25, surface_temperature: 288, gravity: calculate_gravity(5.97e24, 6.37e6), albedo: 0.30, insolation: 1361, known_pressure: 1.0 },
  { model_class: CelestialBodies::Moon, name: 'Moon', mass: '7.35e22', radius: 1.74e6, density: 3.344, distance_from_star: 1.496e8, size: 0.273, orbital_period: 27.32, surface_temperature: 220, gravity: calculate_gravity(7.35e22, 1.74e6), albedo: 0.12, insolation: 1361, known_pressure: 0 },
  { model_class: CelestialBodies::CelestialBody, name: 'Mars', mass: '6.42e23', radius: 3.39e6, density: 3.9335, distance_from_star: 2.279e8, size: 0.5320, orbital_period: 686.98, surface_temperature: 210, gravity: calculate_gravity(6.42e23, 3.39e6), albedo: 0.25, insolation: 586, known_pressure: 0.006 },
  { model_class: CelestialBodies::GasGiant, name: 'Jupiter', mass: '1.90e27', radius: 6.99e7, density: 1.326, distance_from_star: 7.785e8, size: 11.209, orbital_period: 4331, surface_temperature: 165, gravity: calculate_gravity(1.90e27, 6.99e7), albedo: 0.52, insolation: 50.5, known_pressure: 0 },
  { model_class: CelestialBodies::Moon, name: 'Io', mass: '8.93e22', radius: 1.82e6, density: 3.528, distance_from_star: 7.785e8, size: 0.286, orbital_period: 1.77, surface_temperature: 130, gravity: calculate_gravity(8.93e22, 1.82e6), albedo: 0.63, insolation: 50.5, known_pressure: 0 },
  { model_class: CelestialBodies::Moon, name: 'Europa', mass: '4.8e22', radius: 1.56e6, density: 3.013, distance_from_star: 7.785e8, size: 0.245, orbital_period: 3.55, surface_temperature: 102, gravity: calculate_gravity(4.8e22, 1.56e6), albedo: 0.68, insolation: 50.5, known_pressure: 0 },
  { model_class: CelestialBodies::Moon, name: 'Ganymede', mass: '1.48e23', radius: 2.63e6, density: 1.936, distance_from_star: 7.785e8, size: 0.413, orbital_period: 7.15, surface_temperature: 110, gravity: calculate_gravity(1.48e23, 2.63e6), albedo: 0.43, insolation: 50.5, known_pressure: 0 },
  { model_class: CelestialBodies::Moon, name: 'Callisto', mass: '1.08e23', radius: 2.41e6, density: 1.834, distance_from_star: 7.785e8, size: 0.378, orbital_period: 16.69, surface_temperature: 134, gravity: calculate_gravity(1.08e23, 2.41e6), albedo: 0.17, insolation: 50.5, known_pressure: 0 },
  { model_class: CelestialBodies::GasGiant, name: 'Saturn', mass: '5.68e26', radius: 5.82e7, density: 0.687, distance_from_star: 1.433e9, size: 9.449, orbital_period: 10747, surface_temperature: 134, gravity: calculate_gravity(5.68e26, 5.82e7), albedo: 0.47, insolation: 15.0, known_pressure: 0 },
  { model_class: CelestialBodies::Moon, name: 'Titan', mass: '1.345e23', radius: 2.575e6, density: 1.88, distance_from_star: 1.433e9, size: 0.400, orbital_period: 15.95, known_pressure: 1.5, surface_temperature: 94, gravity: calculate_gravity(1.345e23, 2.575e6), albedo: 0.22, insolation: 15.0 },
  { model_class: CelestialBodies::IceGiant, name: 'Uranus', mass: '8.68e25', radius: 2.54e7, density: 1.27, distance_from_star: 2.872e9, size: 4.007, orbital_period: 30589, surface_temperature: 76, gravity: calculate_gravity(8.68e25, 2.54e7), albedo: 0.51, insolation: 3.7, known_pressure: 0 },
  { model_class: CelestialBodies::IceGiant, name: 'Neptune', mass: '1.02e26', radius: 2.46e7, density: 1.638, distance_from_star: 4.495e9, size: 3.883, orbital_period: 59800, surface_temperature: 72, gravity: calculate_gravity(1.02e26, 2.46e7), albedo: 0.41, insolation: 1.5, known_pressure: 0 },
  { model_class: CelestialBodies::Moon, name: 'Triton', mass: '2.14e22', radius: 1.35e6, density: 2.061, distance_from_star: 4.495e9, size: 0.212, orbital_period: 5.88, surface_temperature: 38, gravity: calculate_gravity(2.14e22, 1.35e6), albedo: 0.76, insolation: 1.5, known_pressure: 0 },
  { model_class: CelestialBodies::DwarfPlanet, name: 'Pluto', mass: '1.31e22', radius: 1.19e6, density: 1.854, distance_from_star: 5.906e9, size: 0.1868, orbital_period: 90560, surface_temperature: 44, gravity: calculate_gravity(1.31e22, 1.19e6), albedo: 0.52, insolation: 0.9, known_pressure: 0 },
  { model_class: CelestialBodies::DwarfPlanet, name: 'Charon', mass: '1.52e21', radius: 6.07e5, density: 1.702, distance_from_star: 5.906e9, size: 0.095, orbital_period: 90560, surface_temperature: 53, gravity: calculate_gravity(1.52e21, 6.07e5), albedo: 0.35, insolation: 0.9, known_pressure: 0 },
  { model_class: CelestialBodies::DwarfPlanet, name: 'Ceres', mass: '9.39e20', radius: 4.73e5, density: 2.09, distance_from_star: 4.14e8, size: 0.148, orbital_period: 1680, surface_temperature: 167, gravity: calculate_gravity(9.39e20, 4.73e5), albedo: 0.09, insolation: 150, known_pressure: 0 },
  { model_class: CelestialBodies::DwarfPlanet, name: 'Haumea', mass: '4.01e21', radius: 8.16e5, density: 1.885, distance_from_star: 6.45e9, size: 0.1, orbital_period: 103774, surface_temperature: 32, gravity: calculate_gravity(4.01e21, 8.16e5), albedo: 0.7, insolation: 0.6, known_pressure: 0 },
  { model_class: CelestialBodies::DwarfPlanet, name: 'Makemake', mass: '3.1e21', radius: 7.15e5, density: 1.7, distance_from_star: 6.85e9, size: 0.1, orbital_period: 112897, surface_temperature: 30, gravity: calculate_gravity(3.1e21, 7.15e5), albedo: 0.77, insolation: 0.5, known_pressure: 0 },
  { model_class: CelestialBodies::DwarfPlanet, name: 'Eris', mass: '1.66e22', radius: 1.16e6, density: 2.52, distance_from_star: 1.01e10, size: 0.18, orbital_period: 203830, surface_temperature: 30, gravity: calculate_gravity(1.66e22, 1.16e6), albedo: 0.96, insolation: 0.4, known_pressure: 0 }
]

geospheres = [
  { name: 'Mercury', crust_composition: { oxygen: 42.0, sodium: 29.0, hydrogen: 22.0, helium: 6.0, potassium: 0.5, other: 0.5 }, crust_mass: 1.0e22 },
  { name: 'Venus', crust_composition: { oxygen: 46.6, silicon: 27.72, aluminium: 8.13, iron: 5.00, calcium: 3.63, sodium: 2.83, potassium: 2.60, magnesium: 2.08 }, crust_mass: 4.87e24, crust_thickness: '20-25 km', rock_type: 'mafic silicate' },
  { name: 'Earth', crust_composition: { oxygen: 46.6, silicon: 27.72, aluminium: 8.13, iron: 5.00, calcium: 3.63, sodium: 2.83, potassium: 2.60, magnesium: 2.08 }, crust_mass: 5.97e24 },
  { name: 'Mars', crust_composition: { silicon: 'unknown', oxygen: 'unknown', iron: 'unknown', magnesium: 'unknown', aluminium: 'unknown', calcium: 'unknown', potassium: 'unknown' }, crust_mass: 6.42e23 },
  { name: 'Moon', crust_composition: { oxygen: 43.0, silicon: 21.0, magnesium: 20.0, iron: 10.0, calcium: 3.0, aluminium: 2.0, sodium: 1.0 }, crust_mass: 7.35e22 },
  { name: 'Io', crust_composition: { sulfur: 40.0, oxygen: 30.0, silicon: 20.0, iron: 10.0 }, crust_mass: 8.93e22 },
  { name: 'Europa', crust_composition: { oxygen: 46.6, silicon: 27.72, aluminium: 8.13, iron: 5.00, calcium: 3.63, sodium: 2.83, potassium: 2.60, magnesium: 2.08 }, crust_mass: 4.8e22 },
  { name: 'Ganymede', crust_composition: { oxygen: 46.6, silicon: 27.72, aluminium: 8.13, iron: 5.00, calcium: 3.63, sodium: 2.83, potassium: 2.60, magnesium: 2.08 }, crust_mass: 1.48e23 },
  { name: 'Callisto', crust_composition: { oxygen: 46.6, silicon: 27.72, aluminium: 8.13, iron: 5.00, calcium: 3.63, sodium: 2.83, potassium: 2.60, magnesium: 2.08 }, crust_mass: 1.08e23 },
  { name: 'Titan', crust_composition: { nitrogen: 98.4, methane: 1.6 }, crust_mass: 1.345e23 },
  { name: 'Triton', crust_composition: { nitrogen: 99.9, methane: 0.1 }, crust_mass: 2.14e22 },
  { name: 'Pluto', crust_composition: { nitrogen: 90.0, methane: 10.0 }, crust_mass: 1.31e22 },
  { name: 'Charon', crust_composition: { nitrogen: 100.0 }, crust_mass: 1.52e21 },
  { name: 'Ceres', crust_composition: { water_ice: 50.0, silicate_rock: 50.0 }, crust_mass: 9.39e20 },
  { name: 'Haumea', crust_composition: { water_ice: 50.0, silicate_rock: 50.0 }, crust_mass: 4.01e21 },
  { name: 'Makemake', crust_composition: { nitrogen: 100.0 }, crust_mass: 3.1e21 },
  { name: 'Eris', crust_composition: { nitrogen: 100.0 }, crust_mass: 1.66e22 }
]

hydrospheres = [
  { name: 'Earth', liquid_volume: 1.4e21, lakes: 0, rivers: 0, oceans: 0, ice: 100, liquid_name: 'water' },
  { name: 'Europa', liquid_volume: 3.0e21, lakes: 0, rivers: 0, oceans: 0, ice: 100, liquid_name: 'water' },
  { name: 'Ganymede', liquid_volume: 3.0e21, lakes: 0, rivers: 0, oceans: 0, ice: 100, liquid_name: 'water' },
  { name: 'Callisto', liquid_volume: 3.0e21, lakes: 0, rivers: 0, oceans: 0, ice: 100, liquid_name: 'water' },
  { name: 'Titan', liquid_volume: 3.0e21, lakes: 0, rivers: 0, oceans: 0, ice: 100,  liquid_name: 'methane and ethane' },
  { name: 'Enceladus', liquid_volume: 1.0e20, lakes: 0, rivers: 0, oceans: 0, ice: 100, liquid_name: 'water' },
  { name: 'Triton', liquid_volume: 2.0e21, lakes: 0, rivers: 0, oceans: 0, ice: 100, liquid_name: 'water' },
  { name: 'Pluto', liquid_volume: 1.0e21, lakes: 0, rivers: 0, oceans: 0, ice: 100, liquid_name: 'water' },
  { name: 'Ceres', liquid_volume: 1.0e20, lakes: 0, rivers: 0, oceans: 0, ice: 100, liquid_name: 'water' }
]

atmospheres = [
  { 
    name: 'Venus', 
    atmosphere_composition: [
      { name: "CO2", percentage: 96.5 }, 
      { name: "N2",  percentage: 3.5 },
      { name: "dust", percentage: 0.1 } 
    ], 
    pressure: 92.0, 
    total_atmospheric_mass: 4.8e20,
    pollution: "None"
  },
  { 
    name: 'Earth', 
    atmosphere_composition: [
      { name: "N2", percentage: 78.08 }, 
      { name: "O2", percentage: 20.95 }, 
      { name: "Ar", percentage: 0.93 }, 
      { name: "CO2", percentage: 0.04 },
      { name: "pollution", percentage: "Variable" }
    ], 
    pressure: 1.0, 
    total_atmospheric_mass: 5.1e18 
  },
  { 
    name: 'Mars', 
    atmosphere_composition: [
      { name: "CO2", percentage: 95.32 }, 
      { name: "N2", percentage: 2.7 }, 
      { name: "Ar", percentage: 1.6 },
      { name: "dust", percentage: 0.5 }
    ], 
    pressure: 0.006, 
    total_atmospheric_mass: 2.5e16 
  },
  { 
    name: 'Titan', 
    atmosphere_composition: [
      { name: "N2", percentage: 98.4 }, 
      { name: "CH4", percentage: 1.6 },
      { name: "dust", percentage: 0.2 }
    ], 
    pressure: 1.5, 
    total_atmospheric_mass: 1.5e19 
  },
  { 
    name: 'Triton', 
    atmosphere_composition: [
      { name: "N2", percentage: 99.9 }, 
      { name: "CH4", percentage: 0.1 },
      { name: "dust", percentage: 0.05 }
    ], 
    pressure: 0.014, 
    total_atmospheric_mass: 2.0e21 
  },
  { 
    name: 'Jupiter', 
    atmosphere_composition: [
      { name: "H2", percentage: 89.8 }, 
      { name: "He", percentage: 10.2 },
      { name: "dust", percentage: 0.01 }
    ], 
    pressure: 0, 
    total_atmospheric_mass: 1.9e27 
  },
  { 
    name: 'Saturn', 
    atmosphere_composition: [
      { name: "H2", percentage: 96.3 }, 
      { name: "He", percentage: 3.7 },
      { name: "dust", percentage: 0.02 }
    ], 
    pressure: 0, 
    total_atmospheric_mass: 5.68e26 
  },
  { 
    name: 'Uranus', 
    atmosphere_composition: [
      { name: "H2", percentage: 82.5 }, 
      { name: "He", percentage: 15.2 }, 
      { name: "CH4", percentage: 2.3 },
      { name: "dust", percentage: 0.01 }
    ], 
    pressure: 0, 
    total_atmospheric_mass: 8.68e25 
  },
  { 
    name: 'Neptune', 
    atmosphere_composition: [
      { name: "H2", percentage: 80 }, 
      { name: "He", percentage: 19 }, 
      { name: "CH4", percentage: 1 },
      { name: "dust", percentage: 0.01 }
    ], 
    pressure: 0, 
    total_atmospheric_mass: 1.02e26 
  },
  { 
    name: 'Pluto', 
    atmosphere_composition: [
      { name: "N2", percentage: 90 }, 
      { name: "CH4", percentage: 10 },
      { name: "dust", percentage: 0.1 }
    ], 
    pressure: 0, 
    total_atmospheric_mass: 1.31e22 
  },
  { 
    name: 'Charon', 
    atmosphere_composition: [
      { name: "N2", percentage: 100 },
      { name: "dust", percentage: 0.01 }
    ], 
    pressure: 0, 
    total_atmospheric_mass: 1.52e21 
  },
  { 
    name: 'Ceres', 
    atmosphere_composition: [
      { name: "H2O", percentage: 100 }, 
      { name: "dust", percentage: 0.05 }
    ], 
    pressure: 0, 
    total_atmospheric_mass: 9.1e20 
  },
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
    attributes[:mass] = attributes[:mass]
    attributes[:radius] = attributes[:radius].to_f
    attributes[:density] = attributes[:density].to_f
    attributes[:distance_from_star] = attributes[:distance_from_star].to_f
    attributes[:size] = attributes[:size].to_f
    attributes[:orbital_period] = attributes[:orbital_period].to_f
    attributes[:gravity] ||= calculate_gravity(attributes[:mass].to_f, attributes[:radius])
    # attributes[:total_atmospheric_mass] ||= 0
    model_class.create!(attributes)
  else
    # Default handling for other celestial bodies
    model_class.create!(attributes)
  end
end

# Create the Solar System
solar_system = SolarSystem.create!(name: 'Sol')

# Create the Sun
sun = solar_system.stars.create!(
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

# Iterate through each celestial body and create the appropriate records
ActiveRecord::Base.transaction do
  celestial_bodies.each do |body|
    celestial_body = body[:model_class].create!(body.except(:model_class).merge(solar_system: solar_system))

    # Initialize the atmosphere for celestial bodies with atmosphere_composition
    # if body[:atmosphere_composition] && !body[:atmosphere_composition].empty?
    #   Atmosphere.create!(
    #     celestial_body: celestial_body,
    #     temperature: body[:surface_temperature],
    #     pressure: body[:known_pressure] || calculate_total_pressure(body[:atmosphere_composition]),
    #     atmosphere_composition: body[:atmosphere_composition],
    #     total_atmospheric_mass: body[:total_atmospheric_mass]
    #   )
    # end

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
end

atmospheres.each do |atmosphere|
  celestial_body = CelestialBodies::CelestialBody.find_by(name: atmosphere[:name])
  next unless celestial_body

  # Build an atmosphere if it doesn't exist
  celestial_body.build_atmosphere unless celestial_body.atmosphere

  celestial_body.atmosphere.update!(
    atmosphere_composition: atmosphere[:atmosphere_composition],
    pressure: atmosphere[:pressure],
    total_atmospheric_mass: atmosphere[:total_atmospheric_mass],
    pollution: atmosphere[:pollution] || 'None'
  )

  celestial_body.atmosphere.reset

  # Save the atmosphere and celestial body
  celestial_body.atmosphere.save!
  celestial_body.save!
end

hydrospheres.each do |hydrosphere|
  celestial_body = CelestialBodies::CelestialBody.find_by(name: hydrosphere[:name])
  next unless celestial_body

  # Build a hydrosphere if it doesn't exist
  if celestial_body.hydrosphere.nil?
    celestial_body.build_hydrosphere(
      liquid_name: 'unknown',
      liquid_volume: 0,
      lakes: 0,
      rivers: 0,
      oceans: 0,
      ice: 0
    )
  end

  celestial_body.hydrosphere.update!(
    liquid_name: hydrosphere[:liquid_name],
    liquid_volume: hydrosphere[:liquid_volume],
    lakes: hydrosphere[:lakes],
    rivers: hydrosphere[:rivers],
    oceans: hydrosphere[:oceans],
    ice: hydrosphere[:ice]
  )  

  # Save the atmosphere and celestial body
  celestial_body.hydrosphere.save!
  celestial_body.save!

  # base_units = [
  #   {
  #     name: "Inflatable Habitat Module",
  #     outpost: outpost,
  #     base_materials: {
  #       kevlar_fabric: "500 kg",
  #       aluminum_mylar_layers: "200 kg",
  #       airtight_polymer_liner: "100 kg"
  #     },
  #     operating_requirements: {
  #       power: "5 kW",
  #       water: "50 liters/day",
  #       oxygen: "20 kg/day",
  #       food: "10 kg/day"
  #     },
  #     output_materials: {
  #       carbon_dioxide: "20 kg/day",
  #       waste_water: "30 liters/day"
  #     }
  #   },
  #   {
  #     name: "Colony Greenhouse",
  #     colony: colony,
  #     base_materials: {
  #       glass_panels: "1000 kg",
  #       steel_frame: "500 kg",
  #       hydroponic_system: "200 kg"
  #     },
  #     operating_requirements: {
  #       power: "15 kW",
  #       water: "100 liters/day",
  #       oxygen: "10 kg/day"
  #     },
  #     output_materials: {
  #       food: "50 kg/day",
  #       oxygen: "5 kg/day"
  #     }
  #   },
  #   {
  #     name: "City Power Station",
  #     city: city,
  #     base_materials: {
  #       solar_panels: "2000 kg",
  #       battery_storage: "500 kg"
  #     },
  #     operating_requirements: {
  #       power: "0 kW" # Generates power
  #     },
  #     output_materials: {
  #       power: "100 kW"
  #     }
  #   }
  # ]

  # materials

  # materials = {
  #   'Mercury' => [
  #     { name: 'Helium-3', mass: 1.0e18, percentage: 0.01, uses: ['nuclear fusion', 'energy production'] },
  #     { name: 'Regolith', mass: 1.0e22, percentage: 100, uses: ['construction', 'radiation shielding'], composition: { oxygen: 42.0, sodium: 29.0, hydrogen: 22.0, helium: 6.0, potassium: 0.5, other: 0.5 } }
  #   ],
  #   'Venus' => [
  #     { name: 'Sulfuric Acid', mass: 4.38e24, percentage: 90, uses: ['chemical processing', 'fertilizers'] },
  #     { name: 'Carbon Dioxide', mass: 4.68e24, percentage: 96.5, uses: ['oxygen production', 'fuel synthesis'] }
  #   ],
  #   'Earth' => [
  #     { name: 'Water', mass: 1.4e21, percentage: 0.023, uses: ['drinking water', 'agriculture'] },
  #     { name: 'Oxygen', mass: 1.0e21, percentage: 0.017, uses: ['breathing', 'industrial processes'] },
  #     { name: 'Igneous and Metamorphic Rocks', mass: 5.67e24, percentage: 95, uses: ['construction', 'mineral extraction'] },
  #     { name: 'Shale', mass: 2.4e23, percentage: 4, uses: ['construction', 'mineral extraction'] },
  #     { name: 'Sandstone', mass: 4.5e22, percentage: 0.75, uses: ['construction', 'mineral extraction'] },
  #     { name: 'Limestone', mass: 1.5e22, percentage: 0.25, uses: ['construction', 'mineral extraction'] },
  #     { name: 'Oxygen', mass: 2.78e24, percentage: 46.6, uses: ['breathing', 'industrial processes'] },
  #     { name: 'Silicon', mass: 1.65e24, percentage: 27.7, uses: ['electronics', 'construction'] },
  #     { name: 'Aluminum', mass: 4.83e23, percentage: 8.1, uses: ['construction', 'manufacturing'] },
  #     { name: 'Iron', mass: 2.98e23, percentage: 5.0, uses: ['construction', 'manufacturing'] }
  #   ],
  #   'Moon' => [
  #     { name: 'Helium-3', mass: 7.35e18, percentage: 0.01, uses: ['nuclear fusion', 'energy production'] },
  #     { name: 'Regolith', mass: 7.35e22, percentage: 100, uses: ['construction', 'radiation shielding'], composition: { oxygen: 43.0, silicon: 21.0, magnesium: 20.0, iron: 10.0, calcium: 3.0, aluminium: 2.0, sodium: 1.0 } }
  #   ],
  #   'Mars' => [
  #     { name: 'Water Ice', mass: 1.28e21, percentage: 0.2, uses: ['drinking water', 'hydrogen fuel'] },
  #     { name: 'Carbon Dioxide', mass: 6.1e23, percentage: 95, uses: ['oxygen production', 'fuel synthesis'] },
  #     { name: 'Regolith', mass: 6.42e23, percentage: 100, uses: ['construction', 'radiation shielding'], composition: { silicon: 'unknown', oxygen: 'unknown', iron: 'unknown', magnesium: 'unknown', aluminium: 'unknown', calcium: 'unknown', potassium: 'unknown', perchlorates: 0.5 } }
  #   ],
  #   'Jupiter' => [
  #     { name: 'Hydrogen', mass: 1.71e27, percentage: 89.8, uses: ['fuel', 'energy production'] },
  #     { name: 'Helium', mass: 1.94e26, percentage: 10.2, uses: ['coolant', 'breathing mixtures'] }
  #   ],
  #   'Io' => [
  #     { name: 'Sulfur', mass: 3.57e22, percentage: 40, uses: ['chemical processing', 'fertilizers'] },
  #     { name: 'Silicon', mass: 1.79e22, percentage: 20, uses: ['electronics', 'construction'] }
  #   ],
  #   'Europa' => [
  #     { name: 'Water Ice', mass: 4.32e22, percentage: 90, uses: ['drinking water', 'hydrogen fuel'] },
  #     { name: 'Salt', mass: 4.8e21, percentage: 10, uses: ['chemical processing'] },
  #     { name: 'Silicate', mass: 2.4e21, percentage: 5, uses: ['construction', 'electronics'] }
  #   ],
  #   'Ganymede' => [
  #     { name: 'Water Ice', mass: 1.33e23, percentage: 90, uses: ['drinking water', 'hydrogen fuel'] },
  #     { name: 'Silicate', mass: 7.4e22, percentage: 5, uses: ['construction', 'electronics'] }
  #   ],
  #   'Callisto' => [
  #     { name: 'Water Ice', mass: 9.72e22, percentage: 90, uses: ['drinking water', 'hydrogen fuel'] },
  #     { name: 'Silicate', mass: 5.4e22, percentage: 5, uses: ['construction', 'electronics'] }
  #   ],
  #   'Saturn' => [
  #     { name: 'Hydrogen', mass: 5.47e26, percentage: 96.3, uses: ['fuel', 'energy production'] },
  #     { name: 'Helium', mass: 2.1e25, percentage: 3.7, uses: ['coolant', 'breathing mixtures'] }
  #   ],
  #   'Titan' => [
  #     { name: 'Methane', mass: 1.35e22, percentage: 10, uses: ['fuel', 'energy production'] },
  #     { name: 'Ethane', mass: 6.75e21, percentage: 5, uses: ['chemical feedstock'] },
  #     { name: 'Nitrogen', mass: 1.28e23, percentage: 95, uses: ['atmospheric processing', 'agriculture'] }
  #   ],
  #   'Uranus' => [
  #     { name: 'Hydrogen', mass: 7.16e25, percentage: 82.5, uses: ['fuel', 'energy production'] },
  #     { name: 'Helium', mass: 1.32e25, percentage: 15.2, uses: ['coolant', 'breathing mixtures'] },
  #     { name: 'Methane', mass: 1.99e24, percentage: 2.3, uses: ['fuel', 'chemical feedstock'] }
  #   ],
  #   'Neptune' => [
  #     { name: 'Hydrogen', mass: 8.16e25, percentage: 80, uses: ['fuel', 'energy production'] },
  #     { name: 'Helium', mass: 1.94e25, percentage: 19, uses: ['coolant', 'breathing mixtures'] },
  #     { name: 'Methane', mass: 1.02e24, percentage: 1, uses: ['fuel', 'chemical feedstock'] }
  #   ],
  #   'Triton' => [
  #     { name: 'Nitrogen', mass: 2.14e22, percentage: 99.9, uses: ['atmospheric processing', 'agriculture'] },
  #     { name: 'Methane', mass: 2.14e19, percentage: 0.1, uses: ['fuel', 'energy production'] }
  #   ],
  #   'Pluto' => [
  #     { name: 'Nitrogen', mass: 1.18e22, percentage: 90, uses: ['atmospheric processing', 'agriculture'] },
  #     { name: 'Methane', mass: 1.31e21, percentage: 10, uses: ['fuel', 'energy production'] }
  #   ],
  #   'Charon' => [
  #     { name: 'Nitrogen', mass: 1.52e21, percentage: 100, uses: ['atmospheric processing', 'agriculture'] }
  #   ],
  #   'Ceres' => [
  #     { name: 'Water Ice', mass: 4.7e20, percentage: 50, uses: ['drinking water', 'hydrogen fuel'] },
  #     { name: 'Silicate Rock', mass: 4.7e20, percentage: 50, uses: ['construction', 'electronics'] }
  #   ],
  #   'Haumea' => [
  #     { name: 'Water Ice', mass: 2.0e21, percentage: 50, uses: ['drinking water', 'hydrogen fuel'] },
  #     { name: 'Silicate Rock', mass: 2.0e21, percentage: 50, uses: ['construction', 'electronics'] }
  #   ],
  #   'Makemake' => [
  #     { name: 'Nitrogen', mass: 3.1e21, percentage: 100, uses: ['atmospheric processing', 'agriculture'] }
  #   ],
  #   'Eris' => [
  #     { name: 'Nitrogen', mass: 1.66e22, percentage: 100, uses: ['atmospheric processing', 'agriculture'] }
  #   ]
  # }

  # habitats_data = [
  #   {
  #     name: "Habitat Module A",
  #     base_materials: { steel: 150, insulation: 75 },
  #     operating_requirements: { power: 5 },
  #     input_resources: {},
  #     output_resources: {},
  #     population_capacity: 4
  #   },
  #   {
  #     name: "Habitat Module B",
  #     base_materials: { steel: 120, insulation: 60 },
  #     operating_requirements: { power: 4 },
  #     input_resources: {},
  #     output_resources: {},
  #     population_capacity: 3
  #   }
  # ]
  
  # habitats_data.each do |habitat_data|
  #   habitat = Habitat.new(
  #     habitat_data[:name],
  #     habitat_data[:base_materials],
  #     habitat_data[:operating_requirements],
  #     habitat_data[:input_resources],
  #     habitat_data[:output_resources],
  #     habitat_data[:population_capacity]
  #   )
    
  #   # Example of allocating population to the habitat
  #   habitat.allocate_population(2)  # Allocating 2 people for this example
  
  #   # Logic to save the habitat to the database can go here
  # end  
end