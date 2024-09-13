class OrbitalRelationship < ApplicationRecord
    belongs_to :celestial_body
    belongs_to :sun, class_name: 'CelestialBody'
  
    # Validations
    validates :distance, presence: true, numericality: { greater_than: 0 }
  
    # Calculate the solar input for this relationship if needed directly
    def solar_input
      return 0 if distance.nil? || sun.luminosity.nil?
  
      sun.luminosity / (4 * Math::PI * distance**2)
    end
end