# app/models/settlement/colony.rb
module Settlement
  class Colony < ApplicationRecord
    include FinancialManagement

    has_many :cities
    has_many :outposts
    has_many :domes
    has_many :habitats
    has_many :inventories

    validates :name, presence: true
    validates :funds, numericality: { greater_than_or_equal_to: 0 }
    validates :expenses, numericality: { greater_than_or_equal_to: 0 }

    # Method to manage expenses
    def manage_expenses(cost)
      self.funds -= cost
      self.expenses += cost
      puts "Current funds: #{funds}. Total expenses: #{expenses}."
    end

    # Method to check if the colony can afford a specified amount
    def can_afford?(amount)
      funds >= amount
    end

    # Method to calculate total population across all settlements
    def total_population
      cities.sum(:current_population) + outposts.sum(:current_population) + domes.sum(:current_population) + habitats.sum(:current_population)
    end

    # Other colony-specific methods...
  end
end

