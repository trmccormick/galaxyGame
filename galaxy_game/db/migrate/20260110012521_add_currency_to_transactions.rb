class AddCurrencyToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_reference :transactions, :currency, null: false, foreign_key: true, default: 1
  end
end
