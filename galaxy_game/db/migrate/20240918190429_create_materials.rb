class CreateMaterials < ActiveRecord::Migration[7.0]
  def change
    create_table :materials do |t|
      t.string :name
      t.float :amount
      t.float :boiling_point
      t.float :melting_point
      t.string :state_at_room_temp
      t.integer :state, default: 0, null: false
      t.integer :location, default: 0, null: false  # Add location field as enum
      t.boolean :is_volatile, default: false        # Add is_volatile field for extraction
      t.references :materializable, polymorphic: true, index: true
      t.references :celestial_body, foreign_key: true
      t.timestamps
    end
    
    add_index :materials, :location  # Add index for location for faster queries
  end
end
