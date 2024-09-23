class CreateCelestialBodiesMaterials < ActiveRecord::Migration[6.1]
  def change
    create_table :celestial_bodies_materials do |t|
      t.references :celestial_body, foreign_key: true
      t.references :material, foreign_key: true
      t.float :amount, default: 0.0
      t.string :state, default: "solid"

      t.timestamps
    end
  end
end