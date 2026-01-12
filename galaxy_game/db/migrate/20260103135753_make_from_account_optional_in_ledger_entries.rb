class MakeFromAccountOptionalInLedgerEntries < ActiveRecord::Migration[7.0]
  def change
    change_column_null :ledger_entries, :from_account_id, true
  end
end
