module StarSim
    class MoonGenerator
      def initialize(parent_body:)
        @parent_body = parent_body
      end
  
      def generate
        return [] unless valid_host?
  
        moon_count = estimate_moon_count
        return [] if moon_count.zero?
  
        Array.new(moon_count) { generate_moon }
      end
  
      private
  
      def valid_host?
        %w[gas_giant ice_giant terrestrial].include?(@parent_body.body_type)
      end
  
      def estimate_moon_count
        case @parent_body.body_type
        when "gas_giant" then rand(10..50)
        when "ice_giant" then rand(5..20)
        when "terrestrial" then rand(0..3)
        else 0
        end
      end
  
      def generate_moon
        distance = rand(0.001..0.05) * @parent_body.radius_km
        name = "#{@parent_body.name} - Moon #{SecureRandom.hex(2).upcase}"
  
        {
          name: name,
          type: :moon,
          parent_id: @parent_body.id,
          orbital_distance_km: distance.round(2),
          radius_km: rand(100..2500),
          mass: rand(1e19..7e22).round(2),
          density: rand(1.5..3.5).round(2)
        }
      end
    end
  end
  