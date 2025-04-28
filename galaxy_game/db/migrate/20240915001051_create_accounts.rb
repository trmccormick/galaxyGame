# Migration for accounts table
class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts do |t|
      t.references :accountable, polymorphic: true, null: false
      t.decimal :balance, precision: 15, scale: 2, default: 0.0, null: false

      t.timestamps
    end
  end
end