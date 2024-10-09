module CelestialBodies
  class CelestialBodies::TerrestrialPlanet < CelestialBody
    # Validations
    validates :surface_temperature, :atmosphere_composition, :atmospheric_pressure, presence: true
    validates :surface_temperature, numericality: true
    validates :atmospheric_pressure, numericality: true

    # Attributes should be handled by ActiveRecord if they are part of the database schema
    # attr_accessor is generally used for non-database attributes or those that aren't persisted

    # Method for calculating habitability score based on specific terrestrial planet criteria
    def habitability_score
      if surface_temperature.between?(273.15, 300.15) && atmospheric_pressure.between?(0.8, 1.2)
        "Habitable"
      else
        "Non-Habitable"
      end
    end

    private

    # Example of a method to get the pressure if it is not a direct attribute
    def calculated_atmospheric_pressure
      # Initialize the service with the current celestial body
      service = TerraSim.new(self)
      service.calculate
      # Assuming you have a method to get the pressure, e.g., `get_pressure`
      self.pressure
    end
  end
end
