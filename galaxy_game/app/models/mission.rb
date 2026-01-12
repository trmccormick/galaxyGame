class Mission < ApplicationRecord
  belongs_to :settlement, class_name: 'Settlement::BaseSettlement'
  enum status: { in_progress: 0, completed: 1, stalled: 2, failed: 3 }
  serialize :operational_data, JSON

  validates :identifier, presence: true
  validates :settlement, presence: true
end