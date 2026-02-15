module TerraSim
  class AtmosphereSimulationService
    GREENHOUSE_GASES = %w[CO2 CH4 N2O H2O].freeze # Use 'H2O' consistently for clarity

    def initialize(celestial_body)
      @celestial_body = celestial_body
      @sigma = 5.67e-8 # Stefan-Boltzmann constant
      @material_lookup = Lookup::MaterialLookupService.new
    end

    def simulate
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
      
      # Update the various temperature types using our new methods
      atmosphere.set_effective_temp(@base_temp)
      atmosphere.set_greenhouse_temp(@surface_temp)
      atmosphere.set_polar_temp(@polar_temp)
      atmosphere.set_tropic_temp(@tropic_temp)
      
      # Also update the celestial body's surface temperature
      @celestial_body.update(surface_temperature: @surface_temp)
    end

    def simulate_atmospheric_loss
      atmosphere = @celestial_body.atmosphere
      return unless atmosphere.present?

      loss_factor = calculate_solar_wind_factor

      atmosphere.gases.each do |gas|
        new_mass = [gas.mass - gas.mass * loss_factor, 0].max
        gas.update(mass: new_mass)
      end

      atmosphere.recalculate_mass!
      atmosphere.update_pressure_from_mass!
    end

    def calculate_solar_wind_factor
      # Placeholder for future magnetic field-based formula
      0.0001
    end

    def decrease_dust(amount)
      @celestial_body.atmosphere.decrease_dust(amount)
    end
  end
end
