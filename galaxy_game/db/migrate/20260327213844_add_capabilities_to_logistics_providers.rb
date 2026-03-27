class AddCapabilitiesToLogisticsProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :logistics_providers, :capabilities, :text
    add_column :logistics_providers, :cost_modifiers, :text
    add_column :logistics_providers, :time_modifiers, :text
  end
end
