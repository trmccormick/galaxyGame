class IncreaseFinancialPrecisionForGcc < ActiveRecord::Migration[7.0]
  def up
    # Increase precision for GCC micro-transactions (cryptocurrency-style)
    # From scale: 2 (0.12) → scale: 8 (0.12345678)
    change_column :transactions, :amount, :decimal, precision: 15, scale: 8
    change_column :accounts, :balance, :decimal, precision: 20, scale: 8
  end

  def down
    # Revert to 2 decimal places (standard fiat currency precision)
    change_column :transactions, :amount, :decimal, precision: 15, scale: 2
    change_column :accounts, :balance, :decimal, precision: 20, scale: 2
  end
end
