# app/models/units/biomass_recycler.rb
module Units
  class BiomassRecycler < BaseUnit
    # Define specific attributes for this unit
    validates :input_biomass, numericality: { greater_than_or_equal_to: 0 }
    validates :energy_cost, numericality: { greater_than_or_equal_to: 0 }  # Updated to use energy_cost

    # Processes waste biomass into useful outputs
    def operate(available_resources)
      return false unless consume_resources(available_resources)

      produce_fertilizer(available_resources)
      produce_biofuel(available_resources)
      true
    end

    private

    def consume_resources(available_resources)
      required_biomass = material_list['biomass']
      
      # Check for sufficient biomass and energy
      if available_resources['biomass'] < required_biomass ||
        available_resources['energy'] < energy_cost
        return false
      end

      # Deduct the resources if available
      available_resources['biomass'] -= required_biomass
      available_resources['energy'] -= energy_cost  # Ensure energy is used
      true
    end

    def produce_fertilizer(available_resources)
      available_resources['fertilizer'] ||= 0
      available_resources['fertilizer'] += material_list['fertilizer_output']
    end

    def produce_biofuel(available_resources)
      available_resources['biofuel'] ||= 0
      available_resources['biofuel'] += material_list['biofuel_output']
    end
  end
end
