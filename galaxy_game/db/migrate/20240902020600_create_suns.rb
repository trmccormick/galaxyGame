class CreateSuns < ActiveRecord::Migration[7.0]
  def change
    create_table :suns do |t|
      t.string :identifier, null: false, index: { unique: true }
      t.string :name
      t.string :sun_type
      t.float :age
      t.float :mass
      t.float :radius
      t.float :solar_constant
      t.integer :discovery_state

      t.timestamps
    end
  end
end
