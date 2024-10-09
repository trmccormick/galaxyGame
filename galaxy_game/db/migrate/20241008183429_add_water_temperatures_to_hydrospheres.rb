class AddWaterTemperaturesToHydrospheres < ActiveRecord::Migration[7.0]
  def change
    add_column :hydrospheres, :ocean_temp, :float
    add_column :hydrospheres, :lake_temp, :float
    add_column :hydrospheres, :river_temp, :float
    add_column :hydrospheres, :ice_temp, :float
  end
end
