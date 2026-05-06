class CreateJobs < ActiveRecord::Migration[6.1]
  def change
    create_table :jobs do |t|
      t.references :owner, polymorphic: true, null: false
      t.references :settlement, null: false, foreign_key: { to_table: :base_settlements }
      t.references :blueprint, null: true, foreign_key: { to_table: :blueprints }
      t.integer :job_type, null: false
      t.integer :status, default: 0, null: false
      t.string :output_type, null: false
      t.datetime :start_date, null: true
      t.datetime :completes_at, null: false
      t.jsonb :operational_data, null: true
      t.timestamps
    end
  end
end
