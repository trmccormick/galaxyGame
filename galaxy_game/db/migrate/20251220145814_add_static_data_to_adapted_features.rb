class AddStaticDataToAdaptedFeatures < ActiveRecord::Migration[7.0]
  def change
    add_column :adapted_features, :static_data, :jsonb
  end
end
