class CreateSpecialMissions < ActiveRecord::Migration[7.0]
  def change
    create_table :special_missions do |t|
      t.references :settlement, null: false, foreign_key: { to_table: :base_settlements }
      t.string :material
      t.decimal :required_quantity
      t.decimal :reward_eap
      t.decimal :bonus_multiplier, default: 1.0
      t.integer :status
      t.json :operational_data

      t.timestamps
    end
  end
end
