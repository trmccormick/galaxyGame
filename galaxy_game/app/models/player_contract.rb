# app/models/player_contract.rb
class PlayerContract < ApplicationRecord
  belongs_to :issuer, polymorphic: true  # Player or Organization
  belongs_to :acceptor, polymorphic: true, optional: true
  belongs_to :location, class_name: 'Location::BaseLocation', optional: true  # Station/base where contract is available

  enum contract_type: {
    item_exchange: 0,    # Direct item trade
    courier: 1          # Transport contract
    # auction: 2,          # Auction-style selling (future expansion)
    # loan: 3             # Future expansion
  }
  enum status: { open: 0, accepted: 1, completed: 2, failed: 3, cancelled: 4 }

  # Contract terms
  serialize :requirements, JSON    # What acceptor must provide
  serialize :reward, JSON         # What issuer provides
  serialize :collateral, JSON     # Security deposit

  # Security fields
  # belongs_to :collateral_account, class_name: 'Financial::Account', optional: true
  serialize :security_terms, JSON

  # Insurance
  has_one :insurance_policy, as: :covered_contract

  validates :contract_type, presence: true

  scope :active, -> { where(status: [:open, :accepted]) }
  scope :courier_contracts, -> { where(contract_type: :courier) }

  def value
    # Calculate contract value for insurance purposes
    case contract_type
    when 'courier'
      reward['credits'].to_f
    when 'item_exchange'
      calculate_item_value
    else
      1000 # Default value
    end
  end

  def risk_factors
    {
      route_risk: calculate_route_risk,
      contractor_reliability: 0.7, # Would be calculated from reputation
      cargo_value: value,
      contract_duration: 7 # Default duration
    }
  end

  private

  def calculate_item_value
    # Simplified item value calculation
    requirements.sum { |req| req['quantity'].to_i * 100 } rescue 1000
  end

  def calculate_route_risk
    # Simplified route risk
    if requirements['destination'] && requirements['origin']
      0.5 # Medium risk for inter-location transport
    else
      0.3 # Lower risk for local contracts
    end
  end
end