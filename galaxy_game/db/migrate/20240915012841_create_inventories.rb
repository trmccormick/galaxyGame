class CreateInventories < ActiveRecord::Migration[7.0]
  def change
    create_table :inventories do |t|
      t.references :colony, foreign_key: true
      t.string :name, null: false
      t.integer :material_type, null: false  # Assuming you use an enum
      t.integer :quantity, default: 0

      t.timestamps
    end
  end
end