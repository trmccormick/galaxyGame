class AddTypeToCelestialBodies < ActiveRecord::Migration[6.1]
  def change
    add_column :celestial_bodies, :type, :string
  end
end
