module CelestialBodiesHelper
    def gas_name_and_formula(gas)
      case gas
      when "O2"
        "Oxygen O₂"
      when "N2"
        "Nitrogen N₂"
      when "CO2"
        "Carbon Dioxide CO₂"
      when "H2"
        "Hydrogen H₂"
      when "He"
        "Helium He"
      else
        gas # Default to gas name if not found
      end
    end
  end
  