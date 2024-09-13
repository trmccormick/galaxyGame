class RemoveTotalPressureFromCelestialBodies < ActiveRecord::Migration[7.0]
  def change
    remove_column :celestial_bodies, :total_pressure, :float
  end
end
