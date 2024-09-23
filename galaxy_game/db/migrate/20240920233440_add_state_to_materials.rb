class AddStateToMaterials < ActiveRecord::Migration[6.1]
  def change
    add_column :materials, :state, :string, default: "solid"
  end
end
