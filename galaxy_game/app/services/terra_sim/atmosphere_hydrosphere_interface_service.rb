module TerraSim
  class AtmosphereHydrosphereInterfaceService
    def initialize(celestial_body)
      @celestial_body = celestial_body
      @atmosphere = celestial_body.atmosphere
      @hydrosphere = celestial_body.hydrosphere
    end

    def simulate
      # Ensure both spheres are present
      unless @atmosphere && @hydrosphere
        Rails.logger.debug "Cannot simulate: atmosphere=#{@atmosphere.present?}, hydrosphere=#{@hydrosphere.present?}"
        return nil
      end

      # Example: Calculate humidity transfer from hydrosphere to atmosphere
      water_vapor = @atmosphere.gases.find_by(name: 'Water')&.mass.to_f
      surface_water = extract_surface_water(@hydrosphere)

      # Calculate new humidity (simple model: proportional to water vapor and surface water)
      humidity = calculate_humidity(water_vapor, surface_water)

      Rails.logger.debug "Updating atmospheric humidity to #{humidity}"
    #   @atmosphere.update(humidity: humidity)

      @atmosphere.temperature_data = (@atmosphere.temperature_data || {}).merge('humidity' => humidity)
      @atmosphere.save!

      # Example: Exchange gases (e.g., O2, CO2) between atmosphere and hydrosphere
      exchange_gases

      true
    end

    private

    def extract_surface_water(hydrosphere)
      # Sum up all water body volumes
      %w[oceans lakes rivers ice_caps].sum do |body|
        value = hydrosphere.liquid_bodies&.dig(body)
        value.is_a?(Hash) ? value['volume'].to_f : value.to_f
      end
    end

    def calculate_humidity(water_vapor, surface_water)
      # Simple proportional model, can be replaced with something more realistic
      base_humidity = 0.3
      vapor_factor = water_vapor / 1.0e12
      water_factor = surface_water / 1.0e15
      (base_humidity + vapor_factor + water_factor).clamp(0, 1)
    end

    def exchange_gases
      # Example: transfer a small amount of CO2 and O2 between spheres
      co2_transfer = 0.001 * (@atmosphere.gases.find_by(name: 'CO2')&.mass.to_f)
      o2_transfer  = 0.001 * (@atmosphere.gases.find_by(name: 'O2')&.mass.to_f)

      # Log the transfer
      Rails.logger.debug "Transferring #{co2_transfer} kg CO2 and #{o2_transfer} kg O2 between atmosphere and hydrosphere"

      # You would implement actual transfer logic here, e.g.:
      # @hydrosphere.absorb_gas('CO2', co2_transfer)
      # @hydrosphere.release_gas('O2', o2_transfer)
    end
  end
end