class CreateMarketPriceHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :market_price_histories do |t|
      t.references :market_condition, null: false, foreign_key: true
      t.decimal :price

      t.timestamps
    end
  end
end
