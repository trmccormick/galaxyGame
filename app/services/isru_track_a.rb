# frozen_string_literal: true

require_relative '../poro'

class IsruTrackA < PORO
  include Concerns::IsruConcern
  
  attr_reader :operational_data
  
  def initialize(buffer = nil, operational_data: {})
    @buffer = buffer || RawGasBuffer.new(operational_data: operational_data)
    @operational_data = operational_data
    super()
  end
  
  # Process regolith using TEU + PVE chain for Luna surface
  def process_regolith(regolith_sample)
    # Step 1: TEU bakes out loose volatiles at high temperature (~700°C)
    volatile_output = teu_units.process(@operational_data[:teu_units])
    
    # Step 2: PVE liberates oxygen from remaining oxides
    oxygen_output = pve_units.extract_from_volatile(volatile_output, @operational_data[:pve_units])
    
    # Step 3: Dump all processed volatiles into centralized RAW Gas tank buffer
    @buffer.add_volatiles(volatile_output.merge(oxygen_output))
    
    # Step 4: Flag depleted regolith slag for 3D sintering fabricator use
    return { 
      slag: volatile_output[:slag], 
      status: :processed,
      water_content_kg: oxygen_output[:water_content_kg]
    }
  end
  
  def self.deploy_units(isru_units)
    # Deploy TEU and PVE units to lunar surface regolith sites
    isru_units.teu_units.map do |unit|
      UnitManager.create!(class_name: 'TelemetryEnabledUnit', 
                         location_data: { type: :luna_surface, coordinates: unit[:coordinates] },
                         operational_data: unit)
    end +
    isru_units.pve_units.map do |unit|
      UnitManager.create!(class_name: 'PhaseVariableExcavator', 
                         location_data: { type: :luna_surface, coordinates: unit[:coordinates] },
                         operational_data: unit)
    end
  end
  
  def self.is_available?
    # Check if TEU/PVE units are available for deployment
    POROSpace::IsruConcern::ISRU_POOL.keys.include?(:tea) && 
    POROSpace::IsruConcern::ISRU_POOL.keys.include?(:pve)
  end
end

class RawGasBuffer < PORO
  attr_reader :operational_data
  
  def initialize(operational_data: {})
    @operational_data = operational_data
    super()
  end
  
  # Accumulate volatiles from both tracks, track capacity
  def add_volatiles(volatile_data)
    # Merge incoming volatiles into buffer
    self.volatiles.merge!(volatile_data)
    
    # Update pressure/temperature states based on total gas mass
    @operational_data[:pressure] = compute_pressure(@volatiles.to_a.sum)
    @operational_data[:temperature] = @volatiles.to_a.sum * 0.15 + 273
    
    # Log to operational data for tracking
    log_operation("Gas volume added: #{@volatiles.to_a.sum} kg, " \
                  "Pressure: #{@operational_data[:pressure]} bar", 
                  category: :gas_management)
    
    true
  end
  
  def fractional_distillation
    # Separate gases based on boiling points
    distillate = separate_by_boiling_point(@volatiles)
    
    # Store each gas fraction in tank farm locations
    store_each_gas(distillate, @operational_data[:tank_farm])
    
    @distillate
  end
  
  def self.reset_pressure(operational_data)
    operational_data[:pressure] = 0.1
  end
end

class TankFarmSystem < PORO
  attr_reader :type, :operational_data
  
  # Location strategy: Pad farms near landing pads for flight fuels
  def initialize(type: :pad, operational_data: {})
    @type = type
    @operational_data = operational_data
    super()
  end
  
  def location_data
    if @type == :pad
      { 
        coordinates: "near_landing_pads", 
        purpose: "flight_fuels",
        capacity: 50_000 # kg for flight fuels (LOX, Methane, Hydrolox stack)
      }
    else
      { 
        coordinates: "inside_structural_tubes", 
        purpose: "habitability_atmosphere",
        capacity: 10_000 # kg for atmosphere buffers
      }
    end
  end
  
  def stock_types
    if @type == :pad
      # Flight fuels: LOX, Methane, Hydrolox stack for return craft refuel
      [:lox, :methane, :hydrolox]
    else
      # Habitation atmosphere buffers (Earth-imported N2 as initial supply)
      [:n2, :o2, :argon]
    end
  end
  
  def self.deploy_pad_farm
    TankFarmSystem.new(type: :pad).tap do |farm|
      farm.operational_data[:deployment_status] = :active
      farm.operational_data[:location] = farm.location_data[:coordinates]
    end
  end
  
  def self.deploy_lava_tube_farm
    TankFarmSystem.new(type: :tube).tap do |farm|
      farm.operational_data[:deployment_status] = :active
      farm.operational_data[:location] = farm.location_data[:coordinates]
    end
  end
end

class LavaTubeAtmosphericHarvester < PORO
  attr_reader :skylight_coverage_ratio, :initial_pressure
  
  def initialize(skyight_coverage_ratio: 0.95, initial_pressure: 0.1, operational_data: {})
    @skylight_coverage_ratio = skyight_coverage_ratio
    @initial_pressure = initial_pressure
    @operational_data = operational_data
    super()
  end
  
  # Simulate passive pressure buildup from micro-losses and airlock cycles
  def current_pressure
    # Passive accumulation logic: small gains from Skylight coverage, losses from leaks
    pressure_change = (@skylight_coverage_ratio - 1.0) * 0.02
    @current_pressure = [@initial_pressure + (@operational_data[:cycle_count] * pressure_change), 0].max
  end
  
  def simulate_passive_buildup(cycles)
    @operational_data[:cycle_count] += cycles
    current_pressure
  end
  
  # Strict gating: only deploy harvesters when tube pressure exceeds threshold
  def can_deploy_harvesters?
    current_pressure >= MIN_PRESSURE_FOR_HARVEST
  end
  
  def self.minimum_pressure_for_extraction
    0.25 # Bar - minimum pressure needed for efficient extraction
  end
  
  MIN_PRESSURE_FOR_HARVEST = minimum_pressure_for_extraction
end