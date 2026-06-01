class CreateLogisticsManifests < ActiveRecord::Migration[6.1]
  def change
    create_table :logistics_manifests do |t|
      t.string :manifest_id, null: false
      t.integer :source_settlement_id, null: false
      t.integer :destination_settlement_id, null: false
      t.datetime :created_at, null: false
      t.text :items
      t.integer :total_items, default: 0, null: false
      t.float :total_cost, default: 0.0, null: false
      t.integer :status, default: 0, null: false
    end
    add_index :logistics_manifests, :manifest_id, unique: true
    add_index :logistics_manifests, :source_settlement_id
    add_index :logistics_manifests, :destination_settlement_id
  end
end
