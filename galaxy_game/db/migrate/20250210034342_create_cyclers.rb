class CreateCyclers < ActiveRecord::Migration[7.0]
  def change
    create_table :cyclers do |t|
      t.string :cycler_type
      t.integer :orbital_period
      t.datetime :last_encounter_date
      t.string :current_trajectory_phase
      t.integer :maximum_docking_capacity
      t.jsonb :encounter_schedule
      t.references :base_craft, null: false, foreign_key: true

      t.timestamps
    end
  end
end
