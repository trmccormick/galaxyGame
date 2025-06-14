class MaterialRequest < ApplicationRecord
  belongs_to :requestable, polymorphic: true
  
  validates :material_name, presence: true
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
  scope :for_material, ->(material_name) { where(material_name: material_name) }
  
  # Delegations
  delegate :settlement, to: :requestable, allow_nil: true
  
  # Calculate how much is still needed
  def quantity_still_needed
    quantity_requested - (quantity_fulfilled || 0)
  end
  
  def gas_request?
    lookup = Lookup::MaterialLookupService.new
    material_data = lookup.find_material(material_name)
    return false unless material_data
    
    material_data["category"] == "gas"
  end
end
