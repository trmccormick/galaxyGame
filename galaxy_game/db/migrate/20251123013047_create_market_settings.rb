class CreateMarketSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :market_settings do |t|
      t.decimal :transportation_cost_per_kg

      t.timestamps
    end
  end
end
