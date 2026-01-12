# frozen_string_literal: true

# The UnitCostCalculator determines the Cost of Goods Sold (COGS) for a manufactured
# unit based on the cost of its raw components (EAP) and the production waste factor.
class Manufacturing::CostCalculator
  attr_reader :blueprint, :material_prices, :breakdown, :cogs

  # Initializes the calculator.
  #
  # @param blueprint [Hash] The blueprint of the manufactured unit.
  # @param material_prices [Hash] A hash of {material_key => eap_price_gcc}
  def initialize(blueprint, material_prices)
    @blueprint = blueprint
    @material_prices = material_prices # EAP prices from Tier1PriceModeler
    @breakdown = []
    @cogs = 0.0
  end

  # Calculates the EAP-COGS (Earth Anchor Price - Cost of Goods Sold).
  # This is the floor price if all components are imported at their EAP floor cost.
  #
  # Formula:
  # Total_COGS = (SUM(Component_Quantity * EAP_Price) / (1 - Waste_Factor))
  #
  # @return [Float] The total COGS in GCC.
  def calculate_cogs
    raw_material_cost_sum = 0.0

    # The blueprint uses the 'required_materials' key, which is a Hash.
    required_materials = @blueprint.fetch('required_materials', {})

    # If no required_materials, try to convert from 'components' array
    if required_materials.empty? && @blueprint['components'].is_a?(Array)
      required_materials = @blueprint['components'].each_with_object({}) do |component, hash|
        material_key = component['material_key']
        quantity = component['quantity_kg'] || component['quantity']
        hash[material_key] = { 'amount' => quantity } if material_key && quantity
      end
    end

    if required_materials.empty?
      @breakdown << "ERROR: Blueprint has no required_materials or components listed."
      @cogs = Float::INFINITY
      return @cogs
    end

    required_materials.each do |material_key, material_data|
      required_amount = material_data.fetch('amount', 0.0).to_f
      price_per_unit = @material_prices[material_key]

      unless price_per_unit
        @breakdown << "ERROR: Price for required material '#{material_key}' not found in EAP lookup."
        @cogs = Float::INFINITY
        return @cogs
      end

      cost = required_amount * price_per_unit
      raw_material_cost_sum += cost

      # Store breakdown detail
      @breakdown << {
        material_key: material_key,
        quantity: required_amount,
        price: price_per_unit,
        cost: cost
      }
    end

    # Get waste factor from production_data.base_material_efficiency or waste_factor
    # Efficiency is 0.95 (95%), so waste is 0.05 (5%)
    base_efficiency = @blueprint.dig('production_data', 'base_material_efficiency') || @blueprint['waste_factor'] ? (1.0 - @blueprint['waste_factor']) : 1.0
    waste_factor = 1.0 - base_efficiency.to_f
    production_efficiency = 1.0 - waste_factor

    # Final COGS calculation
    @cogs = raw_material_cost_sum / production_efficiency
    @cogs.round(8)
  end

  # Prints a formatted breakdown of the COGS calculation.
  def print_breakdown
    raw_material_cost_sum = 0.0
    base_efficiency = @blueprint.dig('production_data', 'base_material_efficiency') || @blueprint['waste_factor'] ? (1.0 - @blueprint['waste_factor']) : 1.0
    waste_factor = 1.0 - base_efficiency.to_f
    production_efficiency = 1.0 - waste_factor

    puts "COGS Breakdown:"
    @breakdown.each do |item|
      puts "- #{item[:material_key].to_s.capitalize.ljust(25, ' ')}: #{item[:quantity]} kg * $#{item[:price].round(2)}/kg = $#{item[:cost].round(4)}"
      raw_material_cost_sum += item[:cost]
    end

    puts "--------------------------------------------------------"
    puts "Total Raw Material Cost (pre-waste) : $#{raw_material_cost_sum.round(4)}"
    puts "Production Efficiency (1 / Waste)   : #{(production_efficiency).round(4)}"
    puts "Total COGS (Material Cost / Eff.)   : $#{@cogs.round(4)}"
  end
end