# app/models/storage/energy_storage.rb
module Storage
  class EnergyStorage < BaseStorage
    attr_accessor :energy_type
    
    def initialize(capacity, energy_type)
      super(capacity, 'Energy')                     # Specify type as 'Energy'
      @energy_type = energy_type                    # Type of energy (e.g., 'Electricity', 'Thermal')
    end
  
    def add_energy(quantity)
      if @current_stock + quantity <= @capacity
        @current_stock += quantity                   # Update current stock
        return "#{quantity} units of #{energy_type} added to storage."
      else
        return "Not enough capacity to add #{quantity} units of #{energy_type}."
      end
    end
  
    def remove_energy(quantity)
      if @current_stock >= quantity
        @current_stock -= quantity                   # Update current stock
        return "#{quantity} units of #{energy_type} removed from storage."
      else
        return "Not enough #{energy_type} available."
      end
    end
  end
end
  