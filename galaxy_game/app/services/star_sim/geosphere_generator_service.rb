# app/services/star_sim/geosphere_generator_service.rb
module StarSim
  class GeosphereGeneratorService
    def initialize(celestial_body_data, material_lookup_service)
      @body_data = celestial_body_data
      @material_lookup = material_lookup_service
      @planet_composition_estimator = PlanetCompositionEstimator.new(
        mass: UnitConverter.earth_masses(@body_data[:mass].to_f), # Assuming you have a unit converter
        orbital_zone: determine_orbital_zone(@body_data[:star_distances]&.first&.[](:distance).to_f), # Need to implement this
        type: @body_data[:type]&.to_sym
      )
      @gravitational_constant = 6.674e-11 # m^3 kg^-1 s^-2
    end

    def generate
      geosphere_data = @body_data[:geosphere_attributes] || {}

      name = @body_data[:name]
      mass = @body_data[:mass].to_f
      radius = @body_data[:radius].to_f
      surface_temp = @body_data[:surface_temperature].to_f
      density = @body_data[:density].to_f

      composition_profile = @planet_composition_estimator.estimate

      geosphere_data[:temperature] ||= generate_internal_temperature(mass, radius)
      geosphere_data[:pressure] ||= generate_internal_pressure(mass, radius, density)
      geosphere_data[:geological_activity] ||= calculate_geological_activity(mass, radius, geosphere_data[:temperature])
      geosphere_data[:tectonic_activity] ||= geosphere_data[:geological_activity] > 50

      layer_radii = calculate_layer_radii(radius, density, composition_profile)

      geosphere_data[:crust_composition] ||= generate_layer_composition(:crust, name, surface_temp, composition_profile)
      geosphere_data[:mantle_composition] ||= generate_layer_composition(:mantle, name, surface_temp, composition_profile)
      geosphere_data[:core_composition] ||= generate_layer_composition(:core, name, density, composition_profile)

      geosphere_data[:total_crust_mass] ||= calculate_layer_mass(:crust, mass, radius, layer_radii)
      geosphere_data[:total_mantle_mass] ||= calculate_layer_mass(:mantle, mass, radius, layer_radii)
      geosphere_data[:total_core_mass] ||= calculate_layer_mass(:core, mass, radius, layer_radii)

      geosphere_data
    end

    private

    def determine_orbital_zone(distance_au)
      # Basic implementation - needs tuning based on star luminosity
      return :inner_zone if distance_au < 0.7
      return :habitable_zone if distance_au >= 0.7 && distance_au <= 1.5
      return :outer_zone if distance_au > 1.5
      nil
    end

    def generate_layer_composition(layer, name, surface_temp, composition_profile)
      composition = super # Call the original method

      if layer == :crust
        geological_activity = calculate_geological_activity(@body_data[:mass].to_f, @body_data[:radius].to_f, geosphere_data[:temperature])
        if geological_activity > 60 # High geological activity implies more volcanism
          # Add volcanic gases to the initial crust composition (as oxides/minerals)
          composition["Silicon"] = (composition["Silicon"].to_f + rand(1..5)).round(1) if composition["Silicon"]
          composition["Sulfur"] = (composition["Sulfur"].to_f + rand(0..3)).round(1) if composition["Sulfur"]
          # ... add other elements/compounds based on TerraSim's eruption gases
        end
        # ... other crust generation logic ...
      end
      composition
    end

    def generate_crust_volatiles(surface_temp, volatile_content)
      volatiles = {}
      scale_factor = case volatile_content
                     when :low then 0.5
                     when :medium then 1.0
                     when :high then 2.0
                     when :very_high then 3.0
                     else 1.0
                     end

      if surface_temp < 273 # Cold
        volatiles["H2O"] = rand(5..15) * scale_factor
        volatiles["CO2"] = rand(1..5) * scale_factor
        volatiles["CH4"] = rand(0..3) * scale_factor
      elsif surface_temp < 400 # Temperate
        volatiles["H2O"] = rand(1..5) * scale_factor
        volatiles["CO2"] = rand(0..2) * scale_factor
      else # Hot
        volatiles["SO2"] = rand(0..5) * scale_factor
      end
      volatiles.transform_values { |v| v.round(1) }.compact
    end

    # ... (rest of your private methods like calculate_layer_radii, masses, internal temp/pressure, activity) ...
  end
end