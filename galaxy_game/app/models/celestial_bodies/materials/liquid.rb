# app/models/celestial_bodies/materials/liquid.rb
module CelestialBodies
  module Materials
    class Liquid < ApplicationRecord
      # Explicitly specify the table name
      self.table_name = 'liquid_materials'
      
      belongs_to :hydrosphere, class_name: 'CelestialBodies::Spheres::Hydrosphere'
      
      validates :name, presence: true
      validates :amount, numericality: { greater_than_or_equal_to: 0 }
    end
  end
end