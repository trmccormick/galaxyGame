class CreateMarketTrades < ActiveRecord::Migration[7.0]
  def change
    create_table :market_trades do |t|
      t.string :resource
      t.integer :quantity
      t.decimal :price

      t.references :buyer, polymorphic: true, null: false # Polymorphic buyer
      t.references :seller, polymorphic: true, null: false # Polymorphic seller

      t.references :buyer_settlement, null: false, foreign_key: { to_table: :base_settlements } # Explicitly BaseSettlement
      t.references :seller_settlement, null: false, foreign_key: { to_table: :base_settlements } # Explicitly BaseSettlement

      t.timestamps
    end
  end
end
