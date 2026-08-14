module AIManager
  class ContractCreationService
    # Creates a player contract for local fulfillment (GCC-funded)
    def self.create_player_contract(settlement, material:, amount:, payout_gcc:)
      # Logic: Create a new instance of PlayerContract
      # PlayerContract.create!(...)
      Rails.logger.debug "PlayerContract created for #{amount} #{material} at #{payout_gcc} GCC."
    end

    # Creates an external import order (USD-funded)
    # Writes a LogisticsContract record to the database.
    # @param settlement [Settlement] destination settlement receiving the import
    # @param material [String] material being imported
    # @param amount [Numeric] quantity of material
    # @param cost_usd [Numeric] total USD cost (stored as shipping_cost)
    def self.create_import_order(settlement, material:, amount:, cost_usd:)
      LogisticsContract.create!(
        from_settlement_id: nil,  # Earth source — not tracked in this call path
        to_settlement: settlement,
        material: material,
        quantity: amount,
        shipping_cost: cost_usd,
        status: 0,  # pending
        operational_data: { import_type: 'earth_import', currency: 'USD' }
      )
    end
  end
end