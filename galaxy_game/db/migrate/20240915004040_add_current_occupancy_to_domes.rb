class AddCurrentOccupancyToDomes < ActiveRecord::Migration[7.0]
  def change
    add_column :domes, :current_occupancy, :integer
  end
end
