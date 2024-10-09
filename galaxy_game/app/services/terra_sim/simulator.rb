module TerraSim
  class Simulator
    attr_reader :celestial_body, :stars

    IDEAL_GAS_CONSTANT = 0.0821 # L·atm/(mol·K)
    STEFAN_BOLTZMANN_CONSTANT = 5.67e-8 # W/(m²·K⁴)

    def initialize(celestial_body)
      @celestial_body = celestial_body
      @stars = celestial_body.solar_system&.stars || []
    end

    def calc_current
      return if stars.empty?

      update_temperature
      update_gravity
      
      # Call each simulation service
      AtmosphereSimulationService.new(celestial_body).simulate if celestial_body.atmosphere.present?
      HydrosphereSimulationService.new(celestial_body).simulate if celestial_body.hydrosphere.present?
      BiosphereSimulationService.new(celestial_body).simulate if celestial_body.biosphere.present?
      GeosphereSimulationService.new(celestial_body).simulate if celestial_body.geosphere.present?

      celestial_body.save!
    end

    private

    def update_temperature
      return unless celestial_body.distance_from_star.present?
    
      total_solar_constant = stars.sum do |star|
        next 0 if star.nil? || star.luminosity.nil?
    
        distance = celestial_body.distance_from_star
        next 0 if distance.nil? || distance.zero?
    
        star.luminosity / (4 * Math::PI * distance**2)
      end
    
      if total_solar_constant > 0
        new_temperature = Math.cbrt(total_solar_constant / (IDEAL_GAS_CONSTANT * celestial_body.albedo))
        celestial_body.surface_temperature = new_temperature
      end
    end

    def update_gravity
      celestial_body.update_gravity
    end
  end
end





