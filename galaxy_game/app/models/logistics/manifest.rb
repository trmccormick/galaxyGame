# frozen_string_literal: true

module Logistics
  class Manifest < ApplicationRecord
    self.table_name = 'logistics_manifests'

    enum status: {
      pending: 0,
      in_transit: 1,
      delivered: 2,
      failed: 3
    }

    belongs_to :source_settlement, class_name: 'Settlement::BaseSettlement'
    belongs_to :destination_settlement, class_name: 'Settlement::BaseSettlement'

    serialize :items, Array

    validates :manifest_id, presence: true, uniqueness: true
    validates :items, presence: true
    validates :total_items, numericality: { greater_than_or_equal_to: 0 }
    validates :total_cost, numericality: { greater_than_or_equal_to: 0 }
    validates :status, presence: true
  end
end
