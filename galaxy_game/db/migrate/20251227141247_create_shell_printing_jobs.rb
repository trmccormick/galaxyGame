# db/migrate/20251227141247_create_shell_printing_jobs.rb
class CreateShellPrintingJobs < ActiveRecord::Migration[7.0]
  def change
    create_table :shell_printing_jobs do |t|
      t.references :settlement, null: false, foreign_key: { to_table: :base_settlements }
      t.references :printer_unit, null: false, foreign_key: { to_table: :base_units }
      t.references :inflatable_tank, null: false, foreign_key: { to_table: :base_units }
      t.string :status, null: false, default: 'pending'
      t.decimal :production_time_hours, precision: 10, scale: 2, null: false
      t.decimal :progress_hours, precision: 10, scale: 2, default: 0.0
      t.datetime :started_at
      t.datetime :completed_at
      t.jsonb :materials_consumed, default: {}
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :shell_printing_jobs, :status
    add_index :shell_printing_jobs, [:settlement_id, :status]
  end
end