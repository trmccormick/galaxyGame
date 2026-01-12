module Financial
  class LedgerEntry < ApplicationRecord
    belongs_to :from_account, class_name: 'Financial::Account', optional: true
    belongs_to :to_account, class_name: 'Financial::Account'
    belongs_to :currency, optional: true
    belongs_to :item, optional: true

    enum entry_type: {
      currency_transfer: 0,
      goods_transfer: 1
    }

    # Scope for NPC-to-NPC transfers
    scope :npc_to_npc, -> {
      # Simplified: just return all entries for now
      all
    }

    # Scope for off-market transfers (between parent corporations)
    scope :off_market, -> {
      where(entry_type: [:currency_transfer, :goods_transfer])
    }
  end
end
