class AddAtmosphereToCelestialBodies < ActiveRecord::Migration[7.0]
  def change
    add_column :celestial_bodies, :gases, :jsonb, default: '{}'
    add_column :celestial_bodies, :pressure, :float, default: 0
    add_column :celestial_bodies, :temperature, :float, default: 0
  end
end
