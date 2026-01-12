class CreateLogisticsProviders < ActiveRecord::Migration[7.0]
  def change
    create_table :logistics_providers do |t|
      t.string :name, null: false
      t.string :identifier, null: false
      t.decimal :base_fee_per_kg, precision: 10, scale: 4, default: 1.0, null: false
      t.integer :reliability_rating, default: 3, null: false
      t.decimal :speed_multiplier, precision: 5, scale: 2, default: 1.0, null: false
      t.references :owner, polymorphic: true, null: false

      t.timestamps
    end
    add_index :logistics_providers, :name, unique: true
    add_index :logistics_providers, :identifier, unique: true
  end
end
