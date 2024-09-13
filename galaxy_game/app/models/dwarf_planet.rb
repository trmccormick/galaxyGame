class DwarfPlanet < CelestialBody
    # Additional methods and attributes specific to dwarf planets
    validates :mass, presence: true, numericality: { less_than: 1e22 } # Example: mass < 1e22 kg for dwarf planets
  
    # Example of custom behavior for dwarf planets
    def update_orbit
      # Dwarf planets often have more irregular or elliptical orbits
      # You could define specific logic for updating orbits here
    end
  end