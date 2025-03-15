class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      # Basic attributes
      t.string :name, null: false
      t.string :description, null: true
      t.decimal :amount, precision: 10, scale: 2, default: 0, null: false
      
      # Classification and storage
      t.integer :material_type, null: false, default: 0  # Enum for item categorization
      t.integer :storage_method, null: false, default: 0  # Enum for storage type

      # New attributes for enhanced functionality
      t.decimal :total_weight, precision: 10, scale: 2, default: 0, null: false  # For weight tracking
      t.decimal :volume, precision: 10, scale: 2, default: 0, null: true         # For volume tracking
      t.integer :durability, null: true                                            # Optional durability for wear tracking
      t.jsonb :metadata, default: {}                                               # Flexible metadata for additional properties
      t.string :origin_world, null: true                                           # Tracks planetary origin
      t.datetime :extraction_date, null: true                                       # Tracks resource collection date

      # Associations
      t.references :inventory, null: true, foreign_key: { to_table: :inventories }
      t.references :container, null: true, foreign_key: { to_table: :items }
      t.references :owner, polymorphic: true, null: false  # Settlement, Player, etc owns the item
      t.references :storage_unit, polymorphic: true, null: true  # Optional storage unit reference

      t.timestamps
    end
  end
end
