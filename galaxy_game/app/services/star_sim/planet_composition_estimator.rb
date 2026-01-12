module StarSim
    class PlanetCompositionEstimator
      attr_reader :mass, :orbital_zone, :type
  
      # @param mass [Float] in Earth masses
      # @param orbital_zone [Symbol] :inner_zone, :habitable_zone, or :outer_zone
      # @param type [Symbol] optional: :terrestrial, :gas_giant, :ice_giant, :dwarf_planet
      def initialize(mass:, orbital_zone:, type: nil)
        @mass = mass
        @orbital_zone = orbital_zone
        @type = type
      end
  
      def estimate
        return gas_giant_profile if gas_giant?
        return ice_giant_profile if ice_giant?
  
        case orbital_zone
        when :inner_zone
          rocky_body_profile
        when :habitable_zone
          mixed_body_profile
        when :outer_zone
          icy_body_profile
        else
          default_profile
        end
      end
  
      private
  
      def gas_giant?
        type == :gas_giant || (mass > 50)
      end
  
      def ice_giant?
        type == :ice_giant || (mass > 10 && mass <= 50 && orbital_zone == :outer_zone)
      end
  
      def rocky_body_profile
        {
          core: :iron_nickel,
          mantle: :silicate,
          surface: :rock,
          volatile_content: :low
        }
      end
  
      def mixed_body_profile
        {
          core: :iron_nickel,
          mantle: :silicate,
          surface: :rock_with_water,
          volatile_content: :medium
        }
      end
  
      def icy_body_profile
        {
          core: :rock,
          mantle: :ice,
          surface: :ice,
          volatile_content: :high
        }
      end
  
      def gas_giant_profile
        {
          core: :rock_or_ice,
          atmosphere: :hydrogen_helium,
          surface: :gaseous,
          volatile_content: :very_high
        }
      end
  
      def ice_giant_profile
        {
          core: :rock,
          mantle: :water_ammonia_methane_ice,
          atmosphere: :hydrogen_helium_methane,
          surface: :icy_gas,
          volatile_content: :very_high
        }
      end
  
      def default_profile
        {
          core: :unknown,
          mantle: :unknown,
          surface: :unknown,
          volatile_content: :unknown
        }
      end
    end
  end
  