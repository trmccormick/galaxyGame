class AddStructureToAtmospheres < ActiveRecord::Migration[7.0]
  def change
    add_column :atmospheres, :structure_type, :string
    add_index :atmospheres, [:structure_type, :structure_id]
  end
end