class AllowNullNameOnSolarSystems < ActiveRecord::Migration[7.0]
  def change
    change_column_null :solar_systems, :name, true
  end
end
