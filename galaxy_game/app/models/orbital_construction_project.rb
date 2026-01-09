class OrbitalConstructionProject < ApplicationRecord
  belongs_to :station, class_name: 'Settlement::BaseSettlement', foreign_key: 'station_id'

  enum status: {
    materials_pending: 0,
    in_progress: 1,
    completed: 2,
    failed: 3,
    canceled: 4
  }

  validates :craft_blueprint_id, presence: true
  validates :progress_percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  # Store material data as JSONB
  store :required_materials, coder: JSON
  store :delivered_materials, coder: JSON
  store :project_metadata, coder: JSON

  def materials_complete?
    required_materials.all? do |material_id, required_qty|
      delivered_materials[material_id].to_f >= required_qty.to_f
    end
  end

  def completion_percentage
    # Calculate based on materials delivered
    total_required = required_materials.values.sum.to_f
    total_delivered = delivered_materials.values.sum.to_f
    total_required > 0 ? (total_delivered / total_required * 100).to_f : 0.0
  end
end