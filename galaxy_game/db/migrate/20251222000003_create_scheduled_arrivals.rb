class CreateScheduledArrivals < ActiveRecord::Migration[7.0]
  def change
    create_table :scheduled_arrivals do |t|
      t.references :cycler, null: false, foreign_key: true

      t.timestamps
    end
  end
end
