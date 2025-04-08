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

    add_index :spatial_locations, [:spatial_context_type, :spatial_context_id, :x_coordinate, :y_coordinate, :z_coordinate], unique: true, name: 'unique_3d_position_per_context'
    add_index :spatial_locations, :name
  end
end
