class CreateComputers < ActiveRecord::Migration[6.1]
  def change
    create_table :computers do |t|
      t.references :colony, foreign_key: true
      t.decimal :mining_power, precision: 10, scale: 2, null: false # GCC output/day
      t.timestamps
    end
  end
end
