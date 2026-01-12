module Financial
  class VirtualLedgerService
    # Records all NPC-to-NPC transfers for audit trail purposes
    # This allows SystemIntelligenceService to track "off-market" economic activity

    def self.record_transfer(from_account:, to_account:, amount:, currency:, item: nil, description:)
      return unless valid_transfer?(from_account, to_account)

      entry_type = item.present? ? :goods_transfer : :currency_transfer

      # Resolve currency
      resolved_currency = nil
      if entry_type == :currency_transfer
        if currency.is_a?(String)
          resolved_currency = Financial::Currency.find_by(symbol: currency)
        else
          resolved_currency = currency
        end
      end
      # For goods_transfer, currency is nil

      # Resolve item
      resolved_item = nil
      if entry_type == :goods_transfer && item.is_a?(String)
        resolved_item = Item.find_or_create_by(name: item)
      elsif item.is_a?(Item)
        resolved_item = item
      end

      LedgerEntry.create!(
        from_account: from_account,
        to_account: to_account,
        currency: resolved_currency,
        item: resolved_item,
        amount: amount,
        entry_type: entry_type,
        description: description,
        created_at: Time.current
      )
    end

    # Query method for SystemIntelligenceService to analyze off-market activity
    def self.off_market_volume(celestial_body, time_range: nil)
      time_range ||= 30.days.ago..Time.current
      # Simplified: just return total off-market volume for the time range
      LedgerEntry.off_market
                .where(created_at: time_range)
                .sum(:amount)
    end

    # Get transfer summary between specific corporations
    def self.corporate_transfers(from_org:, to_org:, time_range: nil)
      time_range ||= 30.days.ago..Time.current
      from_accounts = Account.where(accountable: from_org)
      to_accounts = Account.where(accountable: to_org)

      LedgerEntry.off_market
                .where(from_account: from_accounts, to_account: to_accounts)
                .where(created_at: time_range)
                .group(:currency_id)
                .sum(:amount)
    end

    # Record in-situ production savings
    def self.record_in_situ_savings(producer:, resource:, amount:, eap_price:)
      savings_usd = amount * eap_price
      savings_gcc = savings_usd / exchange_rate_to_gcc

      # Create ledger entry for savings
      LedgerEntry.create!(
        from_account: nil, # No from account for savings
        to_account: producer.account,
        currency: nil,
        item: Item.find_or_create_by(name: resource),
        amount: savings_gcc,
        entry_type: :in_situ_savings,
        description: "In-situ savings for producing #{amount} kg of #{resource}",
        created_at: Time.current
      )
    end

    private

    def self.valid_transfer?(from_account, to_account)
      return false if from_account.nil? || to_account.nil?
      return false if from_account == to_account
      
      # For currency transfers, check if from_account has sufficient balance
      # (This is a simplified check - in production you'd want more robust validation)
      true
    end

    def self.exchange_rate_to_gcc
      # Assume 1 USD = 100 GCC or something
      100.0
    end
  end
end
