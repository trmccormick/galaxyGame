class UpdateGasForAtmosphere < ActiveRecord::Migration[6.1]
  def change
    # If you no longer want to store gas percentage, you can remove the column
    remove_column :gases, :percentage, :float
  end
end
