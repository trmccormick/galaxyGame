# db/migrate/YYYYMMDDHHMMSS_create_currencies.rb
class CreateCurrencies < ActiveRecord::Migration[6.0]
  def change
    create_table :currencies do |t|
      t.string :name, null: false # Full name, e.g., "Martian Global Coin"
      t.string :symbol, null: false # Short code, e.g., "MGC"
      t.boolean :is_system_currency, null: false, default: false # True for USD, GCC, etc.
      t.integer :precision # How many decimal places for this currency (e.g., 2 for USD, 8 for crypto)

      # Optional: If currencies can be issued by players/colonies
      t.references :issuer, polymorphic: true, optional: true

      t.timestamps
    end
    add_index :currencies, :symbol, unique: true
    add_index :currencies, :name, unique: true
  end
end