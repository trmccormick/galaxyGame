# app/models/enclosed_habitat_atmosphere.rb
class EnclosedHabitatAtmosphere < Atmosphere
    belongs_to :enclosed_habitat
  
    private
  
    def default_temperature
      293.15 # Default to 20°C for enclosed habitats
    end
end
  