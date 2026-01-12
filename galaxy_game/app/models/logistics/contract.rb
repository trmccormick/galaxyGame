module Logistics
  class Contract < ApplicationRecord
    self.table_name = :logistics_contracts

    belongs_to :provider, class_name: 'Logistics::Provider'
    belongs_to :from_settlement, class_name: 'Settlement::BaseSettlement'
    belongs_to :to_settlement, class_name: 'Settlement::BaseSettlement'

    enum status: { pending: 0, in_transit: 1, delivered: 2, failed: 3, cancelled: 4 }
    enum transport_method: { orbital_transfer: 0, surface_conveyance: 1, drone_delivery: 2 }

    validates :material, :quantity, :transport_method, presence: true
    validates :quantity, numericality: { greater_than: 0 }
    validates :shipping_cost, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

    scope :active, -> { where(status: [:pending, :in_transit]) }
    scope :completed, -> { where(status: :delivered) }

    def mark_delivered!
      update_columns(status: 2, completed_at: Time.current)
    end

    def mark_failed!(reason = nil)
      update(status: :failed, operational_data: operational_data.merge(failure_reason: reason))
    end

    def mark_in_transit!
      update(status: :in_transit, started_at: Time.current)
    end
  end
end
