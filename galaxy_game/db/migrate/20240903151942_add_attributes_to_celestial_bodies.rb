class AddAttributesToCelestialBodies < ActiveRecord::Migration[6.1]
  def change
    change_table :celestial_bodies do |t|
      t.float :mass
      t.float :radius
      t.float :distance_from_sun
    end
  end
end

