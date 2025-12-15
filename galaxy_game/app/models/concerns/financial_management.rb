module FinancialManagement
  extend ActiveSupport::Concern

  included do
    has_one :account, as: :accountable, dependent: :destroy, class_name: 'Financial::Account'
    after_create :create_account
  end

  # Economy methods that delegate to account
  def can_afford?(amount)
    account&.balance.to_f >= amount.to_f
  end
  
  def charge(amount, description = nil)
    raise "No account found" unless account
    account.withdraw(amount, description || "Charge")
  end
  
  def credit(amount, description = nil)
    raise "No account found" unless account  
    account.deposit(amount, description || "Credit")
  end
  
  def balance
    account&.balance || 0
  end

  # Legacy methods for backwards compatibility
  def manage_expenses(cost, description = "Expense")
    if can_afford?(cost)
      charge(cost, description)
      puts "Current balance: #{balance}."
      true
    else
      puts "Insufficient funds to cover the cost of #{cost}."
      false
    end
  end

  # Update balance - now delegates to account
  def update_balance(amount, description = "Balance update")
    if amount >= 0
      credit(amount, description)
    else
      charge(amount.abs, description)
    end
  end

  private

  def create_account
    return if account.present?

    # Find the default currency (GCC)
    default_currency = Financial::Currency.find_by(symbol: 'GCC')
    raise "Default currency (GCC) not found. Please seed currencies." unless default_currency

    # Set starting balance based on entity type
    starting_balance = case self
                      when Player then 1_000
                      when Organizations::BaseOrganization then 50_000
                      when Settlement::BaseSettlement then 10_000
                      else 100
                      end

    build_account(balance: starting_balance, currency: default_currency, lock_version: 0).save!
  end
end
