class CreateBonds < ActiveRecord::Migration[7.0]
  def change
    create_table :bonds do |t|
      t.references :issuer, polymorphic: true, null: false
      t.references :holder, polymorphic: true, null: false
      t.references :currency, null: false, foreign_key: true
      t.decimal :amount, precision: 20, scale: 4, null: false
      t.decimal :interest_rate, precision: 5, scale: 2
      t.datetime :issued_at, null: false
      t.datetime :due_at
      t.string :status, null: false, default: "issued"
      t.string :description

      t.timestamps
    end
  end
end
