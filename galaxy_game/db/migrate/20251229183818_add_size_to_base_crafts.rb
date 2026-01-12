class AddSizeToBaseCrafts < ActiveRecord::Migration[7.0]
  def change
    add_column :base_crafts, :size, :decimal
  end
end
