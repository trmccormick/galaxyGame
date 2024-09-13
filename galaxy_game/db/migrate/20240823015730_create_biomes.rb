class CreateBiomes < ActiveRecord::Migration[7.0]
  def change
    create_table :biomes do |t|
      t.string :name
      t.daterange :temperature_range
      t.daterange :humidity_range
      t.text :description

      t.timestamps
    end
  end
end
