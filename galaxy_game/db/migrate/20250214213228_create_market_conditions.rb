class CreateMarketConditions < ActiveRecord::Migration[7.0]
  def change
    create_table :market_conditions do |t|
      t.references :market_marketplace, null: false, foreign_key: true
      t.string :resource
      t.decimal :price
      t.integer :supply
      t.integer :demand
      t.timestamps
    end
  end
end