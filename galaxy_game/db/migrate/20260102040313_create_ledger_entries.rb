class CreateLedgerEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :ledger_entries do |t|
      t.references :from_account, null: false, foreign_key: { to_table: :accounts }
      t.references :to_account, null: false, foreign_key: { to_table: :accounts }
      t.references :currency, null: false, foreign_key: true
      t.references :item, foreign_key: true
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.integer :entry_type, null: false, default: 0
      t.text :description
      t.timestamps
    end

    add_index :ledger_entries, [:from_account_id, :to_account_id, :created_at], name: 'idx_ledger_entries_accounts_time'
    add_index :ledger_entries, :entry_type
  end
end
