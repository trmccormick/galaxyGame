class CreateConstructionJobs < ActiveRecord::Migration[7.0]
  def change
    create_table :construction_jobs do |t|
      t.references :jobable, polymorphic: true, null: false, index: true
      t.references :settlement, foreign_key: { to_table: :base_settlements }, null: false

      # FIX: Change to integer for Rails enum functionality
      # The default '0' here corresponds to the first value in your enum definition
      t.integer :job_type, null: false, default: 0 # Assuming 'crater_dome_construction' is 0

      # FIX: Change to integer for Rails enum functionality
      t.integer :status, default: 0, null: false # Assuming 'scheduled' is 0

      t.jsonb :target_values, default: {}
      t.datetime :start_date
      t.datetime :completion_date
      t.datetime :estimated_completion

      # Consideration: If 'priority' is also going to be an enum, it should also be 'integer'
      # If it's just a free-form string, then 'string' is fine.
      t.string :priority, default: 'normal'

      t.integer :completion_percentage, default: 0
      t.references :blueprint, foreign_key: true

      t.timestamps
    end

    add_index :construction_jobs, [:job_type, :status]
    add_index :construction_jobs, :status
  end
end
