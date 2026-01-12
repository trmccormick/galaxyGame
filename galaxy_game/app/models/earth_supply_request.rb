class EarthSupplyRequest < ApplicationRecord
  belongs_to :purchaser, polymorphic: true  # Player or NPC
  
  validates :material_name, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :total_cost, presence: true, numericality: { greater_than: 0 }
  
  enum status: {
    pending_approval: 'pending_approval',
    approved: 'approved',
    in_transit: 'in_transit',
    delivered: 'delivered',
    canceled: 'canceled'
  }
  
  enum priority: {
    economy: 'economy',    # 60 days, 20% discount
    normal: 'normal',      # 30 days, standard price
    rush: 'rush'          # 14 days, 100% premium
  }
  
  scope :ready_for_delivery, -> { where('status = ? AND estimated_arrival <= ?', 'in_transit', Time.current) }
  
  def approve!
    return false unless pending_approval?
    
    if purchaser.can_afford?(total_cost)
      update!(status: 'approved')
      # Earth suppliers will process and ship
      delay(7.days).ship_from_earth  # 7 day processing time
      true
    else
      update!(status: 'canceled', notes: 'Insufficient funds')
      false
    end
  end
  
  def ship_from_earth
    update!(
      status: 'in_transit',
      ship_date: Time.current
    )
    
    # Schedule delivery
    delay(delivery_time - 7.days).deliver_to_settlement
  end
  
  def deliver_to_settlement
    EarthSupplierService.process_delivery(self)
  end
end