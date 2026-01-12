module StarSim
    class PlanetTypeClassifier
      def initialize(celestial_body, star)
        @body = celestial_body
        @star = star
      end
  
      def classify
        frost_line = FrostLineCalculator.new(@star).frost_line
        distance = @body.semi_major_axis.to_f
        mass = @body.mass.to_f
        density = @body.density.to_f
  
        return :gas_giant if mass >= 50 && distance > frost_line
        return :ice_giant if mass >= 10 && mass < 50 && distance > frost_line
        return :terrestrial_planet if mass.between?(0.1, 10) && density > 3.0
        return :icy_body if mass.between?(0.1, 10) && density < 3.0
        return :asteroidal if mass < 0.1
  
        :unknown
      end
    end
  end