# app/models/concerns/cryptocurrency_mining.rb
module CryptocurrencyMining
  extend ActiveSupport::Concern

  included do
    has_many :computers
    has_many :satellites
  end

  def mine_gcc
    total_gcc = 0
    total_power_usage = 0

    # Mine from satellites first (if any)
    total_gcc += mine_from_units(satellites, total_power_usage)

    # Then mine from computers if power is available
    total_gcc += mine_from_units(computers, total_power_usage)

    # Update account balance
    account.update(balance: account.balance + total_gcc)
  end

  private

  def mine_from_units(units, total_power_usage)
    total_gcc = 0

    units.each do |unit|
      if total_power_usage + unit.mining_power <= available_power
        total_gcc += unit.mine
        total_power_usage += unit.mining_power
      else
        break
      end
    end

    total_gcc
  end

  # Available power that can be used for mining
  def available_power
    1000 # Example power limit (can be dynamic)
  end
end


  