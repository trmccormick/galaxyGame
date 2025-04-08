# app/models/location/celestial_location.rb
module Location
  class CelestialLocation < BaseLocation
    self.table_name = 'celestial_locations'

    belongs_to :celestial_body,
               class_name: 'CelestialBodies::CelestialBody'
    belongs_to :locationable, polymorphic: true, optional: true

    validates :celestial_body, presence: true
    validates :coordinates, presence: true
    validates :coordinates, uniqueness: { scope: :celestial_body, case_sensitive: false } # Scoped uniqueness
    validates :coordinates, format: {
      with: /\A-?\d+\.\d+°[NS] -?\d+\.\d+°[EW]\z/,
      message: "must be in format '00.00°N/S 00.00°E/W'"
    }
  end
end