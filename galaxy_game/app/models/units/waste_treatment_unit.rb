# app/models/units/waste_treatment_unit.rb
module Units
  class WasteTreatmentUnit < BaseUnit
    # Validations
    validates :name, presence: true
    validates :unit_type, presence: true
    validates :capacity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
    validates :energy_cost, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
    validates :production_rate, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
    validates :material_list, presence: true

    # Method to operate the unit
    def operate(available_resources)
      required_waste = material_list['waste']
      recycled_output = material_list['recycled_output']
      neutralized_output = material_list['neutralized_output']

      # Check if there are enough resources (waste and energy)
      if available_resources['waste'] >= required_waste && available_resources['energy'] >= energy_cost
        # Deduct the resources
        available_resources['waste'] -= required_waste
        available_resources['energy'] -= energy_cost

        # Produce recycled materials and neutralized waste
        available_resources['recycled_materials'] += recycled_output
        available_resources['neutralized_waste'] += neutralized_output

        # Operation successful
        true
      else
        # Not enough resources
        false
      end
    end
  end
end
