class RemoveStructureForeignKeyFromAtmospheres < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :atmospheres, :structures
  end
end
