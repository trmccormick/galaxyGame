class CreateMarketOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :market_orders do |t|
      t.references :market_condition, null: false, foreign_key: true
      t.references :orderable, polymorphic: true, null: false # Polymorphic association
      t.references :base_settlement, null: false, foreign_key: { to_table: :base_settlements } # Settlement of origin

      t.string :resource
      t.integer :quantity
      t.integer :order_type

      t.timestamps
    end
  end
end
