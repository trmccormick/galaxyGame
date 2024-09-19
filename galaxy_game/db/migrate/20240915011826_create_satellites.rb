class CreateSatellites < ActiveRecord::Migration[6.1]
  def change
    create_table :satellites do |t|
      t.references :colony, foreign_key: true
      t.decimal :mining_output, precision: 10, scale: 2 # GCC output/day
      t.timestamps
    end
  end
end
