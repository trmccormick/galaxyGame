class EquipmentRequest < ApplicationRecord
  belongs_to :requestable, polymorphic: true
  
  validates :equipment_type, presence: true
  validates :quantity_requested, numericality: { greater_than: 0 }
  
  # Status enum - FIXED to use string values to match database
  enum status: {
    pending: 'pending',
    partially_fulfilled: 'partially_fulfilled',
    fulfilled: 'fulfilled',
    canceled: 'canceled'
  }, _default: 'pending'
  
  # Priority enum - FIXED to use string values and 'normal' to match migration
  enum priority: {
    low: 'low',
    normal: 'normal',
    high: 'high',
    critical: 'critical'
  }, _default: 'normal'
  
  # Scopes
  scope :pending_requests, -> { where(status: [:pending, :partially_fulfilled]) }
  scope :fulfilled, -> { where(status: :fulfilled) }
  scope :for_equipment, ->(equipment_type) { where(equipment_type: equipment_type) }
  
  # Calculate how much is still needed
  def quantity_still_needed
    quantity_requested - (quantity_fulfilled || 0)
  end
end