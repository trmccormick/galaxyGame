module TerraSim
  class Simulator
    include GameConstants

    attr_reader :celestial_body, :stars
    
    def initialize(celestial_body)
      @celestial_body = celestial_body
      @stars = celestial_body.solar_system&.stars || []
    end

    def calc_current
      # For bodies without stars, just set basic properties
      if stars.empty?
        @celestial_body.update(surface_temperature: 3) # Space background temperature
        update_gravity
        update_spheres
        return
      end

      # Step 1: Update fundamental properties
      update_temperature
      update_gravity
      
      # Step 2: Update each sphere in dependency order
      update_spheres
    end

    private

    def update_temperature
      # Calculate equilibrium temperature based on stellar flux
      albedo = @celestial_body.albedo || 0.3
      
      # Use stellar flux calculation via solar_constant method
      solar_constant = @celestial_body.solar_constant
      
      if solar_constant && solar_constant > 0
        # Stefan-Boltzmann equilibrium temperature formula
        # T = (S × (1 - a) / (4 × σ))^0.25
        equilibrium_temp = ((solar_constant * (1 - albedo)) / (4 * GameConstants::STEFAN_BOLTZMANN_CONSTANT))**0.25
        @celestial_body.update(surface_temperature: equilibrium_temp)
      else
        # Default temperature if no solar flux (space background)
        @celestial_body.update(surface_temperature: 3)
      end
    end

    # Modify this method to properly use the SolidBodyConcern
    def update_gravity
      # Only update gravity if the celestial body has this method
      if @celestial_body.respond_to?(:update_gravity)
        @celestial_body.update_gravity
      else
        # For bodies without the SolidBodyConcern, do something else
        # Maybe just skip it, or use a different calculation
        Rails.logger.info "Skipping gravity update for #{@celestial_body.name} - no update_gravity method"
      end
    end

    def update_spheres
      # Simulate atmosphere if present
      if @celestial_body.respond_to?(:atmosphere) && @celestial_body.atmosphere.present?
        AtmosphereSimulationService.new(@celestial_body).simulate
      end
      
      # Simulate geosphere if present
      if @celestial_body.respond_to?(:geosphere) && @celestial_body.geosphere.present?
        GeosphereSimulationService.new(@celestial_body).simulate
      end
      
      # Simulate hydrosphere if present
      if @celestial_body.respond_to?(:hydrosphere) && @celestial_body.hydrosphere.present?
        HydrosphereSimulationService.new(@celestial_body).simulate
      end
      
      # Simulate biosphere if present
      if @celestial_body.respond_to?(:biosphere) && @celestial_body.biosphere.present?
        BiosphereSimulationService.new(@celestial_body).simulate
      end
      
      # IMPORTANT: Add this call to the interface service if both spheres exist
      if @celestial_body.respond_to?(:biosphere) && @celestial_body.biosphere.present? &&
         @celestial_body.respond_to?(:geosphere) && @celestial_body.geosphere.present?
        BiosphereGeosphereInterfaceService.new(@celestial_body).simulate
      end
      
      # Handle exotic world types - Duck typing approach
      if @celestial_body.respond_to?(:has_exotic_properties?) && @celestial_body.has_exotic_properties?
        ExoticWorldSimulationService.new(@celestial_body).simulate
      end
    end
  end
end





