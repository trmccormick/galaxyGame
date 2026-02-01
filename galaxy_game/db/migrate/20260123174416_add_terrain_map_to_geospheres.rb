class AddTerrainMapToGeospheres < ActiveRecord::Migration[7.0]
  def change
    add_column :geospheres, :terrain_map, :jsonb
  end
end
