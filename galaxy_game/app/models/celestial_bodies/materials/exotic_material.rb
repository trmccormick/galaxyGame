module CelestialBodies
  module Materials
    class ExoticMaterial < ApplicationRecord
      include MaterialPropertiesConcern
      
      self.table_name = 'exotic_materials'
      
      belongs_to :geosphere, class_name: 'CelestialBodies::Spheres::Geosphere'
      
      validates :rarity, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
      validates :stability, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
      
      # Override solid?, liquid?, gas? methods from MaterialPropertiesConcern
      # to handle exotic states properly
      def solid?(temperature = nil, pressure = 1.0)
        return false if exotic_state?
        super
      end
      
      def liquid?(temperature = nil, pressure = 1.0)
        return false if exotic_state?
        super
      end
      
      def gas?(temperature = nil, pressure = 1.0)
        return false if exotic_state?
        super
      end
      
      # Non-standard states of matter beyond solid/liquid/gas
      def plasma?
        state == 'plasma'
      end
      
      def superfluid?
        state == 'superfluid'
      end
      
      def metallic_hydrogen?
        state == 'metallic_hydrogen'
      end
      
      # Helper to check if this is an exotic state
      def exotic_state?
        plasma? || superfluid? || metallic_hydrogen?
      end
      
      # Special phase transitions under extreme conditions
      def phase_transition_at(temperature, pressure)
        # Handle exotic phase transitions
        return 'metallic_hydrogen' if name == 'Hydrogen' && pressure > 1_000_000
        return 'plasma' if temperature > 10000
        return 'superfluid' if name == 'Helium' && temperature < 2.17
        
        # Fall back to normal phase transitions from MaterialPropertiesConcern
        state_at(temperature, pressure)
      end
    end
  end
end