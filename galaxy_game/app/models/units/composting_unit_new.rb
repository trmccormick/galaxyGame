# app/models/units/composting_unit.rb
module Units
  class CompostingUnit < BaseUnit
    attr_accessor :compost_yield

    # Validations for organic waste and energy cost
    validates :input_organic_waste, numericality: { greater_than_or_equal_to: 0 }
    validates :energy_cost, numericality: { greater_than_or_equal_to: 0 }

    def initialize(name, base_materials, operating_requirements, input_resources, output_resources)
      super(name, base_materials, operating_requirements, input_resources, output_resources)
      @compost_yield = 0
    end

    # Main operation that processes resources and produces compost
    def operate(available_resources)
      return false unless consume_resources(available_resources)

      produce_compost(available_resources)
      true
    end

    private

    # Combines both consume_resources logic: handles organic waste and sludge
    def consume_resources(available_resources)
      required_organic_waste = material_list['organic_waste']
      sludge_needed = 5  # Example amount

      # Check if sufficient organic waste and energy are available
      if available_resources['organic_waste'] < required_organic_waste || available_resources['energy'] < energy_cost
        return false
      end

      # Check if sufficient sludge is available (optional)
      if available_resources['sludge'] < sludge_needed
        puts "Not enough sludge available for composting, operation continues without it!"
      else
        puts "#{name} is composting #{sludge_needed} units of sludge."
        available_resources['sludge'] -= sludge_needed
      end

      # Deduct resources required for composting
      available_resources['organic_waste'] -= required_organic_waste
      available_resources['energy'] -= energy_cost
      true
    end

    # Produces compost, factoring in both organic waste and sludge
    def produce_compost(available_resources)
      available_resources['compost'] ||= 0

      compost_produced = material_list['compost_output']
      sludge_conversion = 5 * 0.8  # Assuming 80% conversion from sludge

      available_resources['compost'] += compost_produced + sludge_conversion
      puts "#{name} produces #{compost_produced + sludge_conversion} units of compost."
    end
  end
end


