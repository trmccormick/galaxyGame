class AddCapacityToInventories < ActiveRecord::Migration[7.0]
  def change
    add_column :inventories, :capacity, :integer
  end
end
