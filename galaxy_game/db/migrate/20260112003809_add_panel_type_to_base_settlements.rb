class AddPanelTypeToBaseSettlements < ActiveRecord::Migration[7.0]
  def change
    add_column :base_settlements, :panel_type, :string
  end
end