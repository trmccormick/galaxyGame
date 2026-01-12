class CreateMaterialProcessingJobs < ActiveRecord::Migration[7.0]
  def change
    create_table :material_processing_jobs do |t|
      t.references :settlement, null: false, foreign_key: { to_table: :base_settlements }
      t.references :unit, null: false, foreign_key: { to_table: :base_units }
      t.string :processing_type
      t.string :input_material
      t.decimal :input_amount
      t.jsonb :output_materials
      t.string :status
      t.datetime :start_date
      t.datetime :estimated_completion
      t.datetime :completion_date
      t.jsonb :operational_data

      t.timestamps
    end
  end
end
