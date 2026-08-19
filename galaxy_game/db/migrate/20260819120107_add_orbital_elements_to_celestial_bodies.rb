class AddOrbitalElementsToCelestialBodies < ActiveRecord::Migration[7.0]
  def change
    add_column :celestial_bodies, :orbital_elements, :jsonb, default: {}, null: false
  end
end
