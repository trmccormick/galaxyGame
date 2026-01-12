# frozen_string_literal: true

# The Tier1PriceModeler calculates the Earth Anchor Price (EAP) for raw,
# non-processed commodities, establishing their baseline floor value in GCC.
# This calculated price serves as the input price for all subsequent Tier 2
# (Alloy/Component) manufacturing COGS calculations.
#
# Updated to use unified TransportCostService and EconomicConfig
class Tier1PriceModeler
  attr_reader :material_data, :destination, :source

  # Initializes the calculator with the material blueprint and destination.
  #
  # @param material_data [Hash] The specific data for a raw material (e.g., Iron).
  # @param destination [String] Destination location (default: 'luna')
  # @param source [String] Source location (default: 'earth')
  def initialize(material_data, destination: 'luna', source: 'earth')
    @material_data = material_data
    @destination = destination
    @source = source
  end

  # Calculates the Earth Anchor Price (EAP) for 1 kg of the commodity in GCC.
  #
  # Formula:
  # EAP = (Earth_Spot_Price_USD * Refining_Cost_Factor) * USD_to_GCC_Peg + Transport_Cost_GCC
  #
  # @return [Float] The final Tier 1 EAP price in GCC/kg.
  def calculate_eap
    return 0.0 unless @material_data.present?
    earth_spot_price_usd = lookup_earth_spot_price
    return 0.0 unless earth_spot_price_usd

    material_name = material_data.fetch('name', 'Unknown')
    material_id = material_data.fetch('id', material_name)
    
    usd_to_gcc_peg = EconomicConfig.usd_to_gcc_peg
    refining_factor = determine_refining_factor
    base_cost_gcc = (earth_spot_price_usd * refining_factor) * usd_to_gcc_peg
    transport_cost_gcc = calculate_transport_cost(material_id)
    eap = base_cost_gcc + transport_cost_gcc
    eap.round(4)
  rescue StandardError => e
    Rails.logger.error "Error calculating EAP for #{material_data.fetch('name', 'unknown')}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    0.0
  end

  # Helper to print the detailed breakdown.
  def print_breakdown
    material_name = material_data.fetch('name', 'Unknown Material')
    material_id = material_data.fetch('id', material_name)
    
    # Currency
    usd_to_gcc_peg = EconomicConfig.usd_to_gcc_peg
    
    # Earth pricing
    earth_spot_price_usd = lookup_earth_spot_price
    refining_factor = determine_refining_factor
    base_cost_gcc = (earth_spot_price_usd * refining_factor) * usd_to_gcc_peg
    
    # Transport
    transport_cost_gcc = calculate_transport_cost(material_id)
    transport_category = determine_transport_category
    
    # Total
    eap = base_cost_gcc + transport_cost_gcc
    
    puts "=" * 70
    puts "EARTH ANCHOR PRICE (EAP) BREAKDOWN"
    puts "Material: #{material_name}"
    puts "Route: #{@source.upcase} → #{@destination.upcase}"
    puts "=" * 70
    puts
    puts "1. EARTH BASE COST"
    puts "   Earth Spot Price:        $#{earth_spot_price_usd.round(4)} USD/kg"
    puts "   Refining Factor:         ×#{refining_factor.round(2)}"
    puts "   USD to GCC Peg:          1 USD = #{usd_to_gcc_peg} GCC"
    puts "   Refined Cost (GCC):      $#{base_cost_gcc.round(4)} GCC/kg"
    puts
    puts "2. TRANSPORT COST"
    puts "   Transport Category:      #{transport_category}"
    puts "   Transport Cost:          $#{transport_cost_gcc.round(4)} GCC/kg"
    puts
    puts "-" * 70
    puts "FINAL EARTH ANCHOR PRICE:   $#{eap.round(4)} GCC/kg"
    puts "=" * 70
    puts
    
    eap
  end
  
  private
  
  # Lookup Earth spot price from multiple sources
  def lookup_earth_spot_price
    # Priority 1: Use pricing.earth_usd.base_price_per_kg from material_data (v1.4+)
    price = material_data.dig('pricing', 'earth_usd', 'base_price_per_kg')
    return price if price

    # Priority 2: Legacy pricing.earth.base_price_per_kg (v1.2/v1.3)
    price = material_data.dig('pricing', 'earth', 'base_price_per_kg')
    return price if price

    # Priority 2: Fallback to legacy field
    price = material_data['earth_spot_price_usd_per_kg']
    return price if price

    # Priority 3: Fallback to config if JSON missing price
    price = EconomicConfig.earth_spot_price(material_data['id'])
    return price if price

    # Priority 4: Infer from rarity if needed
    rarity = material_data.dig('resource_value', 'rarity')
    infer_price_from_rarity(rarity)
  end
  
  # Infer price from rarity when no explicit price available
  def infer_price_from_rarity(rarity)
    case rarity
    when 'common' then 1.0
    when 'uncommon' then 10.0
    when 'rare' then 100.0
    when 'very_rare' then 1000.0
    else 1.0  # Default
    end
  end
  
  # Determine refining cost factor
  def determine_refining_factor
    # Priority 1: Explicit in material_data
    explicit_factor = material_data['refining_cost_factor']
    return explicit_factor if explicit_factor
    
    # Priority 2: Infer from material type
    material_type = material_data['type']
    category = material_data['category']
    
    if material_type == 'ore' || category == 'ore'
      EconomicConfig.refining_factor('ore_to_metal')
    elsif material_type == 'alloy'
      EconomicConfig.refining_factor('ore_to_alloy')
    elsif material_data.dig('processing', 'refining_method')
      EconomicConfig.refining_factor('raw_to_processed')
    else
      EconomicConfig.refining_factor('default')
    end
  end
  
  # Calculate transport cost using unified service
  def calculate_transport_cost(material_id)
    Logistics::TransportCostService.calculate_cost_per_kg(
      from: @source,
      to: @destination,
      resource: material_data['category'] || material_id
    )
  end
  
  # Determine transport category (for display purposes)
  def determine_transport_category
    material_id = material_data.fetch('id', material_data.fetch('name', 'unknown'))
    
    # Try to load full material data to determine category
    material_category = material_data['category']
    material_type = material_data['type']
    
    case material_category
    when 'ore', 'raw', 'geological'
      'bulk_material'
    when 'alloy', 'component', 'processed'
      'manufactured'
    when 'electronics', 'medical', 'technology'
      'high_tech'
    when 'hazardous', 'radioactive', 'biological'
      'specialized'
    else
      case material_type
      when 'ore', 'raw_material'
        'bulk_material'
      when 'component', 'alloy'
        'manufactured'
      when 'electronics', 'medical'
        'high_tech'
      else
        'bulk_material'
      end
    end
  end
end