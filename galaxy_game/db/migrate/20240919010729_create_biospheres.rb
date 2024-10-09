class CreateBiospheres < ActiveRecord::Migration[6.1]
  def change
    create_table :biospheres do |t|
      t.references :celestial_body, null: false, foreign_key: true
      t.float :habitable_ratio, default: 0.0, null: false
      t.float :ice_latitude, default: 0.0, null: false
      t.float :biodiversity_index, default: 0.0, null: false
      t.float :temperature_tropical, default: 273.15 # Assuming Kelvin
      t.float :temperature_polar, default: 273.15 # Assuming Kelvin

      # Optional: Consider adding fields to track biome diversity or additional attributes
      t.integer :biome_count, default: 0, null: false # To keep track of the number of biomes
      t.text :biome_distribution # To store information about biome distribution if needed

      t.timestamps
    end
  end
end
