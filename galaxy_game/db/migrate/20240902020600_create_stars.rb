class CreateStars < ActiveRecord::Migration[7.0]  # ✅ This should match filename
  def change
    create_table :stars do |t|
      t.string :identifier, null: false, index: { unique: true }
      t.string :name
      t.string :type_of_star
      t.float :age
      t.float :mass
      t.float :radius
      t.integer :discovery_state
      t.jsonb :properties, default: {}, null: false
      
      t.timestamps
    end
  end
end
