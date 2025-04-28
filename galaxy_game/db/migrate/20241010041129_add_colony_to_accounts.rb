class AddColonyToAccounts < ActiveRecord::Migration[7.0]
  def change
    add_reference :accounts, :colony, null: true, foreign_key: true
  end
end
