class CreateBiomes < ActiveRecord::Migration[7.0]
  def change
    create_table :biomes do |t|
      t.string :name, null: false, unique: true
      t.int4range :temperature_range, null: false
      t.int4range :humidity_range, null: false
      t.text :description
      t.string :climate_type  # Add climate_type for biome category
      t.boolean :supports_vegetation, default: true
      t.float :base_productivity, default: 1.0  # Baseline productivity factor

      t.timestamps
    end

    add_index :biomes, :name, unique: true
  end
end
