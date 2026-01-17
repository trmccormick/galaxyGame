# app/services/trade_service.rb
# Unified trading service that orchestrates all trading activities
class TradeService
  attr_reader :inventory, :buyer_colony

  def initialize(inventory, buyer_colony)
    @inventory = inventory
    @buyer_colony = buyer_colony
  end
  # Execute different types of trades
  def self.execute_trade(trade_type, participants, terms)
    case trade_type.to_sym
    when :player_direct
      execute_direct_trade(participants, terms)
    when :player_contract
      execute_contract_trade(participants, terms)
    when :npc_automated
      execute_npc_trade(participants, terms)
    when :market_order
      execute_market_trade(participants, terms)
    else
      raise ArgumentError, "Unknown trade type: #{trade_type}"
    end
  end

  # Create a player contract for logistics
  def self.create_player_contract(contract_data)
    Logistics::PlayerContractService.create_logistics_contract(contract_data)
  end

  # Get available insurance options for a contract
  def self.get_insurance_options(contract)
    Logistics::PlayerContractService.generate_insurance_options(contract)
  end

  # Accept a player contract
  def self.accept_contract(contract, acceptor, options = {})
    Logistics::PlayerContractService.accept_contract(contract, acceptor, options[:insurance])
  end

  # Complete a contract
  def self.complete_contract(contract)
    Logistics::PlayerContractService.complete_contract(contract)
  end

  # Fail a contract
  def self.fail_contract(contract, reason)
    Logistics::PlayerContractService.fail_contract(contract, reason)
  end

  # Get available insurers
  def self.available_insurers
    Insurance::InsuranceService.available_insurers
  end

  # Calculate insurance premium
  def self.calculate_insurance_premium(contract_value, tier, risk_factors = {})
    Insurance::InsuranceService.calculate_premium(contract_value, tier, risk_factors)
  end

  # Instance methods for pricing calculations
  def dynamic_price
    scarcity_factor = scarcity_factor()
    base_price = base_price_for_type
    fuel_cost = distance_to_buyer * fuel_cost_per_unit
    market_modifier = market_conditions

    base_price * scarcity_factor + fuel_cost + market_modifier
  end

  def base_price_for_type
    # Assume we're dealing with the first item in the inventory
    item = @inventory.items.first
    case item&.material_type
    when 'raw_material'
      5.0
    when 'processed_material'
      20.0
    else
      10.0
    end
  end

  def fuel_cost_per_unit
    0.1
  end

  def distance_to_buyer
    # Calculate distance between colonies
    # For now, return a simple calculation
    seller_distance = @inventory.inventoryable.celestial_body.distance_from_star || 10000
    buyer_distance = @buyer_colony.celestial_body.distance_from_star || 5000
    (seller_distance - buyer_distance).abs / 1000.0
  end

  def market_conditions
    # Return a random market condition modifier between -5 and 5
    rand(-5.0..5.0)
  end

  private

  def scarcity_factor
    # Assume we're dealing with the first item in the inventory
    item = @inventory.items.first
    quantity = item&.amount || 0
    (1000 / (quantity + 1).to_f)
  end

  def self.execute_direct_trade(participants, terms)
    # Direct item exchange between players at same location
    # Implementation would handle immediate item transfers
    Rails.logger.info "[Trade] Direct trade executed between #{participants.map(&:name).join(' and ')}"
    true
  end

  def self.execute_contract_trade(participants, terms)
    # Contract-based trade (courier, item exchange, etc.)
    contract = terms[:contract]
    acceptor = participants[:acceptor]

    accept_contract(contract, acceptor, terms[:options] || {})
  end

  def self.execute_npc_trade(participants, terms)
    # NPC-to-NPC automated trade
    from_settlement = participants[:from_settlement]
    to_settlement = participants[:to_settlement]

    Logistics::ContractService.create_internal_transfer(
      from_settlement,
      to_settlement,
      terms[:material],
      terms[:quantity],
      terms[:transport_method] || :orbital_transfer
    )
  end

  def self.execute_market_trade(participants, terms)
    # Market-based trade through the existing market system
    buyer = participants[:buyer]
    seller = participants[:seller]

    Market::TradeExecutionService.execute_trade(
      buyer: buyer,
      seller: seller,
      item: terms[:item],
      quantity: terms[:quantity],
      price: terms[:price]
    )
  end
end  