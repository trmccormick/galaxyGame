# app/models/shell_printing_job.rb
class ShellPrintingJob < ApplicationRecord
  belongs_to :settlement, class_name: 'Settlement::BaseSettlement'
  belongs_to :printer_unit, class_name: 'Units::BaseUnit', foreign_key: 'printer_unit_id'
  belongs_to :inflatable_tank, class_name: 'Units::BaseUnit', foreign_key: 'inflatable_tank_id'
  validates :status, presence: true
  validates :production_time_hours, presence: true, numericality: { greater_than: 0 }
  validates :progress_hours, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  enum status: {
    pending: 'pending',
    in_progress: 'in_progress',
    completed: 'completed',
    failed: 'failed',
    cancelled: 'cancelled'
  }
  scope :active, -> { where(status: [:pending, :in_progress]) }
  scope :completed, -> { where(status: :completed) }
  scope :in_progress, -> { where(status: :in_progress) }
  scope :for_settlement, ->(settlement_id) { where(settlement_id: settlement_id) }

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
