# config/initializers/game_constants.rb
module GameConstants
  # People constants
  FOOD_PER_PERSON = 2
  WATER_PER_PERSON = 1
  ENERGY_PER_PERSON = 3
  MIN_RESOURCE_THRESHOLD = 0.8
  STARVATION_THRESHOLD = 0.5
  MORALE_DECLINE_RATE = 0.05
  DEATH_RATE = 0.1

  # Physics constants
  IDEAL_GAS_CONSTANT = 8.31446 # J/(mol·K) - SI units for scientific calculations
  IDEAL_GAS_CONSTANT_L_ATM = 0.0821 # L·atm/(mol·K) - Alternative units for some calculations
  STEFAN_BOLTZMANN_CONSTANT = 5.67e-8 # W/(m²·K⁴)
  GRAVITATIONAL_CONSTANT = 6.674e-11 # N·m²/kg²

  GCC_TO_USD_INITIAL = 1.0 # 1.0 USD per Galactic Credit Coin aka Galactic Crypto Currency (GCC) initially
  INITIAL_TRANSPORTATION_COST_PER_KG = 1320.00 # 1320.00 USD per kg

  DEFAULT_TEMPERATURE = 288.15 # Kelvin

  # Default Earth-like values have been moved to the EARTH_ATMOSPHERE constant below
  # Note: If you need the old format, use EARTH_ATMOSPHERE[:composition]

  # Earth-like pressure in Pascals
  EARTH_PRESSURE = 101325

  # Maximum number of wormholes per solar system
  MAX_WORMHOLES_PER_SYSTEM = 3
  
  # Probabilities for wormhole generation
  NEW_SYSTEM_PROBABILITY = 0.4  # 40% chance
  NEW_GALAXY_PROBABILITY = 0.2  # 20% chance

  # Constants for spatial constraints
  SAFE_DISTANCE_FROM_STAR = 1.496e8 # 1 AU in meters
  MAX_DISTANCE_FROM_STAR = 1.496e10 # 100 AU in meters  

  # Wormhole Generation
  WORMHOLE_GENERATION_INTERVAL = 24.hours
  WORMHOLE_MAINTENANCE_INTERVAL = 1.hour
  WORMHOLE_GENERATION_CHANCE = 0.3 # 30% chance per eligible system
  MAX_NEW_WORMHOLES_PER_CYCLE = 5
  WORMHOLE_MAX_AGE = 30.days

  # Wormhole constants
  MIN_STABILIZERS_REQUIRED = 2
  # MAX_DISTANCE_FROM_STAR = 1000.0
  STABILIZER_EFFECTIVE_RANGE = 100.0 # Distance in spatial units that a stabilizer can affect a wormhole
  MIN_STABILIZER_POWER = 25 # Minimum power level for a stabilizer to be considered operational

  # Physical constants
  STANDARD_TEMPERATURE = 293.15 # K (20°C)
  STANDARD_PRESSURE_PA = 101325 # Pa (1 atm)
  STANDARD_PRESSURE_ATM = 1.0 # atm
  STANDARD_PRESSURE_KPA = 101.3 # kPa

  # Atmospheric constants - consolidated Earth atmosphere data
  EARTH_ATMOSPHERE = {
    # Detailed composition with metadata (for planet generation)
    composition: {
      'N2' => { percentage: 78.08, common_name: 'Nitrogen' },
      'O2' => { percentage: 20.95, common_name: 'Oxygen' },
      'Ar' => { percentage: 0.93, common_name: 'Argon' },
      'CO2' => { percentage: 0.04, common_name: 'Carbon Dioxide' },
      'H2O' => { percentage: 0.25, common_name: 'Water Vapor', variable: true }
    },
    
    # Simplified mix (for engineering calculations)
    simplified_mix: { 
      'N2' => 0.78, 
      'O2' => 0.21, 
      'Ar' => 0.01 
    },
    
    # Breathability parameters
    breathable: {
      min_oxygen_percentage: 19.5,
      max_oxygen_percentage: 23.5,
      max_co2_percentage: 0.5,
      max_co_percentage: 0.0035
    },
    
    # Physical parameters
    pressure: 101325, # Pa
    mass: 5.15e18,    # kg
    scale_height: 8.5,  # km
    
    # Average gas constant for Earth's atmosphere
    average_gas_constant: 287.05 # J/(kg·K)
  }.freeze

  # Greenhouse gas factors (only special properties not in material data)
  GREENHOUSE_FACTORS = {
    'CO2' => 20.0,
    'CH4' => 25.0,
    'N2O' => 298.0,
    'H2O' => 12.0,
    'O3' => 2000.0
  }.freeze

  # Human life support requirements
  HUMAN_LIFE_SUPPORT = {
    'oxygen_per_person_day' => 0.84, # kg of O2 per day
    'co2_produced_per_person_day' => 1.0, # kg of CO2 per day
    'water_per_person_day' => 2.5, # L per day (drinking only)
    'total_water_per_person_day' => 50.0, # L per day (all uses)
    'min_pressure_for_survival' => 33.0, # kPa (minimum pressure without pressure suit)
    'min_oxygen_partial_pressure' => 16.0, # kPa
    'max_co2_partial_pressure' => 1.0, # kPa (long-term exposure limit)
    'emergency_co2_limit' => 4.0, # kPa (short-term emergency limit)
    'temperature_min' => 283.15, # K (10°C)
    'temperature_max' => 303.15, # K (30°C)
    'temperature_optimal' => 294.15 # K (21°C)
  }.freeze

  # Storage related constants
  STORAGE_WORKERS_RATIO = 0.1  # 10% of population can work on storage
  STORAGE_CAPACITY_PER_WORKER = 1000  # kg per worker  

  # Construction cost percentage
  DEFAULT_CONSTRUCTION_PERCENTAGE = 10.0

  # Craft volume constants
  DEFAULT_VOLUME_PER_CREW_M3 = 15.0 # m³ per crew member for habitable volume

  # Earth reference values
  module Earth
    RADIUS = 6371.0  # km
    GRAVITY = 9.8    # m/s²
    MASS = 5.972e24  # kg
    ATMOSPHERIC_DENSITY = 1.0  # relative value
    AXIAL_TILT = 23.5  # degrees
  end
  
  # BiosphereSimulation constants - now baseline values
  BIOSPHERE_SIMULATION = {
    plant_growth_factor: 0.1,               # Base growth rate for plants
    biome_moisture_adjustment_rate: 0.01,   # How quickly moisture levels change
    biome_area_adjustment_rate: 0.05,       # How quickly biome areas change
    temperature_adjustment_rate: 0.1,       # How quickly tropical temperatures change
    polar_adjustment_factor: 0.5,           # Polar regions change slower (0.5x the tropical rate)
    max_biomes: 10,                         # Maximum number of biomes for biodiversity calculation
    temperature_suitability_falloff: 20.0   # Temperature distance where suitability reaches zero
  }.freeze

  # AI Priority System Configuration
  # Adjustable priorities for AI behavior tuning during testing phases
  AI_PRIORITIES = {
    critical: {
      life_support: 1000,
      atmospheric_maintenance: 900,
      debt_repayment: 800
    },
    operational: {
      resource_procurement: 500,
      construction: 300,
      expansion: 100
    }
  }

  # Default priority multipliers for testing adjustments
  AI_PRIORITY_MULTIPLIERS = {
    critical: 1.0,
    operational: 1.0
  }
end