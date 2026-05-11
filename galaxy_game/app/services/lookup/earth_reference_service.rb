module Lookup
  class EarthReferenceService
    def initialize
      @earth = CelestialBodies::Planets::Rocky::TerrestrialPlanet.find_by!(identifier: 'EARTH-01')     
      load_earth_data if @earth.nil?
    end
    
    def radius
      return @earth.radius if @earth.respond_to?(:radius) && @earth.radius.present?
      (@earth_data["radius"] || 6371000.0) / 1000.0 # Convert to km from meters
    end
    
    def gravity
      return @earth.gravity if @earth.respond_to?(:gravity) && @earth.gravity.present?
      @earth_data["gravity"] || GameConstants::Earth::GRAVITY
    end
    
    def mass
      return @earth.mass if @earth.respond_to?(:mass) && @earth.mass.present?
      (@earth_data["mass"] || "5.97e24").to_f
    end
    
    def atmospheric_pressure
      return @earth.atmosphere.pressure * 101325.0 if @earth.respond_to?(:atmosphere) && @earth.atmosphere.respond_to?(:pressure) && @earth.atmosphere.pressure.present?
      (@earth_data.dig("atmosphere", "pressure") || 1.0) * 101325.0 # Convert to Pa from bar
    end
    
    def atmospheric_mass
      return @earth.atmosphere.total_atmospheric_mass if @earth.respond_to?(:atmosphere) && @earth.atmosphere.respond_to?(:total_atmospheric_mass) && @earth.atmosphere.total_atmospheric_mass.present?
      @earth_data.dig("atmosphere", "total_atmospheric_mass") || GameConstants::EARTH_ATMOSPHERE[:mass]
    end
    
    def surface_temperature
      return @earth.surface_temperature if @earth.respond_to?(:surface_temperature) && @earth.surface_temperature.present?
      @earth_data["surface_temperature"] || GameConstants::DEFAULT_TEMPERATURE
    end
    
    def atmosphere_composition
      # print composition from @earth if available for debugging
      if @earth.respond_to?(:atmosphere) && @earth.atmosphere.respond_to?(:composition) && @earth.atmosphere.composition.present?
        # inspect @earth.atmosphere.gases for debugging this should have the correct format that is being looked for
        Rails.logger.debug "Earth atmosphere gases: #{@earth.atmosphere.gases.inspect}"
        return @earth.atmosphere.composition
      end
      
      # Fallback to composition from @earth_data
      return @earth.atmosphere.composition if @earth.respond_to?(:atmosphere) && @earth.atmosphere.respond_to?(:composition) && @earth.atmosphere.composition.present?
      @earth_data.dig("atmosphere", "composition") || GameConstants::EARTH_ATMOSPHERE[:composition]
    end
    
    def axial_tilt
      return @earth.axial_tilt if @earth.respond_to?(:axial_tilt) && @earth.axial_tilt.present?
      @earth_data["axial_tilt"] || GameConstants::Earth::AXIAL_TILT
    end
    
    def surface_area
      return @earth.surface_area if @earth.respond_to?(:surface_area) && @earth.surface_area.present?
      @earth_data["surface_area"] || 510072000.0 # m²
    end
    
    def escape_velocity
      return @earth.escape_velocity if @earth.respond_to?(:escape_velocity) && @earth.escape_velocity.present?
      @earth_data["escape_velocity"] || 11.186 # km/s
    end
    
    private
    
    def load_earth_data
      # Try multiple possible paths
      potential_paths = [
        GalaxyGame::Paths::JSON_DATA.join("star_systems", "sol.json"),
        Rails.root.join("app", "data", "star_systems", "sol.json"),
        Rails.root.join("data", "json-data", "star_systems", "sol.json")
      ]
      
      # Try each path until we find one that works
      sol_data = nil
      potential_paths.each do |path|
        begin
          if File.exist?(path)
            Rails.logger.debug "Found sol.json at: #{path}"
            sol_data = JSON.parse(File.read(path))
            break
          end
        rescue => e
          Rails.logger.debug "Failed to load sol.json from #{path}: #{e.message}"
        end
      end
      
      # If we found sol data, try to extract Earth
      if sol_data
        earth_from_json = sol_data.dig("celestial_bodies", "terrestrial_planets")&.find do |planet|
          planet["name"] == "Earth"
        end
        
        if earth_from_json
          Rails.logger.info "Found Earth data in sol.json"
          @earth_data = earth_from_json
          return # Successfully loaded, exit method
        end
      end
      
      # If we get here, use the fallback data
      Rails.logger.info "Using fallback Earth data"
      @earth_data = build_earth_data_from_constants
    end
    
    def build_earth_data_from_constants
      # Create Earth data structure from constants
      {
        "name" => "Earth",
        "radius" => GameConstants::Earth::RADIUS * 1000, # Convert km to m
        "gravity" => GameConstants::Earth::GRAVITY,
        "mass" => GameConstants::Earth::MASS.to_s,
        "axial_tilt" => GameConstants::Earth::AXIAL_TILT,
        "surface_area" => 510072000.0, # m²
        "escape_velocity" => 11.186, # km/s
        "atmosphere" => {
          "pressure" => GameConstants::STANDARD_PRESSURE_ATM,
          "total_atmospheric_mass" => GameConstants::EARTH_ATMOSPHERE[:mass],
          "composition" => GameConstants::EARTH_ATMOSPHERE[:composition]
        },
        "surface_temperature" => GameConstants::DEFAULT_TEMPERATURE
      }
    end
  end
end