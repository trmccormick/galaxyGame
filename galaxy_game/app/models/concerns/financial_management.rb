# app/models/concerns/financial_management.rb
module FinancialManagement
    extend ActiveSupport::Concern
  
    included do
      validates :funds, numericality: { greater_than_or_equal_to: 0 }
      validates :expenses, numericality: { greater_than_or_equal_to: 0 }
      has_one :account # Assuming each entity has one account for managing funds
    end
  
    # Method to update the funds and expenses
    def manage_expenses(cost)
      if can_afford?(cost)
        self.funds -= cost
        self.expenses += cost
        puts "Current funds: #{funds}. Total expenses: #{expenses}."
      else
        puts "Insufficient funds to cover the cost of #{cost}."
      end
    end
  
    # Check if the account has sufficient funds
    def can_afford?(amount)
      funds >= amount
    end
  
    # Method to update balance with mined funds
    def update_balance(amount)
      self.funds += amount
      account.update(balance: account.balance + amount) if account.present?
    end
end
  
  