class AddStatusToCelestialBodies < ActiveRecord::Migration[6.1]
  def change
    add_column :celestial_bodies, :status, :integer, default: 0, null: false
  end
end
