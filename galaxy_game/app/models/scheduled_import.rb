# ScheduledImport model for tracking AI Manager import orders
class ScheduledImport < ApplicationRecord
  belongs_to :source_settlement, class_name: 'Settlement::BaseSettlement', optional: true
  belongs_to :destination_settlement, class_name: 'Settlement::BaseSettlement'

  validates :material, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :source, presence: true
  validates :transport_cost, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :delivery_eta, presence: true

  enum status: { scheduled: 0, in_transit: 1, delivered: 2, cancelled: 3 }

  scope :pending, -> { where(status: [:scheduled, :in_transit]) }
  scope :overdue, -> { where('delivery_eta < ? AND status != ?', Time.current, :delivered) }

  def overdue?
    delivery_eta < Time.current && !delivered?
  end

  def days_until_delivery
    ((delivery_eta - Time.current) / 1.day).ceil
  end
end</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/galaxy_game/app/models/scheduled_import.rb