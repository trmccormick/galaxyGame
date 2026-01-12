class AddWormholeCapacityToSolarSystems < ActiveRecord::Migration[7.0]
  def change
    add_column :solar_systems, :wormhole_capacity, :decimal, precision: 20, scale: 2, default: 0.0, null: false
  end
end