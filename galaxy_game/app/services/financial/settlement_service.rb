module Financial
  class SettlementService
    def self.liquidate_npc_debt(npc_entity)
      gcc_account = npc_entity.accounts.find_by(currency: Currency.find_by(symbol: 'GCC'))
      usd_account = npc_entity.accounts.find_by(currency: Currency.find_by(symbol: 'USD'))

      return unless gcc_account.balance < 0 && usd_account.balance > 0

      # During Bootstrap: 1 GCC = 1 USD
      debt_amount = gcc_account.balance.abs
      settlement_amount = [debt_amount, usd_account.balance].min

      Account.transaction do
        # 1. Withdraw USD (Earth payment for imports)
        usd_account.withdraw(settlement_amount, "Currency conversion to clear local GCC debt")
        
        # 2. Deposit GCC (Effectively "minting" GCC backed by the USD import value)
        gcc_account.deposit(settlement_amount, "Liquidation of ledger debt via Earth USD reserves")
      end
    end
  end
end