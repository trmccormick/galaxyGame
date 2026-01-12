class AddBonusMultiplierToSpecialMissions < ActiveRecord::Migration[7.0]
  def change
    add_column :special_missions, :bonus_multiplier, :decimal unless column_exists?(:special_missions, :bonus_multiplier)
  end
end
