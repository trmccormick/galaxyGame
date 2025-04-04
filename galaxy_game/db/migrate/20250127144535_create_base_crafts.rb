class CreateBaseCrafts < ActiveRecord::Migration[7.0]
  def change
      create_table :base_crafts do |t|
          t.string :name, null: false
          t.string :craft_name, null: false # to correctly find the blueprint and operational data
          t.string :craft_type, null: false
          t.integer :current_population
          t.boolean :deployed, default: false
          t.string :current_location
          t.jsonb :operational_data, default: {} # Add this line
          
          # Polymorphic association for owner
          t.references :owner, polymorphic: true, null: true
          
          # Player reference
          t.references :player, null: true, foreign_key: true

          # Settlement reference
          t.references :docked_at, foreign_key: { to_table: :base_settlements }

          t.timestamps
      end

      add_index :base_crafts, :craft_type
      add_index :base_crafts, :name
      add_index :base_crafts, :operational_data, using: :gin # Add this line
  end
end
