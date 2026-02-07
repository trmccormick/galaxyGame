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

      def build_data
        {
          "name" => generate_name,
          "identifier" => generate_name.upcase.gsub(/\s+/, '-'),
          "type" => classify_data,
          "mass" => @seed.total_mass,
          "radius" => estimate_radius / 6371.0, # in Earth radii
          "density" => estimated_density,
          "gravity" => calculate_gravity(@seed.total_mass, estimate_radius / 1000.0), # m/s²
          "albedo" => rand(0.1..0.6),
          "surface_temperature" => 288, # placeholder
          "size" => estimate_radius / 6371.0,
          "known_pressure" => gas_giant? ? nil : rand(0.1..2.0),
          "geological_activity" => gas_giant? ? nil : rand(10..90),
          "orbits" => [{
            "around" => @star["name"] || @star.name,
            "semi_major_axis_au" => @seed.orbit,
            "eccentricity" => rand(0.0..0.1),
            "inclination_deg" => rand(0.0..5.0),
            "orbital_period_days" => orbital_period * 365.25,
            "distance" => @seed.orbit
          }],
          "atmosphere_attributes" => gas_giant? ? nil : generate_atmosphere_data,
          "hydrosphere_attributes" => gas_giant? ? nil : generate_hydrosphere_data,
          "geosphere_attributes" => gas_giant? ? nil : generate_geosphere_data,
          "biosphere_attributes" => gas_giant? ? nil : generate_biosphere_data,
          "market_status" => "unclaimed_procedural"
        }
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

      def classify_data
        if gas_giant?
          'gas_giant'
        elsif @seed.total_mass < 0.1
          'dwarf_planet'
        else
          'terrestrial'
        end
      end

      def calculate_gravity(mass_earth, radius_km)
        # G * M / R^2, with Earth units
        9.8 * mass_earth / (radius_km / 6371.0)**2
      end

      def generate_atmosphere_data
        # Simple placeholder
        {
          "composition" => {
            "N2" => { "percentage" => 78.0 },
            "O2" => { "percentage" => 21.0 },
            "CO2" => { "percentage" => 0.04 }
          },
          "pressure" => rand(0.5..1.5)
        }
      end

      def generate_hydrosphere_data
        {
          "total_water_mass" => @seed.total_mass * rand(0.001..0.01),
          "surface_coverage" => rand(0.0..1.0)
        }
      end

      def generate_geosphere_data
        {
          "geological_activity" => rand(10..90),
          "tectonic_activity" => rand < 0.4,
          "total_crust_mass" => @seed.total_mass * rand(0.01..0.05),
          "total_mantle_mass" => @seed.total_mass * rand(0.6..0.7),
          "total_core_mass" => @seed.total_mass * rand(0.25..0.35)
        }
      end

      def generate_biosphere_data
        {
          "biosphere_type" => "none",
          "complexity" => 0,
          "habitability_score" => rand(0.0..1.0)
        }
      end
    end
end
  