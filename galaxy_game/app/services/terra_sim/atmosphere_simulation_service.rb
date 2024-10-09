module TerraSim
  class AtmosphereSimulationService
    GREENHOUSE_GASES = %w[CO2 CH4 N2O Water].freeze # Consistent naming of water vapor

    def initialize(celestial_body)
      @celestial_body = celestial_body
      @sigma = 0.0000000567  # Stefan-Boltzmann constant
      @material_lookup = MaterialLookupService.new # Initialize the lookup service
    end

    def simulate
      update_pressure
      calculate_greenhouse_effect
      update_temperatures
      # Call the biosphere simulation here if needed, but keeping them separate

      decrease_dust(0.1) # Decrease dust concentration by a fixed amount
    end

    private

    def update_pressure
      return unless @celestial_body.atmosphere.present? && @celestial_body.surface_temperature.present?

      atmosphere = @celestial_body.atmosphere
      new_pressure = atmosphere.calculate_pressure(@celestial_body.surface_temperature)
      atmosphere.update(pressure: new_pressure)
    end

    def calculate_greenhouse_effect
      @a = @celestial_body.albedo.to_f
      @sm = @celestial_body.solar_constant.to_f

      # Retrieve gas quantities from atmosphere
      atmosphere = @celestial_body.atmosphere
      gas_values = {}
      GREENHOUSE_GASES.each do |gas|
        gas_info = @material_lookup.find_material(gas) # Look up gas material info
        gas_values[gas] = @atmosphere.gases[gas] || 0 # Use 0 if the gas is not present
        gas_values["#{gas}_molar_mass"] = gas_info ? gas_info['molar_mass'] : 0 # Fetch molar mass
      end

      @p_co2 = gas_values['CO2']
      @p_ch4 = gas_values['CH4']
      @p_water_vapor = gas_values['Water'] # Using 'water_vapor' consistently
      @pr = gas_values['N2']

      # Calculate the greenhouse effect
      @tb = ((1 - @a) * @sm / (4 * @sigma))**0.25 # Blackbody temperature
      @ts = @tb # Initial surface temperature
      @tp = @ts - 75 # Initial atmospheric temperature profile
      @tt = @ts # Initialize temperature state

      # Iterate to simulate greenhouse warming effects
      100.times do
        t_water_vapor = p_h2o**0.3 # Water vapor effect
        t_co2 = @p_co2**0.3 # CO2 effect
        t_ch4 = @p_ch4**0.3 # Methane effect
        p_tot_value = p_tot # Total pressure from all gases

        # Recalculate surface temperature based on gas effects
        @ts = (((1 - @a) * @sm) / (4 * @sigma))**0.25 * 
              ((1 + t_co2 + t_water_vapor + t_ch4)**0.25)

        # Update atmospheric temperature based on surface temp and total gas pressure
        @tp = @ts - (75 / (1 + p_tot_value))
      end

      # Log or update the celestial body with the new temperature
      @celestial_body.update(surface_temperature: @ts)
    end

    def p_h2o
      rh = 0.7
      rgas = 8.314
      lheat = 43655.0
      p0 = 1.4E6
      rh * p0 * Math.exp(-lheat / (rgas * @ts)) # Water vapor pressure calculation
    end

    def p_tot
      @p_co2 + @pr + @p_ch4 + p_h2o # Total pressure including calculated water vapor pressure
    end

    def t_co2
      0.9 * p_tot**0.45 * @p_co2**0.11
    end

    def update_temperatures
      # Any additional temperature updates that may be necessary
      # This can be called after greenhouse effect calculations if needed
      @celestial_body.set_effective_temp(@tb)
      @celestial_body.set_greenhouse_temp(@ts)
      @celestial_body.set_polar_temp(@tp)
      @celestial_body.set_tropic_temp(@tt)
    end

    def decrease_dust(amount)
      atmosphere = @celestial_body.atmosphere
      atmosphere.dust ||= { concentration: 0.0, properties: "Mainly composed of silicates and sulfates." }
      atmosphere.dust['concentration'] -= amount
      atmosphere.dust['concentration'] = 0.0 if atmosphere.dust['concentration'] < 0.0
      atmosphere.save!
    end
  end
end




  