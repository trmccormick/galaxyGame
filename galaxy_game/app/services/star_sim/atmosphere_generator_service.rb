module StarSim
  class AtmosphereGeneratorService
    GREENHOUSE_GASES = %w[CO2 H2O CH4 N2O].freeze # Consistent use of 'H2O'

    def initialize(celestial_body_data, material_lookup_service)
      @body_data = celestial_body_data
      @material_lookup = material_lookup_service
      @gravitational_constant = GameConstants::GRAVITATIONAL_CONSTANT
      @stefan_boltzmann_constant = 5.67e-8
    end

    def generate_composition_for_body(name, surface_temp_override, mass, radius, orbital_distance, stellar_type = nil, has_magnetic_field = false)
      surface_temp = surface_temp_override || estimate_initial_surface_temperature(orbital_distance, stellar_type, @body_data[:albedo].to_f)
      composition = generate_initial_gas_mix(mass, surface_temp, @body_data.dig(:geosphere_attributes, :volatile_content)&.to_sym)

      geosphere_activity = @body_data.dig(:geosphere_attributes, :geological_activity).to_f
      composition = add_volcanic_gases(composition, geosphere_activity, surface_temp)

      populate_molar_mass(composition)

      total_atmospheric_mass = estimate_total_atmospheric_mass(mass, radius, composition)
      pressure = calculate_pressure(mass, radius, total_atmospheric_mass).round(4)
      composition["pressure"] = pressure

      refined_surface_temp = greenhouse_adjusted_temp(surface_temp, composition).round(2)
      @body_data[:surface_temperature] = refined_surface_temp # Update for other services

      composition = model_atmospheric_escape(composition, mass, radius, refined_surface_temp, stellar_type, has_magnetic_field)

      initial_dust = calculate_initial_dust(geosphere_activity)
      composition["dust"] = {"concentration" => initial_dust.round(4), "properties" => "Generated dust"} if initial_dust > 0

      calculate_percentage_composition(composition)
    end

    private

    def estimate_initial_surface_temperature(orbital_distance, stellar_type, albedo)
      solar_constant = calculate_solar_constant(orbital_distance, stellar_type)
      stefan_boltzmann_temp(albedo, solar_constant)
    end

    def generate_initial_gas_mix(mass, surface_temp, volatile_content)
      composition = {}
      # Base elements based on typical planetary formation
      composition["N2"] = {"percentage" => rand(10.0..70.0)}
      composition["CO2"] = {"percentage" => rand(5.0..50.0)}
      composition["Ar"] = {"percentage" => rand(0.1..5.0)}

      # Water vapor depends heavily on temperature and volatile content
      if surface_temp > 273.15 && volatile_content != :low
        composition["H2O"] = {"percentage" => rand(0.1..10.0)}
      end

      # Lighter gases more likely on larger, colder, outer planets with high volatiles
      if mass > 5 && surface_temp < 200 && (volatile_content == :high || volatile_content == :very_high)
        composition["CH4"] = {"percentage" => rand(1.0..20.0)}
        composition["H2"] = {"percentage" => rand(0.1..5.0)}
        composition["He"] = {"percentage" => rand(0.01..1.0)}
      elsif mass > 1 && surface_temp < 250 && volatile_content == :high
        composition["CH4"] = {"percentage" => rand(0.1..5.0)}
      end

      composition
    end

    def add_volcanic_gases(composition, geosphere_activity, surface_temp)
      scale = geosphere_activity / 100.0
      if scale > 0
        composition["CO2"] = {"percentage" => (composition["CO2"]&.[]("percentage").to_f + rand(0.1..5.0) * scale).round(4)}
        composition["SO2"] = {"percentage" => (composition["SO2"]&.[]("percentage").to_f + rand(0.01..1.0) * scale).round(4)} if surface_temp > 300
        composition["H2S"] = {"percentage" => (composition["H2S"]&.[]("percentage").to_f + rand(0.001..0.1) * scale).round(4)} if surface_temp > 350
        composition["N2"] = {"percentage" => (composition["N2"]&.[]("percentage").to_f + rand(0.05..2.0) * scale).round(4)}
        composition["H2O"] = {"percentage" => (composition["H2O"]&.[]("percentage").to_f + rand(0.1..3.0) * scale).round(4)} if surface_temp > 273
      end
      composition
    end

    def populate_molar_mass(composition)
      composition.each do |gas_formula, properties|
        material = @material_lookup.find_material(gas_formula)
        if material && material["properties"] && material["properties"]["molar_mass"]
          properties["molar_mass"] = material["properties"]["molar_mass"]
        else
          Rails.logger.warn "Molar mass not found for gas: #{gas_formula}"
        end
      end
    end

    def estimate_total_atmospheric_mass(mass, radius, composition)
      # More sophisticated model based on volatile content and retention
      # This is still a simplified estimate based on mass and potential volatile abundance
      volatile_factor = case @body_data.dig(:geosphere_attributes, :volatile_content)&.to_sym
                        when :low then 1e-8
                        when :medium then 1e-7
                        when :high then 1e-6
                        when :very_high then 1e-5
                        else 1e-7
                        end
      mass * volatile_factor
    end

    def calculate_pressure(mass, radius, atmospheric_mass)
      surface_gravity = (mass * @gravitational_constant) / (radius**2)
      surface_area = 4 * Math::PI * (radius**2)
      (atmospheric_mass * surface_gravity) / surface_area * 1e-5 # Convert to bars
    end

    def calculate_solar_constant(orbital_distance, stellar_type)
      # Placeholder - needs actual calculation based on star luminosity and distance
      # Assuming Sol-like star for now
      luminosity_sol = 3.828e26 # Watts
      (luminosity_sol / (4 * Math::PI * (orbital_distance * 1.496e11)**2)) # W/m^2
    end

    def stefan_boltzmann_temp(albedo, solar_constant)
      ((1 - albedo) * solar_constant / (4 * @stefan_boltzmann_constant))**0.25
    end

    def greenhouse_adjusted_temp(base_temp, composition)
      greenhouse_factor = 1.0
      composition.each do |gas, properties|
        next unless properties.is_a?(Hash) && properties["percentage"]
        percentage = properties["percentage"].to_f / 100.0
        case gas
        when "CO2"
          greenhouse_factor += 0.1 * percentage
        when "H2O"
          greenhouse_factor += 0.5 * percentage
        when "CH4"
          greenhouse_factor += 0.3 * percentage
        when "N2O"
          greenhouse_factor += 0.2 * percentage
        end
      end
      greenhouse_factor = greenhouse_factor.clamp(1.0, 2.0) # Prevent runaway heating
      (base_temp * greenhouse_factor).clamp(150, 350)       # Clamp to plausible range in Kelvin
    end

    def model_atmospheric_escape(composition, mass, radius, surface_temp, stellar_type, has_magnetic_field)
      escape_velocity = Math.sqrt((2 * @gravitational_constant * mass) / radius)

      composition.each do |gas_formula, properties|
        next unless properties.is_a?(Hash) && properties["molar_mass"]
        molar_mass = properties["molar_mass"].to_f / 1000.0 # kg/mol
        if molar_mass > 0
          thermal_velocity = Math.sqrt((3 * GameConstants::IDEAL_GAS_CONSTANT * surface_temp) / molar_mass) # m/s
          escape_ratio = thermal_velocity / escape_velocity

          # Very simplified escape model - lighter gases escape more easily
          escape_probability = Math.exp(-escape_velocity / thermal_velocity)

          if gas_formula == "H2" && escape_probability > 0.1 && !has_magnetic_field
            properties["percentage"] = [properties["percentage"].to_f * (1 - 0.05 * escape_probability), 0].max.round(4)
          elsif gas_formula == "He" && escape_probability > 0.2 && !has_magnetic_field
            properties["percentage"] = [properties["percentage"].to_f * (1 - 0.02 * escape_probability), 0].max.round(4)
          end
        end
      end
      composition
    end

    def calculate_initial_dust(geosphere_activity)
      geosphere_activity * 0.0005 # Example scaling factor
    end

    def calculate_percentage_composition(atmosphere)
      total_percentage = atmosphere.values.sum do |props| 
        if props.is_a?(Hash) && props.key?("percentage")
          props["percentage"].to_f
        else
          0
        end
      end
      if total_percentage > 0
        atmosphere.each do |_, properties|
          if properties.is_a?(Hash) && properties.key?("percentage")
            properties["percentage"] = (properties["percentage"].to_f / total_percentage * 100.0).round(4)
          end
        end
      end
      atmosphere
    end
  end
end
