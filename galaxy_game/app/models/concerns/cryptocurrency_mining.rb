# app/models/concerns/cryptocurrency_mining.rb
module CryptocurrencyMining
  extend ActiveSupport::Concern

  included do
    has_many :base_units, as: :attachable
  end

  def mine_gcc
    total_gcc = 0
    total_power_usage = 0

    # Mine from computers in satellites first
    total_gcc += mine_from_units(satellite_computers, total_power_usage)

    # Then mine from directly attached computers
    total_gcc += mine_from_units(ground_computers, total_power_usage)

    if total_gcc > 0
      # Update account balance
      account.update(balance: account.balance + total_gcc)
      
      # Update internal funds if supported
      update!(funds: funds + total_gcc) if respond_to?(:funds)
    end
    
    total_gcc
  end

  private

  def mine_from_units(units, total_power_usage)
    total_gcc = 0

    Array(units).each do |unit|
      if total_power_usage + unit.mining_power <= available_power
        total_gcc += unit.mine(mining_difficulty, unit_efficiency)
        total_power_usage += unit.mining_power
      else
        break
      end
    end

    total_gcc
  end

  def ground_computers
    return @ground_computers if defined?(@ground_computers)
    base_units.where(type: 'Units::Computer')
  end

  def satellite_computers
    return @satellite_computers if defined?(@satellite_computers)
    base_units.where(type: 'Craft::BaseCraft', craft_type: 'satellite')
      .map { |satellite| satellite.base_units.find_by(type: 'Units::Computer') }
      .compact
  end

  def available_power
    1000 # Example power limit (can be dynamic)
  end

  def mining_difficulty
    1.0 # Can be made dynamic based on game conditions
  end

  def unit_efficiency
    1.0 # Can be affected by maintenance status, etc
  end
end


