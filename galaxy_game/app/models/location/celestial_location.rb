# app/models/location/celestial_location.rb
module Location
  class CelestialLocation < BaseLocation
    self.table_name = 'celestial_locations'

    belongs_to :celestial_body,
               class_name: 'CelestialBodies::CelestialBody'
    belongs_to :locationable, polymorphic: true, optional: true

    validates :celestial_body, presence: true
    validates :coordinates, presence: true
    validates :coordinates, uniqueness: { scope: :celestial_body, case_sensitive: false }
    validates :coordinates, format: {
      with: /\A\d+\.\d+°[NS]\s+\d+\.\d+°[EW]\z/,
      message: "must be in format '00.00°N/S 00.00°E/W'"
    }
    
    # NEW: Altitude validation
    validates :altitude, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
    
    # ============================================================================
    # SCOPES
    # ============================================================================
    
    scope :surface_locations, -> { where(altitude: nil).or(where(altitude: 0)) }
    scope :orbital_locations, -> { where('altitude > ?', 0) }
    scope :low_orbit, -> { where('altitude > 0 AND altitude <= ?', 2_000_000) }
    scope :medium_orbit, -> { where('altitude > ? AND altitude <= ?', 2_000_000, 35_786_000) }
    scope :high_orbit, -> { where('altitude > ?', 35_786_000) }
    
    # ============================================================================
    # LOCATION TYPE HELPERS
    # ============================================================================
    
    def surface?
      altitude.nil? || altitude.zero?
    end
    
    def orbital?
      !surface?
    end
    
    def orbit_type
      return nil if surface?
      
      case altitude
      when 0..2_000_000
        :low
      when 2_000_000..35_786_000
        :medium
      else
        :high
      end
    end
    
    def altitude_km
      altitude ? altitude / 1000.0 : nil
    end
    
    def altitude_km=(km)
      self.altitude = km ? km * 1000.0 : nil
    end
    
    # ============================================================================
    # COORDINATE PARSING
    # ============================================================================
    
    def latitude
      return @latitude if defined?(@latitude)
      
      match = coordinates.match(/(\d+\.\d+)°([NS])/)
      return nil unless match
      
      lat = match[1].to_f
      lat *= -1 if match[2] == 'S'
      @latitude = lat
    end
    
    def longitude
      return @longitude if defined?(@longitude)
      
      match = coordinates.match(/(\d+\.\d+)°([EW])/)
      return nil unless match
      
      lon = match[1].to_f
      lon *= -1 if match[2] == 'W'
      @longitude = lon
    end
    
    # ============================================================================
    # ORBITAL MECHANICS
    # ============================================================================
    
    def orbital_period
      return nil if surface?
      return nil unless celestial_body.respond_to?(:mass) && celestial_body.respond_to?(:radius)
      
      gravitational_parameter = celestial_body.gravitational_parameter
      orbital_radius = celestial_body.radius + altitude
      
      2 * Math::PI * Math.sqrt((orbital_radius ** 3) / gravitational_parameter)
    end
    
    def orbital_velocity
      return nil if surface?
      return nil unless celestial_body.respond_to?(:mass) && celestial_body.respond_to?(:radius)
      
      gravitational_parameter = celestial_body.gravitational_parameter
      orbital_radius = celestial_body.radius + altitude
      
      Math.sqrt(gravitational_parameter / orbital_radius)
    end
    
    def gravity
      return celestial_body.surface_gravity if surface?
      return nil unless celestial_body.respond_to?(:mass) && celestial_body.respond_to?(:radius)
      
      gravitational_parameter = celestial_body.gravitational_parameter
      orbital_radius = celestial_body.radius + altitude
      
      gravitational_parameter / (orbital_radius ** 2)
    end
    
    # ============================================================================
    # LOCATION DESCRIPTION
    # ============================================================================
    
    def description
      if surface?
        "Surface location at #{coordinates} on #{celestial_body.name}"
      else
        orbit = orbit_type.to_s.capitalize
        "#{orbit} orbit at #{altitude_km.round(0)} km altitude above #{celestial_body.name} (#{coordinates})"
      end
    end
    
    def full_coordinates
      if orbital?
        "#{coordinates} @ #{altitude_km.round(0)} km"
      else
        coordinates
      end
    end
  end
end