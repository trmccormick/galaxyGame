class CreatePlants < ActiveRecord::Migration[7.0]
  def change
    create_table :plants do |t|
      t.string :name
      t.daterange :growth_temperature_range
      t.daterange :growth_humidity_range
      t.text :description

      t.timestamps
    end
  end
end
