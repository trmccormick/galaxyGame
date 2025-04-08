# db/migrate/20240915023023_create_spatial_locations.rb
class CreateSpatialLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :spatial_locations do |t|
      t.string :name, null: false
      t.float :x_coordinate, null: false
      t.float :y_coordinate, null: false
      t.float :z_coordinate, null: false
      t.references :locationable, polymorphic: true
      t.references :spatial_context, polymorphic: true, null: true

      t.timestamps
    end

    add_index :spatial_locations, [:x_coordinate, :y_coordinate, :z_coordinate], unique: true, name: "index_spatial_locations_on_xyz"
    add_index :spatial_locations, :name
  end
end
