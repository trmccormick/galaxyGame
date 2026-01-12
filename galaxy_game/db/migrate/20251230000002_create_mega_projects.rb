class CreateMegaProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :mega_projects do |t|
      t.string :name, null: false
      t.integer :project_type, default: 0, null: false
      t.integer :status, default: 0, null: false
      t.references :settlement, foreign_key: { to_table: :base_settlements }, null: false
      t.references :project_manager, foreign_key: { to_table: :players }, null: true
      t.datetime :deadline, null: false
      t.decimal :budget_gcc, precision: 15, scale: 2, null: false
      t.jsonb :material_requirements, default: {}, null: false
      t.jsonb :progress_data, default: {}, null: false
      t.jsonb :project_metadata, default: {}, null: false

      t.timestamps
    end

    add_index :mega_projects, :status
    add_index :mega_projects, :project_type
    add_index :mega_projects, :deadline
    add_index :mega_projects, [:settlement_id, :status]
  end
end
