module StarSim
    class PlanetBuilder
      def initialize(seed, star)
        @seed = seed
        @star = star
      end
  
      def build
        CelestialBodies::CelestialBody.create!(
          name: generate_name,
          mass: total_mass_kg,
          radius: estimate_radius,
          density: estimated_density,
          orbital_period: orbital_period,
          semi_major_axis: @seed.orbit,
          gas_mass: @seed.gas_mass,
          core_mass: @seed.mass,
          type: classify, # STI type (e.g., 'CelestialBodies::GasGiant') if you're using it
          celestial_star: @star
        )
      end
  
      private
  
      def generate_name
        "Planet-#{SecureRandom.hex(3)}"
      end
  
      def total_mass_kg
        (@seed.total_mass * earth_mass_kg).round
      end
  
      def earth_mass_kg
        5.972e24
      end
  
      def estimate_radius
        if gas_giant?
          (70000 * (@seed.total_mass)**0.5).round # km, Jupiter-like
        else
          (6371 * (@seed.mass)**0.3).round # km, Earth-like
        end
      end
  
      def orbital_period
        Math.sqrt(@seed.orbit**3).round(2) # in Earth years
      end
  
      def estimated_density
        gas_giant? ? 1.3 : 5.5 # g/cm³
      end
  
      def gas_giant?
        @seed.gas_mass > 0.1
      end
  
      def classify
        if gas_giant?
          'CelestialBodies::GasGiant'
        elsif @seed.total_mass < 0.1
          'CelestialBodies::DwarfPlanet'
        else
          'Searched for regex `TerrestrialPlanet|GasGiant|IceGiant|Moon|DwarfPlanet` (`**/app/models/celestial_bodies/**/*.rb`), 20 results

Searched for regex `module|class` (`**/app/models/celestial_bodies/**/*.rb`), 20 results

Read [](file:///Users/tam0013/Documents/git/galaxyGame/galaxy_game/app/models/celestial_bodies/celestial_body.rb#260-260), lines 260 to 300

Searched for regex `module CelestialBodies|class TerrestrialPlanet|class GasGiant|class IceGiant|class Moon|class DwarfPlanet` (`**/app/models/celestial_bodies/**/*.rb`), 20 results

Searched for regex `class TerrestrialPlanet|class GasGiant|class IceGiant` (`**/app/models/celestial_bodies/**/*.rb`), 3 results

Searched for regex `module CelestialBodies` (`**/app/models/celestial_bodies/planets/rocky/terrestrial_planet.rb`), 1 result

Read [](file:///Users/tam0013/Documents/git/galaxyGame/galaxy_game/app/models/celestial_bodies/planets/rocky/terrestrial_planet.rb#1-1), lines 1 to 20

Searched for text `CelestialBodies::TerrestrialPlanet` (`**/app/models/celestial_bodies/**/*.rb`), 1 result

Read [](file:///Users/tam0013/Documents/git/galaxyGame/galaxy_game/app/models/celestial_bodies/celestial_body.rb#1-1), lines 1 to 40

Read [](file:///Users/tam0013/Documents/git/galaxyGame/galaxy_game/app/models/celestial_bodies/planets/rocky/terrestrial_planet.rb#1-1), lines 1 to 40

The root cause of the failure is that the code references `CelestialBodies::TerrestrialPlanet`, but the actual class is defined as `CelestialBodies::Planets::Rocky::TerrestrialPlanet`. The same applies to `GasGiant`, '
        end
      end
    end
end
  