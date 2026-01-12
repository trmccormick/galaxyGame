class AddPropertiesToCelestialBodiesMaterials < ActiveRecord::Migration[7.0]
  def change
    add_column :celestial_bodies_materials, :properties, :jsonb, default: {}
  end
end