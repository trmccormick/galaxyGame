class AddCurrencyToAccounts < ActiveRecord::Migration[7.0]
  def change
    add_reference :accounts, :currency, null: false, foreign_key: true, default: 1
  end
end
