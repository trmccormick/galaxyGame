class ChangeMassToStringInCelestialBodies < ActiveRecord::Migration[7.0]
  def change
    change_column :celestial_bodies, :mass, :string
  end
end
