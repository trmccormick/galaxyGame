# app/models/units/base_unit.rb
module Units
  class BaseUnit < ApplicationRecord
    include Storage  # Include the Storage module

    # Polymorphic association for flexible placement
    belongs_to :location, polymorphic: true

    # Assuming the owner can be a Settlement, Outpost, or Spaceship
    belongs_to :owner, polymorphic: true

    # Polymorphic association to resources
    has_many :inventories, dependent: :destroy # Manage resources
  
    # Add validations
    validates :name, presence: true
    validates :unit_type, presence: true
    validates :capacity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
    validates :energy_cost, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
    validates :production_rate, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
    validates :material_list, presence: true

    # Assuming material_list is a serialized attribute or a separate model
    serialize :material_list, Hash # If using a hash for simplicity
  
    # Initialize the unit's storage capacity
    def initialize(attributes = {})
      super(attributes)
      initialize_storage(capacity) if capacity.present?
    end

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

    # New method to consume resources
    def consume_resources(available_resources)
      material_list.each do |material, amount|
        # Check if there's enough of the resource to consume
        if available_resources[material].to_i >= amount
          available_resources[material] -= amount
        else
          # Handle insufficient resources (e.g., log an error, raise an exception)
          return false # Not enough resources to consume
        end
      end
      true # Resources consumed successfully
    end

    # Logic for upgrading the unit's production rate or capacity
    def upgrade
      self.capacity += 10 # Example increment
      self.production_rate += 5 # Example increment for production rate
      initialize_storage(capacity) # Re-initialize storage with new capacity
      save
    end

    # Method to consume resources during operation
    def operate(available_resources)
      return false if available_resources.nil? # Ensure available_resources is not nil

      material_list.each do |material, amount|
        next unless available_resources.key?(material) # Ensure the material exists
        
        if available_resources[material].to_i >= amount
          available_resources[material] -= amount
        else
          return false # Not enough resources
        end
      end
      true # Return true if operation is successful
    end

    # Method to add items to storage
    def add_to_storage(item, quantity)
      add_item(item, quantity) if can_store?(quantity)
    end

    # Method to remove items from storage
    def remove_from_storage(item_name, quantity)
      remove_item(item_name, quantity)
    end
  end
end

  
