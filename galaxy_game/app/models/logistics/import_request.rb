# frozen_string_literal: true

class Logistics::ImportRequest < ApplicationRecord
  self.table_name = 'logistics_import_requests'

  belongs_to :settlement, class_name: 'Settlement::BaseSettlement'
  belongs_to :manifest, class_name: 'Logistics::Manifest', optional: true

  enum status: {
    created: 0,
    quoted: 1,
    ordered: 2,
    fulfilled: 3,
    cancelled: 4
  }

  enum tier: { survival: 0, expansion: 1 }, _prefix: true
  enum priority: { high: 0, normal: 1, low: 2 }, _prefix: true
  enum category: { consumable: 0, equipment: 1, other: 2 }, _prefix: true

  # cost_analysis is a native JSON column; no need to use serialize

  validates :resource, :quantity_needed, :status, :tier, :priority, :category, presence: true
end
