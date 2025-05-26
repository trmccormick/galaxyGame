class CreateSuns < ActiveRecord::Migration[7.0]
  def change
    create_table :suns do |t|
      t.string :identifier, null: false, index: { unique: true }
      t.string :name
      t.string :type_of_star
      t.float :age
      t.float :mass
      t.float :radius
      t.integer :discovery_state
      t.jsonb :properties, default: {}, null: false  # Add this flexible properties field

      t.timestamps
    end
  end
end
