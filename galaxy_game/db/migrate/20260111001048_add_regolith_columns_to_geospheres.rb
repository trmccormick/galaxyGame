class AddRegolithColumnsToGeospheres < ActiveRecord::Migration[7.0]
  def change
    add_column :geospheres, :regolith_depth, :float, default: 0.0
    add_column :geospheres, :regolith_particle_size, :float, default: 0.0
    add_column :geospheres, :weathering_rate, :float, default: 0.0
    add_column :geospheres, :plates, :jsonb, default: {}
    add_column :geospheres, :stored_volatiles, :json
    add_column :geospheres, :ice_tectonic_enabled, :boolean, default: false
    add_column :geospheres, :total_geosphere_mass, :float, default: 0.0
  end
end
