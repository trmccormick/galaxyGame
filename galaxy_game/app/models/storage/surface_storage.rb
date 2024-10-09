module Storage
  class SurfaceStorage < Storage
    def initialize(celestial_body)
      super()
      @celestial_body = celestial_body
    end

    def store(item)
      apply_surface_conditions(item)
      @items << item
    end

    def retrieve(item)
      @items.delete(item)
    end

    private

    # Applies surface conditions of the celestial body to the item
    def apply_surface_conditions(item)
      temperature = @celestial_body.surface_temperature
      pressure = @celestial_body.known_pressure
      atmosphere_composition = @celestial_body.atmosphere.composition

      # Temperature effects (e.g., freezing, melting, evaporation)
      case item.state_at(temperature, pressure)
      when 'solid'
        handle_solid_state(item, temperature)
      when 'liquid'
        handle_liquid_state(item, temperature)
      when 'gas'
        handle_gaseous_state(item, temperature)
      end

      # Atmospheric effects (e.g., oxidation, corrosion, etc.)
      apply_atmospheric_effects(item, atmosphere_composition)
    end

    def handle_solid_state(item, temperature)
      # Check if the temperature causes melting or sublimation
      if temperature > item.melting_point
        item.state = 'liquid'
      elsif temperature > item.sublimation_point
        item.state = 'gas'
      end
    end

    def handle_liquid_state(item, temperature)
      # Check if the temperature causes freezing or evaporation
      if temperature < item.freezing_point
        item.state = 'solid'
      elsif temperature > item.boiling_point
        item.state = 'gas'
      end
    end

    def handle_gaseous_state(item, temperature)
      # If temperature falls below the gas's condensation point
      if temperature < item.condensation_point
        item.state = 'liquid'
      end
    end

    def apply_atmospheric_effects(item, composition)
      # Handle effects of the atmosphere, like corrosion or reactions
      if composition.include?('O2') && item.reacts_with_oxygen?
        item.corroded = true  # Simple example of corrosion due to oxygen
      end

      if composition.include?('CO2') && item.is_sensitive_to_co2?
        item.degrade_quality
      end
    end
  end
end

  