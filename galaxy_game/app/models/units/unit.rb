class Unit
    attr_accessor :unit_type, :capacity, :status, :energy_consumption
  
    def initialize(unit_type, capacity, energy_consumption)
      @unit_type = unit_type
      @capacity = capacity
      @energy_consumption = energy_consumption
      @status = :active
    end
  
    # Method to operate the unit, consuming energy or resources
    def operate
      puts "Operating #{@unit_type} unit. Capacity: #{@capacity}"
    end
end