# app/models/celestial_bodies/planets/gaseous/gas_giant.rb
module CelestialBodies
  module Planets
    module Gaseous
      class GasGiant < GaseousPlanet
        # This is CRUCIAL for STI: update the `type` column for new records
        before_validation :set_sti_type
        
        # Gas giants can't be terraformed in the traditional sense
        def terraformed?
          false
        end
        
        # Ensure density and mass are stored as plain decimals
        # Remove any custom getter/setter for density and mass

        # Validation for density
        validates :density, numericality: { less_than: 2.0 }, allow_nil: true

        # Overriding habitability score for gas giants
        def habitability_score
          "Gas giants are not habitable."
        end
        
        # Method to estimate number of moons
        def estimate_moon_count
          Rails.logger.debug "GasGiant#estimate_moon_count mass: #{mass.inspect}"
          return 0 unless mass.present? && mass.to_f > 0
          base_moons = 79
          jupiter_mass = 1.898e27
          count = (base_moons * (mass.to_f / jupiter_mass)).round
          count = [count, 100].min
          count
        end
        
        # Check for ring system probability
        def ring_system_probability
          # Gas giants often have ring systems
          0.75 # 75% probability for gas giants
        end
        
        private
        
        # New STI type setter
        def set_sti_type
          self.type = 'CelestialBodies::Planets::Gaseous::GasGiant'
        end
      end
    end
  end
end