class ConstructionJob < ApplicationRecord
  belongs_to :jobable, polymorphic: true
  belongs_to :blueprint, optional: true
  belongs_to :settlement, class_name: 'Settlement::BaseSettlement', foreign_key: 'settlement_id'
  
  has_many :material_requests, as: :requestable, dependent: :destroy
  has_many :equipment_requests, as: :requestable, dependent: :destroy
  
  # Store target values and result data as JSON
  store :target_values, coder: JSON
  store :result_data, coder: JSON
  
  # Job type enum
  enum job_type: {
    crater_dome_construction: 0,
    skylight_cover: 1,
    access_point_conversion: 2,
    habitat_expansion: 3,
    structure_upgrade: 4
  }
  
  # Status enum
  enum status: {
    scheduled: 0,
    materials_pending: 1,
    equipment_pending: 2,
    workers_pending: 3,
    in_progress: 4,
    completed: 5,
    failed: 6,
    canceled: 7
  }
  
  # Add the missing helper methods
  def materials_gathered?
    return true if material_requests.empty?
    material_requests.all? { |req| req.status.in?(['fulfilled_by_player', 'fulfilled_by_npc']) }
  end
  
  def equipment_gathered?
    return true if equipment_requests.empty?
    equipment_requests.all? { |req| req.status == 'fulfilled' }
  end
  
  def infer_settlement
    # Use explicit settlement if set
    return settlement if settlement.present?
    
    # Use jobable's settlement if available
    return jobable.settlement if jobable.respond_to?(:settlement) && jobable.settlement.present?
    
    # If jobable is a settlement, return it
    return jobable if jobable.is_a?(Settlement::BaseSettlement)
    
    # Try to find by location
    if jobable.respond_to?(:location) && jobable.location.present?
      Settlement::BaseSettlement.where(location: jobable.location).first
    end
  end
  
  # Add convenience scopes
  scope :active, -> { where(status: [:scheduled, :materials_pending, :equipment_pending, :workers_pending, :in_progress]) }
  scope :completed, -> { where(status: :completed) }
  scope :failed, -> { where(status: :failed) }
end