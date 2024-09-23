class AddMeltingPointAndBoilingPointToMaterials < ActiveRecord::Migration[7.0]
  def change
    add_column :materials, :melting_point, :float
    add_column :materials, :boiling_point, :float
  end
end
