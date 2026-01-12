module CelestialBodies
  module MinorBodies
    class Asteroid < CelestialBody
      # Common asteroid validations
      validates :mass, numericality: { less_than: 1e20 }, allow_nil: true
      
      # Set STI type
      before_validation :set_sti_type
      
      # Asteroids are typically irregularly shaped
      def is_spherical?
        false
      end
      
      # Most asteroids rotate relatively quickly
      def typical_rotation_period
        # Most asteroids rotate in 2-20 hours
        rand(2..20) / 24.0 # Convert hours to days
      end
      
      # Material composition methods
      def composition_type
        # Common asteroid classifications
        [:carbonaceous, :silicaceous, :metallic].sample
      end
      
      def estimated_mineral_value
        # Rough calculation based on size and composition
        return 0 unless mass.present?
        
        # Base value per kg depending on composition
        value_per_kg = case composition_type
                      when :carbonaceous then 1.0  # Lower value, more common
                      when :silicaceous then 5.0   # Medium value
                      when :metallic then 25.0     # High value (metals)
                      else 2.0
                      end
        
        # Scale with mass (larger asteroids have more valuable materials)
        (mass * value_per_kg).to_i
      end
      
      private
      
      def set_sti_type
        self.type = 'CelestialBodies::MinorBodies::Asteroid'
      end
    end
  end
end