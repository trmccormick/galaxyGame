class SpecialMission < ApplicationRecord
  belongs_to :settlement, class_name: 'Settlement::BaseSettlement'

  enum status: { open: 0, accepted: 1, completed: 2, expired: 3, cancelled: 4 }

  validates :material, :required_quantity, :reward_eap, presence: true
  validates :required_quantity, :reward_eap, numericality: { greater_than: 0 }

  scope :open, -> { where(status: :open) }
  scope :expired, -> { where("operational_data->>'expires_at' < ?", Time.current.to_s) }

  def accept!(player)
    return false unless open?

    update(
      status: :accepted,
      operational_data: operational_data.merge(accepted_by: player.id, accepted_at: Time.current)
    )
  end

  def complete!(player)
    return false unless accepted?

    update(
      status: :completed,
      operational_data: operational_data.merge(completed_by: player.id, completed_at: Time.current)
    )
  end

  def expire!
    update(status: :expired) if open?
  end

  def total_reward
    reward_eap * (bonus_multiplier || 1.0)
  end
end
