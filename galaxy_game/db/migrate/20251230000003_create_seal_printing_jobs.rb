# db/migrate/20251230000003_create_seal_printing_jobs.rb
class CreateSealPrintingJobs < ActiveRecord::Migration[7.0]
  def change
    create_table :seal_printing_jobs do |t|
      t.references :settlement, null: false, foreign_key: { to_table: :base_settlements }
      t.references :printer_unit, null: false, foreign_key: { to_table: :base_units }
      t.references :pressurization_target, polymorphic: true, null: false
      t.string :seal_type, null: false
      t.string :status, null: false, default: 'pending'
      t.decimal :production_time_hours, precision: 10, scale: 2, null: false
      t.decimal :progress_hours, precision: 10, scale: 2, default: 0.0
      t.datetime :started_at
      t.datetime :completed_at
      t.jsonb :materials_consumed, default: {}
      t.jsonb :position_data, default: {}
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :seal_printing_jobs, :status
    add_index :seal_printing_jobs, [:settlement_id, :status]
    add_index :seal_printing_jobs, [:pressurization_target_type, :pressurization_target_id], name: 'index_seal_printing_jobs_on_target'
    add_index :seal_printing_jobs, :seal_type
  end
end