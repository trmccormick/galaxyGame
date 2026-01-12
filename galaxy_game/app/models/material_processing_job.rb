class MaterialProcessingJob < ApplicationRecord
  belongs_to :settlement, class_name: 'Settlement::BaseSettlement'
  belongs_to :unit, class_name: 'Units::BaseUnit'

  # Enums for processing types and statuses
  enum processing_type: {
    thermal_extraction: 'thermal_extraction',
    volatiles_extraction: 'volatiles_extraction'
  }

  enum status: {
    pending: 'pending',
    in_progress: 'in_progress',
    completed: 'completed',
    failed: 'failed'
  }

  # Validations
  validates :processing_type, presence: true
  validates :input_material, presence: true
  validates :input_amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true

  # Scopes
  scope :pending, -> { where(status: :pending) }
  scope :in_progress, -> { where(status: :in_progress) }
  scope :completed, -> { where(status: :completed) }
  scope :active, -> { where(status: [:pending, :in_progress]) }
  scope :for_settlement, ->(settlement) { where(settlement: settlement) }
  scope :for_unit, ->(unit) { where(unit: unit) }

  # Methods
  def start!
    update!(status: 'in_progress', start_date: Time.current)
  end

  def process_tick(hours_elapsed)
    return unless status == 'in_progress'
    
    self.progress_hours ||= 0.0
    self.progress_hours += hours_elapsed
    
    if progress_hours >= production_time_hours
      complete!
    else
      save!
    end
  end

  def complete!
    # Do the actual processing here
    service = Manufacturing::MaterialProcessingService.new(settlement)
    service.complete_job(self)
    update!(status: 'completed', completion_date: Time.current)
  end
end
