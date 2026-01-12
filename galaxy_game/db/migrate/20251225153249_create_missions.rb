class CreateMissions < ActiveRecord::Migration[7.0]
  def change
    create_table :missions do |t|
      t.string :identifier, null: false
      t.references :settlement, null: false, foreign_key: { to_table: :base_settlements }
      t.integer :status, default: 0
      t.integer :progress, default: 0
      t.text :operational_data

      t.timestamps
    end

    add_index :missions, :identifier, unique: true
  end
end