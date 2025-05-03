# app/models/celestial_bodies/materials/liquid.rb
module CelestialBodies
  module Materials
    class Liquid < ApplicationRecord
      include MaterialPropertiesConcern
      
      self.table_name = 'liquid_materials'
      
      belongs_to :hydrosphere, class_name: 'CelestialBodies::Spheres::Hydrosphere'
      
      # Remove name validation (now in concern)
      # validates :name, presence: true
      
      validates :amount, numericality: { greater_than_or_equal_to: 0 }
      
      private
      
      def default_state
        'liquid'
      end
    end
  end
end