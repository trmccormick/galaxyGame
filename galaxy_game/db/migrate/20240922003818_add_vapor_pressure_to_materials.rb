class AddVaporPressureToMaterials < ActiveRecord::Migration[7.0]
  def change
    add_column :materials, :vapor_pressure, :float
  end
end
