class AddLayerToMaterials < ActiveRecord::Migration[7.0]
  def change
    add_column :materials, :layer, :string, null: false, default: 'crust'
    add_index :materials, [:celestial_body_id, :layer]
  end
end
