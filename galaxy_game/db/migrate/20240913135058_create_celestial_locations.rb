# db/migrate/20240913135058_create_celestial_locations.rb
class CreateCelestialLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :celestial_locations do |t|
      t.string :name, null: false
      t.string :coordinates, null: false
      t.references :locationable, polymorphic: true
      t.references :celestial_body, null: false, foreign_key: true

      t.timestamps
    end

    add_index :celestial_locations, [:celestial_body_id, :coordinates], unique: true, name: 'unique_coordinates_per_celestial_body'
    add_index :celestial_locations, :name
  end
end