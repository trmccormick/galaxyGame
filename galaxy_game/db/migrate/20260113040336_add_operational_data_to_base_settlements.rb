class AddOperationalDataToBaseSettlements < ActiveRecord::Migration[7.0]
  def change
    add_column :base_settlements, :operational_data, :jsonb, default: {}
    add_index :base_settlements, :operational_data, using: :gin
  end
end
