# app/models/concerns/cryptocurrency_mining.rb
module CryptocurrencyMining
  extend ActiveSupport::Concern

  included do
    has_many :base_units, as: :attachable
  end

  def mine_gcc
    total_gcc = 0

    computers = base_units.select { |unit| unit.is_a?(Units::Computer) }

    computers.each do |computer|
      total_gcc += computer.mine(mining_difficulty, unit_efficiency)
    end

    if total_gcc > 0
      account.update(balance: account.balance + total_gcc)
      update!(funds: funds + total_gcc) if respond_to?(:funds)
    end
    
    total_gcc
  end

  private

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