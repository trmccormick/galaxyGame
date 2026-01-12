class CreateBondRepayments < ActiveRecord::Migration[7.0]
  def change
    create_table :bond_repayments do |t|
      t.references :bond, null: false, foreign_key: true
      t.references :currency, null: false, foreign_key: true
      t.decimal :amount, precision: 20, scale: 4, null: false
      t.string :description
      t.timestamps
    end
  end
end
