class MissionContract < ApplicationRecord
  belongs_to :offered_by, polymorphic: true   # e.g., Base, Organization, AIManager
  belongs_to :accepted_by, polymorphic: true, optional: true # Player, NPC, Org, etc.

  # JSON fields for flexibility
  serialize :requirements, JSON
  serialize :reward, JSON
  serialize :manifest, JSON
  serialize :phases, JSON

  enum status: { open: 0, accepted: 1, completed: 2, failed: 3, expired: 4 }

  validates :mission_id, :name, :requirements, :reward, presence: true

  # Example: requirements = { "resource": "methane", "amount": 10000, "delivery_location": "Luna Base" }
  # reward = { "credits": 5000, "market_adjusted": true }
end