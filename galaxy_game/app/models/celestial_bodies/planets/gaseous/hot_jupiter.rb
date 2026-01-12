module CelestialBodies
  module Planets
    module Gaseous
      class HotJupiter < GasGiant
        # Hot Jupiters are gas giants very close to their stars
        validates :surface_temperature, numericality: { greater_than: 900 }, allow_nil: true
        validates :orbital_period, numericality: { less_than: 10 * 24 * 3600 }, allow_nil: true # Less than 10 days
        
        # Set STI type
        before_validation :set_sti_type
        
        # Hot Jupiters are tidally locked
        def tidally_locked?
          true
        end
        
        # Hot Jupiters have extreme temperature differences
        def day_night_temperature_difference
          return 0 unless surface_temperature.present?
          
          # Day side is much hotter than night side
          day_temp = surface_temperature
          night_temp = surface_temperature * 0.6 # Simplified approximation
          
          day_temp - night_temp
        end
        
        # Atmospheric characteristics specific to hot Jupiters
        def atmospheric_characteristics
          {
            evaporation_rate: "extreme",
            temperature: "extremely_hot",
            volatiles: "depleted",
            composition: "exotic"
          }
        end
        
        # Hot Jupiters typically have fewer moons due to their close orbit
        def estimate_moon_count
          # Usually 0-1 moons for hot Jupiters
          [super / 10, 1].min
        end
        
        # Ring systems are less likely for hot Jupiters
        def ring_system_probability
          0.15 # 15% probability - much lower than regular gas giants
        end
        
        private
        
        def set_sti_type
          self.type = 'CelestialBodies::Planets::Gaseous::HotJupiter'
        end
      end
    end
  end
end