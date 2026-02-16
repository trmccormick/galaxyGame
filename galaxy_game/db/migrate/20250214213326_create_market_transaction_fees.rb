class CreateMarketTransactionFees < ActiveRecord::Migration[7.0]
  def change
    create_table :market_transaction_fees do |t|
      t.string :fee_type, null: false
      t.decimal :percentage, precision: 5, scale: 2
      t.decimal :fixed_amount, precision: 15, scale: 2

      t.timestamps
    end
  end
end
