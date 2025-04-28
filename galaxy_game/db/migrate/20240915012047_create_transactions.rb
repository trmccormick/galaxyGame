# Migration for transactions table
class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions do |t|
      t.references :account, null: false, foreign_key: true
      t.references :recipient, polymorphic: true, null: false
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.string :transaction_type, null: false
      t.text :description

      t.timestamps
    end
  end
end

