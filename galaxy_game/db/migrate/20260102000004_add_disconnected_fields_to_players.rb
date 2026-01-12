class AddDisconnectedFieldsToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :disconnected, :boolean, default: false, null: false
    add_column :players, :disconnected_at, :datetime
  end
end