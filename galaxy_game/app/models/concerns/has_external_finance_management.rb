module HasExternalFinanceManagement
  extend ActiveSupport::Concern

  # This concern manages financial operations related to *external* (fiat) currencies 
  # (e.g., USD, EUR). It is intended for corporate entities (Settlements/Organizations)
  # that must manage debt and revenue streams originating outside the game's core GCC economy.
  #
  # It complements the standard FinancialManagement concern, which typically focuses 
  # on the entity's primary, transactional GCC account. This module adds the specialized
  # logic for debt establishment, structured revenue collection ticks, and complex 
  # cash flow-based import approval (gatekeeping).
  #
  # Establishes the initial balance for an external (fiat) currency account.
  # For LDC, this is the initial USD debt (a negative amount). For other corporations, 
  # it could be starting capital (a positive amount).
  #
  # @param currency_symbol [String] The symbol of the fiat currency (e.g., 'USD').
  # @param initial_amount [Float] The starting balance (negative for debt).
  def establish_initial_fiat_balance(currency_symbol: 'USD', initial_amount: nil)
    fiat_currency = Currency.find_by!(symbol: currency_symbol)
    fiat_account = Account.find_or_create_for_entity_and_currency(
      accountable_entity: self,
      currency: fiat_currency
    )

    # Use default LDC debt if not specified (for setup consistency)
    debt_amount = initial_amount || -4_050_000_000.00
    
    # Use deposit/withdraw to create an initial transaction log entry.
    if debt_amount.positive?
      fiat_account.deposit(debt_amount, "Initial #{currency_symbol} Capital")
    elsif debt_amount.negative?
      # Withdraw the absolute amount to set the initial debt balance
      fiat_account.withdraw(debt_amount.abs, "Initial #{currency_symbol} Debt (Project Start)")
    end

    Rails.logger.info "[Financials] #{currency_symbol} Account initialized with balance: #{fiat_account.balance.to_f} #{currency_symbol}"
    fiat_account
  end

  # Simulates the corporation collecting external (fiat) revenue from assets 
  # (e.g., Earth contracts, data sales, external resource pipelines).
  # This is the mechanism for servicing fiat debt (like LDC's USD debt).
  def collect_external_fiat_revenue(currency_symbol: 'USD')
    # Use a lookup for the corporation's external revenue target, defaulting to LDC's USD stream.
    # Annual Revenue Target for LDC: $1.2 Billion / year
    annual_revenue_target = self.corporation_data&.dig('external_revenue_usd') || 1_200_000_000.00
    
    # Assuming a 4-hour job interval (matching MineGccJob)
    daily_ticks = 24 / 4 
    revenue_per_tick = annual_revenue_target / 365.0 / daily_ticks
    
    fiat_account = find_fiat_account(currency_symbol)
    
    if fiat_account
      fiat_account.deposit(revenue_per_tick, "External Revenue Stream")
      Rails.logger.info "[Financials] Collected #{'%.2f' % revenue_per_tick} #{currency_symbol}. Current Balance: #{fiat_account.balance.to_f}"
      revenue_per_tick
    else
      Rails.logger.warn "[Financials] #{currency_symbol} Account not found. Revenue not collected."
      0.0
    end
  end

  # The Financial Gatekeeper for external (fiat) currency imports.
  # Checks if the corporation's current fiat balance can cover the import cost
  # while respecting defined debt limits.
  #
  # @param cost_fiat [Float] The total cost of the item to import.
  # @param currency_symbol [String] The symbol of the fiat currency being spent.
  # @return [Boolean] True if the import can be afforded/approved.
  def can_afford_fiat_import?(cost_fiat, currency_symbol: 'USD')
    fiat_account = find_fiat_account(currency_symbol)
    return false unless fiat_account

    current_balance = fiat_account.balance.to_f
    
    # Use a lookup for maximum allowed debt, defaulting to LDC's limit.
    max_allowed_debt = self.corporation_data&.dig('max_fiat_debt') || 4_500_000_000.00
    safety_buffer = self.corporation_data&.dig('min_debt_spend_threshold') || 1_000_000_000.00
    
    # Rule 1: Deep Debt Check (Debt > Safety Buffer)
    if current_balance < -safety_buffer
      # If heavily in debt, only allow small, critical purchases.
      is_critical_maintenance = cost_fiat < 100_000.00 # Example small budget
      
      unless is_critical_maintenance
        Rails.logger.warn "[Financial Gatekeeper] BLOCKED: #{currency_symbol} Debt too high (#{current_balance} #{currency_symbol}). Import cost: #{cost_fiat}."
        return false
      end
    end
    
    # Rule 2: Absolute Debt Limit Check
    # Ensure the transaction won't push the debt below the absolute allowed minimum balance.
    if current_balance - cost_fiat < -max_allowed_debt 
      Rails.logger.warn "[Financial Gatekeeper] BLOCKED: Import would exceed absolute debt limit (-#{max_allowed_debt} #{currency_symbol}). Cost: #{cost_fiat}."
      return false
    end
    
    true
  end
  
  private

  # Utility method to locate the corporation's fiat account
  def find_fiat_account(currency_symbol)
    fiat_currency = Currency.find_by(symbol: currency_symbol)
    Account.find_by(accountable: self, currency: fiat_currency)
  end
end