module CelestialBodies
  module MinorBodies
    class DwarfPlanet < CelestialBody
      include SolidBodyConcern
      
      # Dwarf planets are in hydrostatic equilibrium (round) but haven't cleared their orbits
      validates :mass, numericality: { greater_than: 1e20, less_than: 1e24 }, allow_nil: true
      
      # Set STI type
      before_validation :set_sti_type
      
      # Dwarf planets are in hydrostatic equilibrium
      def is_spherical?
        true
      end
      
      # Calculated values for dwarf planets
      def calculate_geological_activity
        # Get age from properties hash
        age_value = properties.try(:[], 'age')
        
        # Simpler calculation than for full planets
        return 10 unless age_value.present? && mass.present?
        
        age_factor = [1.0 - (age_value.to_f / 5.0e9), 0.2].max
        mass_factor = mass.to_f / 1.0e21
        
        [mass_factor * age_factor * 20, 40].min
      end
      
      # Check if it's in an asteroid belt
      def asteroid_belt_member?
        solar_system&.asteroid_belts&.any? do |belt|
          belt.contains?(self)
        end
      end
      
      private
      
      def set_sti_type
        self.type = 'CelestialBodies::MinorBodies::DwarfPlanet'
      end
    end
  end
end