module Lookup
  class EarthReferenceService
    def initialize
      load_earth_data
    end
    
    def radius
      (@earth_data["radius"] || 6371000.0) / 1000.0 # Convert to km from meters
    end
    
    def gravity
      @earth_data["gravity"] || GameConstants::Earth::GRAVITY
    end
    
    def mass
      (@earth_data["mass"] || "5.97e24").to_f
    end
    
    def atmospheric_pressure
      (@earth_data.dig("atmosphere", "pressure") || 1.0) * 101325.0 # Convert to Pa from bar
    end
    
    def atmospheric_mass
      @earth_data.dig("atmosphere", "total_atmospheric_mass") || GameConstants::EARTH_ATMOSPHERE[:mass]
    end
    
    def surface_temperature
      @earth_data["surface_temperature"] || GameConstants::DEFAULT_TEMPERATURE
    end
    
    def atmosphere_composition
      @earth_data.dig("atmosphere", "composition") || GameConstants::EARTH_ATMOSPHERE[:composition].transform_keys(&:to_s)
    end
    
    def axial_tilt
      @earth_data["axial_tilt"] || GameConstants::Earth::AXIAL_TILT
    end
    
    def surface_area
      @earth_data["surface_area"] || 510072000.0 # m²
    end
    
    def escape_velocity
      @earth_data["escape_velocity"] || 11.186 # km/s
    end
    
    private
    
    def load_earth_data
      # Try multiple possible paths
      potential_paths = [
        GalaxyGame::Paths::GAME_DATA.join("star_systems", "sol.json"),
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
          "composition" => GameConstants::EARTH_ATMOSPHERE[:composition].transform_values do |v|
            v.is_a?(Hash) ? v.transform_keys(&:to_s) : v
          end
        },
        "surface_temperature" => GameConstants::DEFAULT_TEMPERATURE
      }
    end
  end
end