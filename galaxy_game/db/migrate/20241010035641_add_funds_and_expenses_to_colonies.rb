class AddFundsAndExpensesToColonies < ActiveRecord::Migration[6.0]
  def change
    add_column :colonies, :funds, :decimal, default: 0.0
    add_column :colonies, :expenses, :decimal, default: 0.0
  end
end

