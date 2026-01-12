# app/models/mining_log.rb
class MiningLog < ApplicationRecord
  # Defines a polymorphic association.
  # This means 'owner' can be any other model (e.g., Craft::Satellite::BaseSatellite, Player, etc.).
  # The database table will need `owner_type` (string) and `owner_id` (bigint) columns.
  belongs_to :owner, polymorphic: true, optional: true

  # Validations to ensure data integrity
  validates :amount_mined, numericality: { greater_than: 0 }, presence: true
  validates :mined_at, presence: true
  validates :currency, presence: true, inclusion: { in: %w[GCC USD BTC] }

  # Scopes for common queries
  scope :recent, -> { order(mined_at: :desc) }
  scope :by_currency, ->(currency) { where(currency: currency) }
  scope :by_owner, ->(owner) { where(owner: owner) }
  scope :for_period, ->(start_date, end_date) { where(mined_at: start_date..end_date) }

  # JSON accessors for operational details
  def thermal_efficiency
    operational_details&.dig('efficiency_factors', 'thermal') || 1.0
  end

  def processing_boost
    operational_details&.dig('efficiency_factors', 'processing') || 1.0
  end

  def power_efficiency
    return 0 if operational_details&.dig('power_usage').to_f == 0
    amount_mined.to_f / operational_details['power_usage'].to_f
  end

  def mining_rate_per_hour
    # Assuming the mining operation represents some fraction of an hour
    # You'll need to adjust this based on your actual timing
    amount_mined.to_f / 0.18 # If 0.18 represents 0.18 hours
  end
end