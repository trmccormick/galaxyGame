class CreatePlanetBiomes < ActiveRecord::Migration[6.1]
  def change
    create_table :planet_biomes do |t|
      t.references :biome, null: false, foreign_key: true
      t.references :biosphere, null: false, foreign_key: true
      t.timestamps
    end
  end
end
