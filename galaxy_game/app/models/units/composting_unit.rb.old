# app/models/units/composting_unit.rb
module Units
  class CompostingUnit < BaseUnit
    # Composting-specific validations
    validates :input_organic_waste, numericality: { greater_than_or_equal_to: 0 }
    validates :energy_cost, numericality: { greater_than_or_equal_to: 0 }

    # Processes organic waste into compost
    def operate(available_resources)
      return false unless consume_resources(available_resources)

      produce_compost(available_resources)
      true
    end

    private

    def consume_resources(available_resources)
      required_organic_waste = material_list['organic_waste']
      return false if available_resources['organic_waste'] < required_organic_waste
      return false if available_resources['energy'] < energy_cost

      # Deduct the required resources
      available_resources['organic_waste'] -= required_organic_waste
      available_resources['energy'] -= energy_cost
      true
    end

    def produce_compost(available_resources)
      available_resources['compost'] ||= 0
      available_resources['compost'] += material_list['compost_output']
    end
  end
end

