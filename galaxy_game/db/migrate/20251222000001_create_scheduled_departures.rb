class CreateScheduledDepartures < ActiveRecord::Migration[7.0]
  def change
    create_table :scheduled_departures do |t|
      t.references :cycler, null: false, foreign_key: { to_table: :cyclers }
      t.timestamps
    end
  end
end