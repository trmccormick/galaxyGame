# db/migrate/20251218034030_create_adapted_features.rb
class CreateAdaptedFeatures < ActiveRecord::Migration[7.0]
  def change
    create_table :adapted_features do |t|
      t.references :celestial_body, null: false, foreign_key: { to_table: :celestial_bodies }
      t.string :feature_id, null: false # e.g., "luna_lt_001"
      t.string :feature_type, null: false # e.g., "lava_tube", "crater"
      t.string :type, null: false # STI type column
      t.string :status, default: "natural" # e.g., "enclosed", "settlement_established"
      t.datetime :adapted_at
      t.datetime :discovered_at # Add this - when was it discovered
      t.integer :settlement_id
      t.integer :discovered_by
      t.integer :parent_feature_id # For skylights/access points belonging to lava tubes
      t.timestamps
    end
    
    add_index :adapted_features, [:feature_id, :feature_type, :celestial_body_id], 
              unique: true, name: "index_adapted_features_on_feature_and_body"
    add_index :adapted_features, :type
    add_index :adapted_features, :parent_feature_id
    
    add_foreign_key :adapted_features, :adapted_features, column: :parent_feature_id
  end
end
