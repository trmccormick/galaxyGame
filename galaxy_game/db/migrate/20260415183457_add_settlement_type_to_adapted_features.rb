class AddSettlementTypeToAdaptedFeatures < ActiveRecord::Migration[7.0]
  def change
    add_column :adapted_features, :settlement_type, :string
  end
end
