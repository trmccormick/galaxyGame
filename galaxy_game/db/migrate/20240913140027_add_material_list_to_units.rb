class AddMaterialListToUnits < ActiveRecord::Migration[7.0]
  def change
    add_column :units, :material_list, :json
  end
end
