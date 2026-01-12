# db/migrate/20251218143953_create_worldhouse_structures.rb
class CreateWorldhouseStructures < ActiveRecord::Migration[7.0]
  def change
    add_column :structures, :geological_feature_id, :bigint
    add_column :structures, :total_segments, :integer
    add_column :structures, :enclosed_segments, :integer, default: 0
    add_column :structures, :coverage_percent, :float, default: 0.0
    
    add_index :structures, :geological_feature_id
    add_foreign_key :structures, :adapted_features, column: :geological_feature_id
    
    create_table :worldhouse_segments do |t|
      t.references :worldhouse, null: false, foreign_key: { to_table: :structures }
      t.integer :segment_index, null: false
      t.string :name
      t.float :length_m, null: false
      t.float :width_m, null: false
      t.string :status, default: 'planned'
      t.timestamps
    end
    
    add_index :worldhouse_segments, [:worldhouse_id, :segment_index], unique: true
    
    create_table :segment_components do |t|
      t.references :segment, null: false, foreign_key: { to_table: :worldhouse_segments }
      t.references :item, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.string :component_type, null: false
      t.timestamps
    end
    
    add_index :segment_components, :component_type
  end
end