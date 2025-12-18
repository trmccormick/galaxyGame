# app/models/celestial_bodies/materials/geological_material.rb
module CelestialBodies
  module Materials
    class GeologicalMaterial < ApplicationRecord
      include MaterialPropertiesConcern
      
      self.table_name = 'geological_materials'
      
      belongs_to :geosphere, class_name: 'CelestialBodies::Spheres::Geosphere'
      
      # Remove name validation (now in concern)
      # validates :name, presence: true
      
      validates :layer, inclusion: { in: %w[crust mantle core] }
      validates :percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
      validates :mass, numericality: { greater_than_or_equal_to: 0 }
      validates :state, inclusion: { in: %w[solid liquid gas metallic_hydrogen plasma superfluid bose-einstein_condensate] }
      
      # Helper methods for state now provided by concern
      # We can remove these or override them to use the 'state' field
      
      # Override solid? to use the stored state
      def solid?
        return false if exotic_state?
        state == 'solid'
      end
      
      def liquid?
        return false if exotic_state?
        state == 'liquid'
      end
      
      def gas?
        return false if exotic_state?
        state == 'gas'
      end

      # Add specific exotic state checkers
      def plasma?
        state == 'plasma'
      end

      def metallic_hydrogen?
        state == 'metallic_hydrogen'
      end

      def superfluid?
        state == 'superfluid'
      end
      
      def exotic_state?
        ['metallic_hydrogen', 'plasma', 'superfluid', 'bose-einstein_condensate'].include?(state)
      end

      private
      
      def default_state
        state || 'solid'
      end
    end
  end
end