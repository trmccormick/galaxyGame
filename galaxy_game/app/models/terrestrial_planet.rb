class TerrestrialPlanet < CelestialBody
    # Additional attributes for terrestrial planets
    validates :surface_temperature, :atmosphere_composition, presence: true
  
    # Example: specific attributes that make terrestrial planets distinct
    attr_accessor :surface_temperature, :atmosphere_composition, :geological_activity
  
    # Method for calculating habitability score based on specific terrestrial planet criteria
    def habitability_score
      if surface_temperature.between?(273.15, 300.15) && atmospheric_pressure.between?(0.8, 1.2)
        "Habitable"
      else
        "Non-Habitable"
      end
    end
  
    # You could add more specific methods for terrestrial planets, like plate tectonics or volcanic activity
    def update_geological_activity
      # Logic to update or check geological activity like earthquakes or volcanic eruptions
    end
end