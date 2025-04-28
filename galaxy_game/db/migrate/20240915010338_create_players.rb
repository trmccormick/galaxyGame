class CreatePlayers < ActiveRecord::Migration[6.1]
  def change
    create_table :players do |t|
      t.string :name, null: false
      t.string :active_location, null: false
      t.string :biography

      t.timestamps
    end

    add_reference :base_settlements, :player, foreign_key: true
  end
end
