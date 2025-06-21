class UnitAssemblyJob < ApplicationRecord
  # Fix association - migration uses base_settlement, not settlement
  belongs_to :base_settlement, class_name: 'Settlement::BaseSettlement'
  belongs_to :owner, polymorphic: true, optional: true
  has_many :material_requests, as: :requestable, dependent: :destroy

  validates :base_settlement, presence: true
  validates :unit_type, presence: true
  validates :count, presence: true, numericality: { greater_than: 0 }

  enum status: {
    pending: 'pending',
    materials_pending: 'materials_pending', 
    in_progress: 'in_progress',
    completed: 'completed',
    failed: 'failed',
    canceled: 'canceled'
  }

  enum priority: {
    normal: 'normal',
    low: 'low',
    medium: 'medium', 
    high: 'high',
    critical: 'critical'
  }

  scope :active, -> { where.not(status: ['completed', 'failed', 'canceled']) }

  # Delegate settlement methods for backwards compatibility
  delegate :inventory, to: :base_settlement
  delegate :owner, to: :base_settlement
  
  def settlement
    base_settlement
  end

  def materials_gathered?
    material_requests.empty? || material_requests.all? { |req| req.status == 'fulfilled' }
  end

  def start_assembly
    return false unless status == 'materials_pending'
    return false unless materials_gathered?

    # Consume materials from settlement inventory
    consume_materials

    # Calculate completion time - use specifications for blueprint data
    manufacturing_time = specifications.dig('production_data', 'manufacturing_time_hours') || 1
    
    update!(
      status: 'in_progress',
      start_date: Time.current,
      estimated_completion: Time.current + manufacturing_time.hours
    )

    true
  end

  def complete_assembly
    return false unless status == 'in_progress'

    # Create unassembled items in settlement inventory
    create_unassembled_items

    update!(
      status: 'completed',
      completion_date: Time.current
    )

    true
  end

  private

  def consume_materials
    material_requests.each do |request|
      remaining_needed = request.quantity_requested
      
      # Find items owned by the job requester
      items_to_consume = base_settlement.inventory.items.where(
        name: request.material_name,
        owner: base_settlement.owner
      ).order(:created_at)
      
      items_to_consume.each do |item|
        break if remaining_needed <= 0
        
        if item.amount <= remaining_needed
          remaining_needed -= item.amount
          item.destroy!
        else
          item.update!(amount: item.amount - remaining_needed)
          remaining_needed = 0
        end
      end
      
      request.update!(status: 'fulfilled')
    end
  end

  def create_unassembled_items
    blueprint_name = specifications['name'] || unit_type.humanize
    
    count.times do |i|
      Item.create!(
        name: "Unassembled #{blueprint_name}",
        description: "Unassembled #{blueprint_name} ready for deployment",
        amount: 1,
        
        # Ownership and location
        owner: base_settlement.owner,
        inventory: base_settlement.inventory,
        
        # Item properties - fix material_type to use the correct enum string
        material_type: 'manufactured_goods',  # Ensure this matches an enum value in Item model
        storage_method: 'bulk_storage',
        
        # Deployment data
        metadata: {
          'deployment_data' => {
            'unit_type' => unit_type,
            'blueprint_reference' => specifications['id'], # Use specifications['id'] instead of blueprint_id
            'manufactured_by' => base_settlement.owner.name,
            'manufactured_at' => Time.current.to_s,
            'assembly_job_id' => id
          }
        }
      )
    end
  end
end