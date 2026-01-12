class AddLockVersionToAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :accounts, :lock_version, :integer
  end
end
