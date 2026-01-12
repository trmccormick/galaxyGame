class MakeCurrencyOptionalInLedgerEntries < ActiveRecord::Migration[7.0]
  def change
    change_column_null :ledger_entries, :currency_id, true
  end
end
