class CreateOrbitalConstructionProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :orbital_construction_projects do |t|
      t.references :station, foreign_key: { to_table: :base_settlements }, null: false
      t.string :craft_blueprint_id, null: false
      t.integer :status, default: 0, null: false # materials_pending
      t.float :progress_percentage, default: 0.0
      t.jsonb :required_materials, default: {}
      t.jsonb :delivered_materials, default: {}
      t.datetime :construction_started_at
      t.datetime :completed_at
      t.datetime :estimated_completion_time
      t.jsonb :project_metadata, default: {}

      t.timestamps
    end

    add_index :orbital_construction_projects, :status
    add_index :orbital_construction_projects, [:station_id, :status]
  end
end