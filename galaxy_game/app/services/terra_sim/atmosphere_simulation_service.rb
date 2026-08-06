module TerraSim
  class AtmosphereSimulationService
    GREENHOUSE_GASES = %w[CO2 CH4 N2O H2O].freeze # Use 'H2O' consistently for clarity

    def initialize(celestial_body)
      @celestial_body = celestial_body
      @sigma = 5.67e-8 # Stefan-Boltzmann constant
      @material_lookup = Lookup::MaterialLookupService.new
    end

    def simulate(days = 1)
      update_pressure
      calculate_greenhouse_effect
      update_temperatures
      simulate_atmospheric_loss
      decrease_dust(0.1)
    end

    private

    def update_pressure
      return unless @celestial_body.atmosphere.present?

      atmosphere = @celestial_body.atmosphere
      atmosphere.update_pressure_from_mass!
    end

    def calculate_greenhouse_effect
      @albedo = @celestial_body.albedo.to_f
      @solar_input = @celestial_body.solar_constant.to_f
      @base_temp = stefan_boltzmann_temp

      gather_gas_data

      @surface_temp = @base_temp
      @polar_temp = @surface_temp - 75
      @tropic_temp = @surface_temp

      100.times do
        @surface_temp = greenhouse_adjusted_temp
        @polar_temp = @surface_temp - (75 / (1 + total_pressure))
      end

      @celestial_body.update(surface_temperature: @surface_temp)
    end

    def stefan_boltzmann_temp
      ((1 - @albedo) * @solar_input / (4 * @sigma))**0.25
    end

    def gather_gas_data
      atmosphere = @celestial_body.atmosphere
      @gases = {}

      GREENHOUSE_GASES.each do |gas|
        material = @material_lookup.find_material(gas)
        gas_mass = atmosphere.gases.find_by(name: gas)&.mass || 0
        molar_mass = material ? material["molar_mass"] : 0

        @gases[gas] = { mass: gas_mass, molar_mass: molar_mass }
      end
    end

    def greenhouse_adjusted_temp
      water_effect = water_vapor_pressure**0.3
      co2_effect   = @gases['CO2'][:mass]**0.3
      ch4_effect   = @gases['CH4'][:mass]**0.3

      greenhouse_temp = (@base_temp * (1 + co2_effect + water_effect + ch4_effect)**0.25)
      
      # Cap greenhouse effect at 2x base temperature
      [greenhouse_temp, 2.0 * @base_temp].min
    end

    def water_vapor_pressure
      rh = 0.7
      r = 8.314
      l_heat = 43655.0
      p0 = 1.4e6
      rh * p0 * Math.exp(-l_heat / (r * @surface_temp))
    end

    def total_pressure
      # Get the actual pressure from the atmosphere model
      @celestial_body.atmosphere.pressure
    end

    def update_temperatures
      atmosphere = @celestial_body.atmosphere
      return unless atmosphere

      # Clamp temperatures to valid ranges before updating
      clamped_base_temp    = @base_temp.clamp(150.0, 400.0)
      clamped_surface_temp = @surface_temp.clamp(150.0, 400.0)
      clamped_polar_temp   = @polar_temp.clamp(100.0, 350.0)
      clamped_tropic_temp  = @tropic_temp.clamp(150.0, 400.0)

      # Update the various temperature types using clamped values
      atmosphere.set_effective_temp(clamped_base_temp)
      atmosphere.set_greenhouse_temp(clamped_surface_temp)
      atmosphere.set_polar_temp(clamped_polar_temp)
      atmosphere.set_tropic_temp(clamped_tropic_temp)

      # Also update the celestial body's surface temperature
      @celestial_body.update(surface_temperature: clamped_surface_temp)
    end

    def simulate_atmospheric_loss
      atmosphere = @celestial_body.atmosphere
      return unless atmosphere.present?

      loss_factor = calculate_solar_wind_factor
      return if loss_factor <= 0.00001 # No meaningful loss with magnetosphere active

      # Apply loss per-gas, adjusted by molecular mass / escape velocity
      atmosphere.gases.each do |gas|
        next if gas.mass.nil? || gas.mass <= 0

        gas_mass_factor = molecular_mass_factor(gas.name)
        adjusted_loss_rate = loss_factor * gas_mass_factor

        new_mass = [gas.mass - gas.mass * adjusted_loss_rate, 0].max
        # Use mass_frozen to avoid float precision issues with very large numbers
        gas.update_columns(mass: new_mass)
      end

      # After updating all gas masses, update total_atmospheric_mass directly.
      # CRITICAL: Must use update_columns (not save!/recalculate_mass!) to avoid triggering
      # after_save callbacks on Atmosphere model. Those callbacks call update_pressure_from_mass!
      # which recalculates pressure via material lookup — this interferes with test environments
      # and can corrupt gas state during simulation cycles. Pressure will be recalculated on the
      # next natural simulate() cycle when called from GeosphereSimulationService.
      new_total = atmosphere.gases.sum(:mass)
      atmosphere.update_columns(total_atmospheric_mass: new_total)
    end

    def calculate_solar_wind_factor
      # Nearly zero loss with magnetosphere protection
      return 0.00001 if @celestial_body.has_magnetosphere

      # Calculate base solar wind intensity from stellar distance
      # StarDistance stores distance in meters; convert to km
      star_distance_m = @celestial_body.star_distances&.first&.distance
      return 0.0001 if star_distance_m.nil? || star_distance_m <= 0

      star_distance_km = star_distance_m / 1000.0

      # Reference: Earth distance from Sol ≈ 149.6M km (1 AU)
      au_to_km = 149_600_000.0
      earth_distance_km = au_to_km

      # Inverse square law for solar wind intensity
      # intensity_ratio = (earth_distance / actual_distance)²
      intensity_ratio = (earth_distance_km / star_distance_km.to_f) ** 2

      # Base loss rate at Earth distance with no magnetosphere: ~0.01% per step
      base_loss_rate = 0.0001

      intensity_ratio * base_loss_rate
    end

    def molecular_mass_factor(gas_name)
      # Relative escape rates based on molecular mass
      # H₂ escapes fastest, CO₂ escapes slowest
      # Factors relative to a baseline (CO₂ = 1.0)
      factors = {
        'H2' => 5.0,   # Hydrogen: very light, escapes 5x faster than CO₂
        'He' => 3.5,   # Helium: light noble gas
        'N2' => 1.2,   # Nitrogen: lighter than CO₂
        'O2' => 1.1,   # Oxygen: slightly lighter than CO₂
        'Ar' => 0.9,   # Argon: slightly heavier than CO₂
        'CO2' => 1.0,  # Carbon dioxide: baseline
        'H2O' => 0.8,  # Water vapor: heavier, escapes slower
        'CH4' => 1.15  # Methane: between N₂ and CO₂
      }

      factors.fetch(gas_name, 1.0) # Default to 1.0 (CO₂-like) if unknown
    end

    def decrease_dust(amount)
      @celestial_body.atmosphere.decrease_dust(amount)
    end
  end
end
