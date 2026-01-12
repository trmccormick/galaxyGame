class CreateGameStates < ActiveRecord::Migration[7.0]
  def change
    create_table :game_states do |t|
      t.integer :year
      t.integer :day
      t.boolean :running, default: false
      t.integer :speed, default: 3
      t.datetime :last_updated_at

      t.timestamps
    end
  end
end
