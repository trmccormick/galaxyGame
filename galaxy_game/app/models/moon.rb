class Moon < CelestialBody
    # Specific attributes for moons
    validates :orbital_period, numericality: { greater_than: 0 }
  
    # Methods specific to moons
    def update_orbit
      # Implementation for updating orbit around a planet
    end
  end