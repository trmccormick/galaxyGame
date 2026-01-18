# app/models/units/waste_treatment_unit.rb
module Units
  class WasteTreatmentUnit < BaseUnit
    # Virtual attributes that map to operational_data
    def energy_cost
      operational_data&.dig('energy_cost') || 0
    end
    
    def energy_cost=(value)
      self.operational_data ||= {}
      self.operational_data['energy_cost'] = value
    end
    
    def material_list
      operational_data&.dig('material_list') || {}
    end
    
    def material_list=(value)
      self.operational_data ||= {}
      self.operational_data['material_list'] = value
    end
    
    # Validations
    validates :name, presence: true
    validates :unit_type, presence: true
    validates :material_list, presence: true
    
    validate :validate_energy_cost
    validate :validate_capacity
    validate :validate_production_rate
    
    def validate_energy_cost
      cost = operational_data&.dig('energy_cost')
      if cost.present? && (!cost.is_a?(Numeric) || cost < 0)
        errors.add(:energy_cost, 'must be a non-negative number')
      end
    end
    
    def validate_capacity
      cap = operational_data&.dig('capacity')
      if cap.present? && (!cap.is_a?(Integer) || cap < 0)
        errors.add(:capacity, 'must be a non-negative integer')
      end
    end
    
    def validate_production_rate
      rate = operational_data&.dig('production_rate')
      if rate.present? && (!rate.is_a?(Integer) || rate < 0)
        errors.add(:production_rate, 'must be a non-negative integer')
      end
    end

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
