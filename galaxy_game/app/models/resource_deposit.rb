# == Schema Information
#
# Table name: resource_deposits
#
#  id                    :bigint           not null, primary key
#  depositable_type      :string           not null
#  depositable_id        :bigint           not null
#  feature_id            :bigint
#  celestial_location_id :bigint
#  spatial_location_id   :bigint
#  material_name         :string           not null
#  initial_mass_kg       :decimal(20, 6)   not null
#  current_mass_kg       :decimal(20, 6)   not null
#  extraction_difficulty :float
#  depletion_curve       :string
#  status                :integer          default(0), not null
#  operational_data      :jsonb            default({})
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class ResourceDeposit < ApplicationRecord
  belongs_to :depositable, polymorphic: true
  belongs_to :feature, class_name: 'CelestialBodies::Features::AdaptedFeature', optional: true
  belongs_to :celestial_location, class_name: 'Location::CelestialLocation', optional: true
  belongs_to :spatial_location, class_name: 'Location::SpatialLocation', optional: true

  enum status: {
    undiscovered: 0,
    available: 1,
    claimed: 2,
    depleted: 3
  }

  validates :material_name, presence: true
  validates :initial_mass_kg, presence: true, numericality: { greater_than: 0 }
  validates :current_mass_kg, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :depositable, presence: true
  validates :status, presence: true

  validate :location_mutual_exclusivity
  validate :current_mass_not_exceed_initial

  # Only one of feature, celestial_location, or spatial_location may be set
  def location_mutual_exclusivity
    locs = [feature_id, celestial_location_id, spatial_location_id].compact
    if locs.size != 1
      errors.add(:base, 'Exactly one location (feature, celestial_location, or spatial_location) must be set')
    end
  end

  def current_mass_not_exceed_initial
    if current_mass_kg && initial_mass_kg && current_mass_kg > initial_mass_kg
      errors.add(:current_mass_kg, 'cannot exceed initial_mass_kg')
    end
  end
end
