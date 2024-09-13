class CreatePlanets < ActiveRecord::Migration[7.0]
  def change
    create_table :planets do |t|
      t.string :name
      t.decimal :size
      t.decimal :gravity, precision: 10, scale: 2
      t.decimal :density, precision: 10, scale: 2
      t.decimal :orbital_period, precision: 10, scale: 2
      t.jsonb :atmosphere, default: {}
      t.float :total_pressure
      t.jsonb :gas_quantities, default: {}
      t.jsonb :materials, default: {}
      t.float :water_volume

      t.timestamps
    end
  end
end
