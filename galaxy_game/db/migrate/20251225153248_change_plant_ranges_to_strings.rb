class ChangePlantRangesToStrings < ActiveRecord::Migration[7.0]
  def change
    change_column :plants, :growth_temperature_range, :string
    change_column :plants, :growth_humidity_range, :string
  end
end
