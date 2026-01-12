module CelestialBodies
  module MinorBodies
    class Comet < CelestialBody
      # Comets are small icy bodies that release gas when near a star
      
      # Source regions for comets
      SOURCE_REGIONS = ['Oort Cloud', 'Kuiper Belt', 'Scattered Disc', 'Extrasolar']
      
      # Typical composition of comets
      TYPICAL_COMPOSITION = {
        'water ice' => 60,
        'carbon dioxide' => 20,
        'methane' => 10,
        'ammonia' => 5,
        'dust' => 5
      }
      
      # Store additional properties
      store :properties, accessors: [
        :perihelion, # Closest approach to star (AU)
        :aphelion,   # Furthest distance from star (AU)
        :eccentricity, # Orbit eccentricity 
        :source_region, # Where the comet originated
        :active,     # Whether the comet is currently active (has coma/tail)
        :last_perihelion_date, # Date of last closest approach
        :next_perihelion_date, # Date of next closest approach
        :nucleus_size, # Size of the solid core in meters
        :coma_size,  # Size of the gas cloud when active in km
        :tail_length # Length of the tail when active in km
      ]
      
      # Set STI type
      before_validation :set_sti_type
      
      # Validations specific to comets
      validates :mass, numericality: { less_than: 1e19 }, allow_nil: true # Comets are small
      validates :radius, numericality: { less_than: 100000 }, allow_nil: true # Typical nucleus < 100km
      validate :validate_orbit
      
      # Comet-specific methods
      
      # Calculate if the comet is currently active based on distance to star
      def active?
        return self.active if self.active.present? # Use stored value if available
        
        # Comets typically become active within ~3-5 AU of their star
        return false unless solar_system&.current_star
        
        distance = current_star_distance
        if distance.present?
          # Comets typically activate around 3-5 AU from their star
          distance < 5.0
        else
          false
        end
      end
      
      # Get current distance to star
      def current_star_distance
        return nil unless solar_system&.current_star
        
        star_distance = star_distances.find_by(star: solar_system.current_star)
        star_distance&.distance
      end
      
      # Calculate tail length based on distance to star
      def calculate_tail_length
        return 0 unless active?
        
        distance = current_star_distance
        return 0 unless distance.present?
        
        # Simple inverse square relationship - closer to star, longer tail
        # At 1 AU, a typical comet might have a tail of 10 million km
        base_length = 1e7 # 10 million km
        nucleus = nucleus_size || radius || 1000 # Default to 1km if unknown
        size_factor = Math.sqrt(nucleus / 1000.0) # Larger nucleus = longer tail
        
        # Calculate based on distance (inverse square) and size
        (base_length * size_factor) / (distance ** 2)
      end
      
      # Comets lose mass when active
      def calculate_mass_loss_rate
        return 0 unless active?
        
        distance = current_star_distance
        return 0 unless distance.present? && mass.present?
        
        # Simple model: mass loss is inversely proportional to square of distance
        # At 1 AU, a typical comet might lose 1e3 kg/s
        base_rate = 1e3 # kg/s
        nucleus = nucleus_size || radius || 1000
        size_factor = nucleus / 1000.0
        
        # Larger comets lose more mass, closer comets lose more mass
        (base_rate * size_factor) / (distance ** 2)
      end
      
      # Estimate remaining active lifetime
      def estimated_remaining_lifetime
        return nil unless mass.present? && active?
        
        loss_rate = calculate_mass_loss_rate
        return nil if loss_rate <= 0
        
        # Very rough estimate assuming constant mass loss rate
        # In reality, comets have complex activity cycles
        # Return in years
        (mass / loss_rate) / (365.25 * 24 * 3600)
      end
      
      # Determine the source region if not explicitly set
      def determine_source_region
        return source_region if source_region.present?
        
        if aphelion.present?
          if aphelion > 10000 # Far beyond Neptune
            'Oort Cloud'
          elsif aphelion > 50 # Beyond Neptune
            'Scattered Disc'
          elsif aphelion > 30 # Near Neptune
            'Kuiper Belt'
          else
            'Inner Solar System'
          end
        else
          'Unknown'
        end
      end
      
      # Override as comets aren't spherical
      def is_spherical?
        false
      end
      
      private
      
      def set_sti_type
        self.type = 'CelestialBodies::MinorBodies::Comet'
      end
      
      def validate_orbit
        if perihelion.present? && aphelion.present?
          if perihelion >= aphelion
            errors.add(:perihelion, "must be less than aphelion")
          end
          
          if eccentricity.present?
            calculated_e = (aphelion - perihelion) / (aphelion + perihelion)
            if (calculated_e - eccentricity).abs > 0.1
              errors.add(:eccentricity, "doesn't match perihelion and aphelion values")
            end
          end
        end
      end
    end
  end
end