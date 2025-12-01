module CelestialBodies
  class BrownDwarf < CelestialBody
    # Brown dwarfs are substellar objects that are too low in mass to sustain hydrogen fusion
    
    # Override the parent validation completely
    _validators.delete(:orbital_period) if _validators[:orbital_period]
    _validate_callbacks.each do |callback|
      if callback.filter.is_a?(ActiveModel::Validations::NumericalityValidator) && 
         callback.filter.attributes.include?(:orbital_period)
        skip_callback(:validate, callback.kind, callback.filter)
      end
    end
    
    # Add our own validation that allows nil
    validates :orbital_period, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
    
    # Attributes that make sense for brown dwarfs
    store :properties, accessors: [:spectral_type, :luminosity, :effective_temperature]
    
    # Default values
    before_validation :set_brown_dwarf_defaults, on: :create
    
    def is_star?
      false # Brown dwarfs aren't true stars
    end
    
    def is_orbiting_star?
      # Some brown dwarfs can orbit stars, but most are isolated
      solar_system.present?
    end
    
    def distance_from_star
      # Return distance only if this brown dwarf is part of a solar system
      return nil unless is_orbiting_star?
      
      # Find the first star distance
      star_distance = star_distances.first
      star_distance&.distance
    end
    
    private
    
    def set_brown_dwarf_defaults
      self.spectral_type ||= ['L', 'T', 'Y'].sample
      self.luminosity ||= rand(0.00001..0.001) # Very low compared to stars
      self.effective_temperature ||= rand(300..2500) # K
    end

    public

    # Conversion constant: Jupiter mass in kg
    JUPITER_MASS_KG = 1.898e27

    # Returns mass in kg
    def mass_kg
      mass.to_f * JUPITER_MASS_KG if mass
    end

    # Override density to use mass in kg
    def density
      return nil if mass.nil? || volume.nil?
      mass_kg / volume
    end
  end
end
