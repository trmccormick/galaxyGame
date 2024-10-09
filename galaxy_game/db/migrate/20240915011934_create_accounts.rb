class CreateAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :accounts do |t|
      t.references :settlement, foreign_key: true
      t.decimal :balance, precision: 15, scale: 2, default: 0.0
      t.timestamps
    end
  end
end
