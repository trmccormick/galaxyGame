class CreateLogisticsImportRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :logistics_import_requests do |t|
      t.references :settlement, null: false, foreign_key: { to_table: :base_settlements }
      t.references :manifest, foreign_key: { to_table: :logistics_manifests }
      t.string :resource, null: false
      t.integer :quantity_needed, null: false
      t.json :cost_analysis
      t.integer :status, null: false, default: 0
      t.integer :tier, null: false, default: 0
      t.integer :priority, null: false, default: 1
      t.integer :category, null: false, default: 2
      t.datetime :resolved_at
      t.timestamps
    end
  end
end
