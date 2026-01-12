module Market
  class PurchaseService
    def self.execute(player:, npc_entity:, item_price:, description:)
      # 1. Fetch the relevant accounts
      gcc = Financial::Currency.find_by!(symbol: 'GCC')
      player_account = player.accounts.find_by!(currency: gcc)
      npc_account = npc_entity.accounts.find_by!(currency: gcc)

      # 2. Execute the financial movement
      # Using the transfer_funds method you already have in account.rb
      Financial::Account.transaction do
        player_account.transfer_funds(item_price, npc_account, description)

        # 3. IMMEDIATELY trigger your existing settlement logic
        # This clears the NPC's "Virtual Ledger" debt using their USD reserves
        Financial::SettlementService.liquidate_npc_debt(npc_entity)
      end
    rescue => e
      # Handle insufficient funds or transaction errors here
      Rails.logger.error "Purchase failed: #{e.message}"
      raise e
    end
  end
end