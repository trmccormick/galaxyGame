class AddExoticMatterProductionToWormholes < ActiveRecord::Migration[7.0]
  def change
    add_column :wormholes, :exotic_matter_production_rate, :decimal, precision: 10, scale: 4, default: 0.0, null: false
    add_column :wormholes, :shift_count, :integer, default: 0, null: false
    add_column :wormholes, :last_shift_at, :datetime
    add_column :wormholes, :collapse_charge_triggered, :boolean, default: false, null: false
  end
end