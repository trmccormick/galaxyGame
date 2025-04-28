class AddAttributesToCelestialBodies < ActiveRecord::Migration[6.1]
  def change
    change_table :celestial_bodies do |t|
      t.decimal :mass, precision: 38, scale: 10
      t.float :radius
    end
  end
end

