class Job < ApplicationRecord
  belongs_to :owner, polymorphic: true
  belongs_to :settlement, class_name: 'Settlement::BaseSettlement'
  belongs_to :blueprint, optional: true

  belongs_to :printer_unit, class_name: 'Units::BaseUnit', optional: true

  enum job_type: {
    material_processing: 0,
    component_production: 1,
    smelting: 2,
    unit_assembly: 3,
    resource_processing: 4,
    environment_processing: 5
  }

  enum status: {
    in_progress: 0,
    ready_to_claim: 1,
    claimed: 2,
    failed: 3,
    cancelled: 4,
    pending: 5
  }

  validates :job_type, presence: true
  validates :status, presence: true
  validates :output_type, presence: true
  validates :completes_at, presence: true
end
