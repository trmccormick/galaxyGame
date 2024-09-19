class CreateBiomes < ActiveRecord::Migration[7.0]
  def change
    create_table :biomes do |t|
      t.string :name, null: false, unique: true
      t.int4range :temperature_range, null: false
      t.int4range :humidity_range, null: false
      t.text :description

      t.timestamps
    end

    add_index :biomes, :name, unique: true
  end
end
