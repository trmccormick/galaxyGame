# app/models/logistics_contract.rb
class LogisticsContract < ApplicationRecord
  belongs_to :from_settlement, class_name: 'Settlement::BaseSettlement', optional: true
  belongs_to :to_settlement, class_name: 'Settlement::BaseSettlement'

  # status is a plain integer column (not enum) — values set by logistics pipeline
  # Typical values: 0=pending, 1=in_transit, 2=delivered, 3=failed

  validates :to_settlement_id, :material, :quantity, presence: true
end
