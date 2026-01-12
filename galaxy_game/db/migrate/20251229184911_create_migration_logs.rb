class CreateMigrationLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :migration_logs do |t|
      t.references :unit, null: false, foreign_key: { to_table: :base_units }
      t.references :robot, null: false, foreign_key: { to_table: :base_units }
      t.integer :source_location_id
      t.string :source_location_type
      t.integer :target_location_id
      t.string :target_location_type
      t.string :migration_type
      t.datetime :performed_at

      t.timestamps
    end
  end
end
