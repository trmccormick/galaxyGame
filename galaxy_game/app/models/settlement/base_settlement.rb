# app/models/base_settlement.rb
class BaseSettlement < ApplicationRecord
    include PopulationManagement
    include Housing    
  
    belongs_to :colony
    has_many :base_units
    has_many :inventories
  
    # Validations for shared attributes
    validates :name, presence: true
    validates :current_population, numericality: { greater_than_or_equal_to: 0 }
    validates :food_per_person, :water_per_person, :energy_per_person, numericality: { greater_than: 0 }

    def initialize
        super  # Call to parent class's initialize method
        initialize_housing(population_capacity || 100)  # Use existing capacity or default
    end    
  
    # Method to collect materials from the environment
    def collect_materials(amount)
      collected_materials = base_units.sum do |unit|
        unit.collect_materials(amount)  # Assuming each unit has a collect_materials method
      end
  
      update_inventory(collected_materials)  # Update inventory with collected materials
    end
  
    # Method to process collected materials
    def process_materials
      base_units.each do |unit|
        unit.process_materials(inventories)  # Assuming each unit has a process_materials method
      end
    end

    # Override the method to allocate space as needed
    def allocate_space(num_people)
        super(num_people)  # Call the Housing concern's method
        # Additional logic can be added here if necessary
    end
  
    private
  
    def update_inventory(collected_materials)
      # Logic to update the inventory based on collected materials
      collected_materials.each do |material, amount|
        inventory = inventories.find_or_initialize_by(material: material)
        inventory.amount += amount
        inventory.save
      end
    end
  
    # Override resource requirements to account for shared needs
    def resource_requirements
      {
        food: calculate_food_requirements,
        water: calculate_water_requirements,
        energy: calculate_energy_requirements,
        materials: nil  # Placeholder for raw materials, can be overridden in subclasses
      }
    end
  
    def calculate_food_requirements
      current_population * (food_per_person * 1.1)  # Increase food requirement slightly
    end
  
    def calculate_water_requirements
      current_population * water_per_person
    end
  
    def calculate_energy_requirements
      current_population * energy_per_person
    end
end
  
  
  