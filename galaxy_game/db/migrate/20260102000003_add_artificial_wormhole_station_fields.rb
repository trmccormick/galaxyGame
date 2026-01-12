class AddArtificialWormholeStationFields < ActiveRecord::Migration[7.0]
  def change
    add_column :wormholes, :artificial_station_built, :boolean, default: false, null: false
    add_column :wormholes, :station_built_at, :datetime
    add_column :wormholes, :required_exotic_matter, :decimal, precision: 15, scale: 2, default: 0.0
    add_column :wormholes, :required_construction_materials, :jsonb, default: {}
  end
end