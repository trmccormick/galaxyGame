# app/services/trade_service.rb
# Unified trading service that orchestrates all trading activities
class TradeService
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

  private

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