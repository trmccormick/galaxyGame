class ComponentProductionJob < ApplicationRecord
  belongs_to :settlement
  belongs_to :printer_unit, class_name: 'BaseUnit', foreign_key: 'printer_unit_id', optional: true

  validates :component_blueprint_id, presence: true
  validates :component_name, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :status, presence: true
  validates :production_time_hours, presence: true, numericality: { greater_than: 0 }

  enum status: {
    pending: 0,
    in_progress: 1,
    completed: 2,
    failed: 3,
    cancelled: 4
  }

  scope :active, -> { where(status: [:pending, :in_progress]) }
  scope :completed, -> { where(status: :completed) }
  scope :in_progress, -> { where(status: :in_progress) }

  def start!
    update!(status: 'in_progress', started_at: Time.current)
  end

  def complete!
    update!(status: 'completed', completed_at: Time.current, progress_hours: production_time_hours)
  end

  def fail!(reason = nil)
    update!(
      status: 'failed',
      completed_at: Time.current,
      metadata: (metadata || {}).merge('failure_reason' => reason)
    )
  end

  def cancel!
    update!(status: 'cancelled', completed_at: Time.current)
  end

  def progress_percentage
    return 0 if production_time_hours.to_f.zero?
    ((progress_hours.to_f / production_time_hours.to_f) * 100).round(2)
  end

  def time_remaining_hours
    [production_time_hours.to_f - progress_hours.to_f, 0].max
  end

  def estimated_completion
    return nil unless started_at && in_progress?
    started_at + production_time_hours.hours
  end

  def active?
    pending? || in_progress?
  end

  def finished?
    completed? || failed? || cancelled?
  end

  def process_tick(hours_elapsed)
    return unless in_progress?
    self.progress_hours ||= 0
    self.progress_hours += hours_elapsed
    if progress_hours >= production_time_hours
      self.status = 'completed'
      self.completed_at = Time.current
      self.progress_hours = production_time_hours
    end
    save!
  end
end
