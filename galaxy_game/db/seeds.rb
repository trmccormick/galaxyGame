# Method to calculate gravity based on mass and radius
def calculate_gravity(mass, radius)
  gravitational_constant = 6.67430e-11 # in m^3 kg^-1 s^-2
  radius_in_meters = radius * 1000 # Convert km to meters
  (gravitational_constant * mass) / (radius_in_meters ** 2)
end

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
def create_celestial_body(name:, mass:, radius:, density:, distance_from_sun:, size:, orbital_period:, gravity: nil, gas_quantities: {}, materials: {}, total_atmospheric_mass: 0, known_pressure: nil)
  # Ensure gas_quantities and materials are hashes
  gas_quantities = JSON.parse(gas_quantities || '{}') if gas_quantities.is_a?(String)
  materials = JSON.parse(materials || '{}') if materials.is_a?(String)

  # Calculate gas quantities in actual mass values
  actual_gas_quantities = gas_quantities.transform_values do |percentage|
    calculate_gas_mass(percentage, total_atmospheric_mass)
  end

  # Calculate gravity if not provided
  calculated_gravity = gravity || calculate_gravity(mass, radius)

  # Create the celestial body with all attributes including known_pressure
  CelestialBody.create!(
    name: name,
    mass: mass,
    radius: radius,
    density: density,
    distance_from_sun: distance_from_sun,
    size: size,
    orbital_period: orbital_period,
    gravity: calculated_gravity,
    gas_quantities: actual_gas_quantities.to_json,
    materials: materials.to_json,
    known_pressure: known_pressure
  )
end

# Create Celestial Bodies with total atmospheric mass estimation
celestial_bodies = [
  {
    name: 'Mercury',
    mass: 3.30e23, # in kg
    radius: 2.44e6, # in meters
    density: 5.427, # in g/cm^3
    distance_from_sun: 5.79e7, # in km
    size: 0.3829, # Relative to Earth (Earth = 1.0)
    orbital_period: 87.97, # in Earth days    
    gas_quantities: {},
    materials: { iron: 35.0, nickel: 10.0 }
  },
  {
    name: 'Venus',
    mass: 4.87e24,
    radius: 6.05e6,
    density: 5.243,
    distance_from_sun: 1.08e8,
    size: 0.9499,
    orbital_period: 224.7,    
    gas_quantities: { CO2: 96.5, N2: 3.5 },
    known_pressure: 92.0, # in atm
    materials: { sulfur: 15.0, carbon: 30.0 },
    total_atmospheric_mass: 4.8e20 # in kg (approximation)
  },
  {
    name: 'Earth',
    mass: 5.97e24,
    radius: 6.37e6,
    density: 5.514,
    distance_from_sun: 1.496e8,
    size: 1.0,
    orbital_period: 365.25,    
    gas_quantities: { N2: 78.08, O2: 20.95, Ar: 0.93, CO2: 0.04 },
    known_pressure: 1.000, # in atm
    materials: { iron: 5.0, aluminum: 8.0, silicon: 28.0 },
    total_atmospheric_mass: 5.1e18 # in kg (approximation)
  },
  {
    name: 'Mars',
    mass: 6.42e23,
    radius: 3.39e6,
    density: 3.9335,
    distance_from_sun: 2.279e8,
    size: 0.5320,
    orbital_period: 686.98,
    gas_quantities: { CO2: 95.32, N2: 2.7, Ar: 1.6, O2: 0.13 },
    known_pressure: 0.006, # in atm
    materials: { iron: 14.0, silicon: 21.0, magnesium: 8.0 },
    total_atmospheric_mass: 2.5e16 # in kg (approximation)
  },
  {
    name: 'Jupiter',
    mass: 1.90e27,
    radius: 6.99e7,
    density: 1.326,
    distance_from_sun: 7.785e8,
    size: 11.209,
    orbital_period: 4331,
    gas_quantities: { H2: 89.8, He: 10.2 },
    materials: { hydrogen: 70.0, helium: 28.0 },
    total_atmospheric_mass: 1.9e27 # in kg (approximation)
  },
  {
    name: 'Saturn',
    mass: 5.68e26,
    radius: 5.82e7,
    density: 0.687,
    distance_from_sun: 1.433e9,
    size: 9.449,
    orbital_period: 10747,
    gas_quantities: { H2: 96.3, He: 3.7 },
    materials: { hydrogen: 75.0, helium: 24.0 },
    total_atmospheric_mass: 1.2e27 # in kg (approximation)
  },
  {
    name: 'Uranus',
    mass: 8.68e25,
    radius: 2.54e7,
    density: 1.27,
    distance_from_sun: 2.872e9,
    size: 4.007,
    orbital_period: 30589,
    gas_quantities: { H2: 82.5, He: 15.2, CH4: 2.3 },
    materials: { methane: 1.5, ammonia: 0.1 },
    total_atmospheric_mass: 8.0e24 # in kg (approximation)
  },
  {
    name: 'Neptune',
    mass: 1.02e26,
    radius: 2.46e7,
    density: 1.638,
    distance_from_sun: 4.495e9,
    size: 3.883,
    orbital_period: 59800,
    gas_quantities: { H2: 80.0, He: 19.0, CH4: 1.5 },
    materials: { methane: 2.0, ammonia: 0.5 },
    total_atmospheric_mass: 7.6e24 # in kg (approximation)
  },
  {
    name: 'Pluto',
    mass: 1.31e22,
    radius: 1.19e6,
    density: 1.854,
    distance_from_sun: 5.906e9,
    size: 0.1868,
    orbital_period: 90560,
    gas_quantities: { N2: 90.0, CH4: 9.0, CO: 1.0 },
    materials: { nitrogen: 30.0, methane: 50.0 },
    total_atmospheric_mass: 1.3e15 # in kg (approximation)
  },
  {
    name: 'Moon',
    mass: 7.35e22,
    radius: 1.74e6,
    density: 3.344,
    distance_from_sun: 1.496e8, # Approximate same distance from the sun as Earth
    size: 0.273,
    orbital_period: 27.32,
    gas_quantities: {},
    materials: { silicon: 22.0, iron: 13.0 }
  },
  {
    name: 'Europa',
    mass: 4.8e22,
    radius: 1.56e6,
    density: 3.013,
    distance_from_sun: 7.785e8, # Approximate same distance from the sun as Jupiter
    size: 0.245,
    orbital_period: 3.55,
    gas_quantities: {},
    materials: { water_ice: 100.0, silicate_rock: 30.0 }
  },
  {
    name: 'Titan',
    mass: 1.345e23,
    radius: 2.575e6,
    density: 1.88,
    distance_from_sun: 1.433e9, # Approximate same distance from the sun as Saturn
    size: 0.400,
    orbital_period: 15.95,
    gas_quantities: { N2: 95.0, CH4: 5.0 },
    known_pressure: 1.5, # in atm
    materials: { methane: 95.0, ethane: 5.0 }
  },
  {
    name: 'Ceres',
    mass: 9.39e20,
    radius: 4.73e5,
    density: 2.09,
    distance_from_sun: 4.14e8,
    size: 0.148,
    orbital_period: 1680,
    gas_quantities: {},
    materials: { water_ice: 30.0, silicate_rock: 70.0 }
  }
]

# Create celestial bodies with respective attributes
celestial_bodies.each do |body|
  create_celestial_body(
    name: body[:name],
    mass: body[:mass],
    radius: body[:radius],
    density: body[:density],
    distance_from_sun: body[:distance_from_sun],
    size: body[:size],
    orbital_period: body[:orbital_period],
    gravity: body[:gravity],
    gas_quantities: body[:gas_quantities],
    materials: body[:materials],
    total_atmospheric_mass: body[:total_atmospheric_mass],
    known_pressure: body[:known_pressure]
  )

# Units with material requirements
Unit.create!(
  name: 'Solar Panel',
  unit_type: 'energy',
  capacity: 500,
  energy_cost: 0,
  production_rate: 50,
  material_list: {
    "silicon" => 10,
    "aluminum" => 5,
    "copper" => 2
  },
  location: mars
)

Unit.create!(
  name: 'Smelter',
  unit_type: 'production',
  capacity: 100,
  energy_cost: 200,
  production_rate: 10,
  material_list: {
    "iron_ore" => 20,
    "carbon" => 5,
    "steel" => 5
  },
  location: moon_outpost
)

Unit.create!(
  name: 'Atmospheric Processor',
  unit_type: 'atmosphere',
  capacity: 300,
  energy_cost: 150,
  production_rate: 20,
  material_list: {
    "titanium" => 15,
    "steel" => 10,
    "silicon" => 5
  },
  location: mars
)
end
