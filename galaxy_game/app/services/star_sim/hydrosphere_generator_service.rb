module StarSim
  class HydrosphereGeneratorService
    def initialize(celestial_body_data)
      @body_data = celestial_body_data
    end

    def generate(body_data = nil)
      body_data ||= @body_data
      hydrosphere_data = body_data[:hydrosphere] || {}

      surface_temp = body_data[:surface_temperature].to_f
      pressure = body_data.dig(:atmosphere, :pressure).to_f
      mass = body_data[:mass].to_f
      radius = body_data[:radius].to_f

      initial_water_mass = estimate_initial_water_mass(mass)

      # If atmosphere data exists, use it to determine water vapor
      atmospheric_water_percentage = body_data.dig(:atmosphere, :composition, "H2O", :percentage).to_f / 100.0
      total_atmospheric_mass = body_data.dig(:atmosphere, :total_atmospheric_mass).to_f
      atmospheric_water_mass = atmospheric_water_percentage * total_atmospheric_mass if total_atmospheric_mass > 0

      total_hydrosphere_mass = initial_water_mass + (atmospheric_water_mass || 0)

      if total_hydrosphere_mass > 0
        initial_water_temps = calculate_initial_water_temperatures(surface_temp) # Get initial temps
        hydrosphere_data[:liquid_bodies] ||= generate_water_bodies(surface_temp, pressure, total_hydrosphere_mass, radius, initial_water_temps) # Pass temps
        hydrosphere_data[:composition] ||= generate_water_composition
        hydrosphere_data[:state_distribution] ||= calculate_state_distribution(surface_temp, pressure, hydrosphere_data[:liquid_bodies])
        hydrosphere_data[:total_hydrosphere_mass] = total_hydrosphere_mass
      else
        hydrosphere_data[:liquid_bodies] = {}
        hydrosphere_data[:composition] = {}
        hydrosphere_data[:state_distribution] = {}
        hydrosphere_data[:total_hydrosphere_mass] = 0
      end

      hydrosphere_data
    end

    private

    def estimate_initial_water_mass(mass)
      # Very rough estimate based on planetary mass - larger planets can retain more volatiles
      # Fraction could be very small for rocky planets
      earth_mass = 5.972e24
      water_mass_fraction = [0.001 * (mass / earth_mass), 0.1].min # Up to 10% water by mass (highly unlikely for terrestrial)
      mass * water_mass_fraction
    end

    def calculate_initial_water_temperatures(surface_temp)
      {
        ocean_temp: calculate_initial_water_temp(surface_temp, 0.7), # Assume oceans are large
        lake_temp: calculate_initial_water_temp(surface_temp, 0.2), # Lakes smaller
        river_temp: calculate_initial_water_temp(surface_temp, 0.05), # Rivers smallest
        ice_temp: calculate_initial_water_temp(surface_temp, 0.9)
      }
    end

    def calculate_initial_water_temp(surface_temp, volume_factor)
      base_temp = surface_temp - 5
      volume_effect = Math.log(100 * volume_factor + 1) # Simulate volume effect, assume input as coverage %
      base_temp - volume_effect
    end

    def generate_liquid_bodies(surface_temp, pressure, total_hydrosphere_mass, radius, initial_water_temps)
      liquid_bodies = {}
      surface_area = 4 * Math::PI * (radius**2)
      potential_ocean_depth = (total_hydrosphere_mass / (surface_area * 1000)) # Assuming density of water is 1000 kg/m^3

      if surface_temp > 273.15 && surface_temp < boiling_point_of_water(pressure)
        ocean_coverage = [rand(0.1..0.9), 0.0].max # Percentage of surface covered by oceans
        ocean_volume = (ocean_coverage * surface_area * potential_ocean_depth * 0.7).clamp(0, 1e18) # Adjust for depth variation

        liquid_bodies[:oceans] = {
          volume: ocean_volume,
          salinity: generate_salinity,
          coverage: ocean_coverage * 100,
          temperature: initial_water_temps[:ocean_temp] # Use initial temp
        }

        lake_coverage = [(1.0 - ocean_coverage) * rand(0.01..0.1), 0.0].max
        lake_volume = lake_coverage * surface_area * (potential_ocean_depth * rand(0.01..0.1))
        liquid_bodies[:lakes] = {
          volume: lake_volume,
          salinity: generate_salinity(freshwater_bias: 0.7),
          coverage: lake_coverage * 100,
          temperature: initial_water_temps[:lake_temp]
        } if lake_volume > 1e9 # Minimum size for a significant lake
      elsif surface_temp <= 273.15
        ice_coverage = [rand(0.1..0.7), 0.0].max
        ice_thickness = potential_ocean_depth * ice_coverage * rand(0.01..0.5)
        ice_volume = ice_coverage * surface_area * ice_thickness
        liquid_bodies[:ice_caps] = {
          volume: ice_volume,
          coverage: ice_coverage * 100,
          temperature: initial_water_temps[:ice_temp]
        }
        groundwater_volume = total_hydrosphere_mass * 0.05 # Estimate
        liquid_bodies[:groundwater] = {
          volume: groundwater_volume,
          depth_range: "0-#{rand(1..5)}km"
        } if groundwater_volume > 1e15
      else # Very hot - likely little surface water
        # Could have some atmospheric water vapor already handled
      end

      if surface_temp > 273.15 && rand() < 0.3 # Chance of rivers on warmer planets
        river_length = radius * rand(0.001..0.01) # Fraction of radius
        river_volume = river_length * (rand(1e3..1e6)**2) # Cross-sectional area
        liquid_bodies[:rivers] = {
          volume: river_volume,
          total_length: river_length * 1000, # in meters
          temperature: initial_water_temps[:river_temp]
        } if river_volume > 1e9
      end

      liquid_bodies.compact
    end

    def generate_salinity(freshwater_bias: 0.1)
      if rand() < freshwater_bias
        rand(0.001..0.05) # Freshwater (ppt)
      else
        rand(1.0..4.0) # Seawater (percentage)
      end
    end

    def generate_water_composition
      composition = [{"compound": "H2O", "percentage": 97.0 + rand(-2.0..2.0)}]
      dissolved_salts_percentage = 3.0 + rand(-1.0..1.0)
      composition << {"compound": "dissolved_salts", "percentage": dissolved_salts_percentage.clamp(0.1, 5.0)}
      # Could add more trace elements later
      composition
    end

    def calculate_state_distribution(surface_temp, pressure, liquid_bodies)
      state_distribution = {}
      liquid_percentage = 0.0
      solid_percentage = 0.0
      vapor_percentage = 0.0

      total_water_volume = 0.0
      liquid_bodies.each do |type, data|
        total_water_volume += data[:volume].to_f if data.key?(:volume)
      end

      if total_water_volume > 0
        liquid_percentage = percentage_liquid(surface_temp, pressure)
        solid_percentage = percentage_frozen(surface_temp, pressure)
        vapor_percentage = percentage_vapor(surface_temp, pressure)
      end

      # Account for atmospheric water vapor if data is available
      atmospheric_water_percentage = @body_data.dig(:atmosphere, :composition, "H2O", :percentage).to_f
      vapor_percentage = [vapor_percentage + atmospheric_water_percentage * 0.1, 0.0].max # Small fraction of atm. water

      state_distribution[:liquid] = liquid_percentage.clamp(0.0, 100.0)
      state_distribution[:solid] = solid_percentage.clamp(0.0, 100.0)
      state_distribution[:vapor] = vapor_percentage.clamp(0.0, 100.0)

      state_distribution.transform_values { |v| v.round(1) }
    end

    def percentage_frozen(temp, pressure)
      return 100 if temp < 273.15
      return 0 if temp > 273.15
      50
    end

    def percentage_liquid(temp, pressure)
      return 0 if temp < 273.15 || temp > boiling_point_of_water(pressure)
      70
    end

    def percentage_vapor(temp, pressure)
      boiling_point = boiling_point_of_water(pressure)
      return 0 if temp < 273.15 || temp < boiling_point
      return 100 if temp > boiling_point
      30
    end

    def boiling_point_of_water(pressure_in_bars)
      # Simplified approximation of boiling point vs pressure
      # Standard boiling point at 1 bar is 373.15 K
      return 373.15 if pressure_in_bars <= 0.01 # Vacuum-like

      373.15 + 28 * Math.log(pressure_in_bars)
    end
  end
end
