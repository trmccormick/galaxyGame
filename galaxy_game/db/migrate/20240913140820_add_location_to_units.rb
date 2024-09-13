class AddLocationToUnits < ActiveRecord::Migration[7.0]
  def change
    add_column :units, :location_type, :string
    add_column :units, :location_id, :integer
  end
end
