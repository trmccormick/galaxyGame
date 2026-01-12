# app/units/models/biogas_generator.rb
module Units
  class BiogasGenerator < BaseUnit
    # Biogas generator-specific attributes
    validates :input_biomass, numericality: { greater_than_or_equal_to: 0 }
    validates :input_organic_waste, numericality: { greater_than_or_equal_to: 0 }
    validates :energy_cost, numericality: { greater_than_or_equal_to: 0 }  # Updated to use energy_cost

    # Processes waste into biogas and fertilizer
    def operate(available_resources)
      return false unless consume_resources(available_resources)

      produce_biogas(available_resources)
      produce_fertilizer(available_resources)
      true
    end

    private

    def consume_resources(available_resources)
      required_biomass = material_list['biomass']
      required_organic_waste = material_list['organic_waste']
      
      # Check for sufficient biomass, organic waste, and energy
      if available_resources['biomass'] < required_biomass ||
        available_resources['organic_waste'] < required_organic_waste ||
        available_resources['energy'] < energy_cost
        return false
      end

      # Deduct the resources if available
      available_resources['biomass'] -= required_biomass
      available_resources['organic_waste'] -= required_organic_waste
      available_resources['energy'] -= energy_cost  # Use energy instead of power
      true
    end

    def produce_biogas(available_resources)
      available_resources['biogas'] ||= 0
      available_resources['biogas'] += material_list['biogas_output']
    end

    def produce_fertilizer(available_resources)
      available_resources['fertilizer'] ||= 0
      available_resources['fertilizer'] += material_list['fertilizer_output']
    end
  end
end
