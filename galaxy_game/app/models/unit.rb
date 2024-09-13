# app/models/unit.rb

class Unit < ApplicationRecord
    # Polymorphic association for flexible placement
    belongs_to :location, polymorphic: true
  
    # Add validations
    validates :name, presence: true
    validates :unit_type, presence: true
    validates :capacity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
    validates :energy_cost, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
    validates :production_rate, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
    validates :material_list, presence: true
  
    # Check if the unit can be built with available resources
    def can_be_built?(available_resources)
      material_list.all? do |material, amount|
        available_resources[material].to_i >= amount
      end
    end
  
    # Method to process building a unit, consuming resources
    def build_unit(available_resources)
      return false unless can_be_built?(available_resources)
  
      # Deduct materials from the available resources
      material_list.each do |material, amount|
        available_resources[material] -= amount
      end
      true
    end
  end
  
