class CreateUnitAssemblyJobs < ActiveRecord::Migration[7.0]
  def change
    create_table :unit_assembly_jobs do |t|
      t.references :base_settlement, null: false, foreign_key: true
      t.references :owner, polymorphic: true, index: true
      t.string :unit_type, null: false
      t.integer :count, default: 1
      t.string :status, default: 'pending'
      t.string :priority, default: 'normal'
      t.string :blueprint_id
      t.jsonb :specifications, default: {}
      t.datetime :start_date
      t.datetime :completion_date
      t.datetime :estimated_completion
      
      t.timestamps
    end
    
    add_index :unit_assembly_jobs, [:unit_type, :status]
  end
end
