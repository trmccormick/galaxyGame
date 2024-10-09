# app/models/concerns/energy_management.rb
module EnergyManagement
    extend ActiveSupport::Concern
  
    included do
      # Any necessary validations can go here
    end
  
    attr_accessor :energy_storage
  
    def activate_units
      available_energy = energy_storage.current_stock
  
      units.each do |unit|
        if available_energy >= unit.energy_consumption
          unit.activate
          available_energy -= unit.energy_consumption
        end
      end
  
      energy_storage.current_stock = available_energy
    end
  end
  