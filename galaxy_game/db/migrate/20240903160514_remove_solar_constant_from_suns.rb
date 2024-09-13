class RemoveSolarConstantFromSuns < ActiveRecord::Migration[7.0]
  def change
    remove_column :suns, :solar_constant, :decimal
  end
end
