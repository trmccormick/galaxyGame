class AddUnitReferenceToInventories < ActiveRecord::Migration[6.0]
  def change
    add_reference :inventories, :unit, foreign_key: { to_table: :base_units }
  end
end
