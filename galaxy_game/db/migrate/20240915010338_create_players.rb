class CreatePlayers < ActiveRecord::Migration[6.1]
  def change
    create_table :players do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_reference :settlements, :player, foreign_key: true
  end
end
