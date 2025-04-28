class CreateMarketTransactionFees < ActiveRecord::Migration[7.0]
  def change
    create_table :market_transaction_fees do |t|

      t.timestamps
    end
  end
end
