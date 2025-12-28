# db/migrate/20251226153737_create_component_production_jobs.rb
class CreateComponentProductionJobs < ActiveRecord::Migration[7.0]
  def change
    create_table :component_production_jobs do |t|
      t.references :settlement, null: false, foreign_key: { to_table: :base_settlements }
      t.references :printer_unit, null: false, foreign_key: { to_table: :base_units }
      t.string :component_blueprint_id, null: false
      t.string :component_name, null: false
      t.integer :quantity, null: false, default: 1
      t.string :status, null: false, default: 'pending'
      t.decimal :production_time_hours, precision: 10, scale: 2, null: false
      t.decimal :progress_hours, precision: 10, scale: 2, default: 0.0
      t.datetime :started_at
      t.datetime :completed_at
      t.jsonb :materials_consumed, default: {}
      t.decimal :import_cost_gcc, precision: 10, scale: 2, default: 0.0
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :component_production_jobs, :status
    add_index :component_production_jobs, :component_blueprint_id
    add_index :component_production_jobs, [:settlement_id, :status]
  end
end