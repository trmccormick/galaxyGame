class CreateBaseSettlements < ActiveRecord::Migration[7.0]
  def change
    create_table :base_settlements do |t|
      t.string :name
      t.integer :current_population, default: 0  # Ensure this line exists
      t.integer :settlement_type, default: 0
      t.references :colony, null: true, foreign_key: true
      t.references :accounts, null: true, foreign_key: true
      t.references :base_settlements, :owner, polymorphic: true, index: true
      # Lavatube specific fields
      t.integer :length, null: true
      t.integer :diameter, null: true
      t.float :usable_area

      t.timestamps
    end
  end
end
