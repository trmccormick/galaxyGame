# frozen_string_literal: true

module Marketplace
  class GuaranteedMarketSale
    def self.execute(player_settlement:, resource:, volume:, bid_price:, ldc_settlement:)
      new(
        player_settlement: player_settlement,
        resource: resource,
        volume: volume,
        bid_price: bid_price,
        ldc_settlement: ldc_settlement
      ).process
    end

    def initialize(player_settlement:, resource:, volume:, bid_price:, ldc_settlement:)
      @player_settlement = player_settlement
      @resource = resource
      @volume = volume
      @bid_price = bid_price
      @ldc_settlement = ldc_settlement
    end

    def process
      # Query account directly from database to avoid association caching issues
      ldc_account = Financial::Account.find_by(
        accountable_type: @ldc_settlement.class.name,
        accountable_id: @ldc_settlement.id
      )
      
      unless ldc_account
        return {
          success: false,
          error: "LDC settlement has no account",
          transaction: nil
        }
      end

      total_gcc = @volume * @bid_price

      if ldc_account.balance < total_gcc
        return {
          success: false,
          error: "Insufficient LDC funds: #{ldc_account.balance} < #{total_gcc}",
          transaction: nil
        }
      end

      transaction = Financial::TransactionManager.create_transfer(
        from: ldc_account,
        to: @player_settlement,
        amount: total_gcc,
        currency: :gcc,
        description: "Buyer of last resort: #{@resource} x#{@volume} @ #{@bid_price} GCC"
      )

      {
        success: true,
        transaction_id: transaction.id,
        transaction: transaction,
        amount_transferred: total_gcc,
        error: nil
      }
    rescue StandardError => e
      {
        success: false,
        error: "Transfer failed: #{e.message}",
        transaction: nil
      }
    end
  end
end
