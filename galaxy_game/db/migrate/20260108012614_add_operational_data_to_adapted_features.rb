class AddOperationalDataToAdaptedFeatures < ActiveRecord::Migration[7.0]
  def change
    add_column :adapted_features, :operational_data, :jsonb, default: {}
    add_index :adapted_features, :operational_data, using: :gin
  end
end
