# app/models/celestial_bodies/star_distance.rb
module CelestialBodies
  class CelestialBodies::StarDistance < ApplicationRecord
    # Associations
    belongs_to :celestial_body
    belongs_to :star

    # Validations
    validates :distance, presence: true, numericality: true
  end
end
