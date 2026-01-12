class CreateExchangeRates < ActiveRecord::Migration[7.0]
  def change
    create_table :exchange_rates do |t|
      t.references :from_currency, null: false, foreign_key: { to_table: :currencies }
      t.references :to_currency, null: false, foreign_key: { to_table: :currencies }
      t.decimal :rate, precision: 15, scale: 8, null: false

      t.timestamps
    end

    add_index :exchange_rates, [:from_currency_id, :to_currency_id], unique: true
  end
end
