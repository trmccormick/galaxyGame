# app/models/celestial_bodies/materials/geological_material.rb
module CelestialBodies
  module Materials
    class GeologicalMaterial < ApplicationRecord
      self.table_name = 'geological_materials'
      
      belongs_to :geosphere, class_name: 'CelestialBodies::Spheres::Geosphere'
      
      validates :name, presence: true
      validates :layer, inclusion: { in: %w[crust mantle core] }
      validates :percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
      validates :mass, numericality: { greater_than_or_equal_to: 0 }
      validates :state, inclusion: { in: %w[solid liquid gas] }
      
      # Copy any other methods or validations from the original class
      
      # Helper methods for state
      def solid?
        state == 'solid'
      end
      
      def liquid?
        state == 'liquid'
      end
      
      def gas?
        state == 'gas'
      end
    end
  end
end