class CreateTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :transactions do |t|
      t.references :buyer, foreign_key: { to_table: :colonies }
      t.references :seller, foreign_key: { to_table: :colonies }
      t.decimal :amount, precision: 15, scale: 2
      t.timestamps
    end
  end
end

