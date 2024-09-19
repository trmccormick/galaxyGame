class AddGeosphereToCelestialBodies < ActiveRecord::Migration[7.0]
  def change
    add_column :celestial_bodies, :crust, :jsonb, default: '{}'
    add_column :celestial_bodies, :mantle, :jsonb, default: '{}'
    add_column :celestial_bodies, :core, :jsonb, default: '{}'
  end
end
