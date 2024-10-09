module CelestialBodies
    class Material < ApplicationRecord
      belongs_to :celestial_body, class_name: 'CelestialBodies::CelestialBody'
      
      # Attributes
      attr_accessor :name, :amount
  
      # Validations
      validates :name, presence: true
      validates :amount, numericality: { greater_than_or_equal_to: 0 }

      attr_accessor :name, :abundance_percentage, :uses, :amount

    #   def initialize(name, abundance_percentage, uses)
    #     @name = name                      # Name of the material
    #     @abundance_percentage = abundance_percentage  # Percentage of the material in the celestial body
    #     @uses = uses                      # Possible uses of the material
    #     @amount = 0                       # Amount of the material (will be calculated)
    #   end
    
    #   def calculate_amount(total_mass)
    #     @amount = total_mass * (@abundance_percentage / 100.0)
    #   end
    end
end