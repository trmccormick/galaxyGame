module StarSim
  class OrbitalZoneClassifier
    attr_reader :semi_major_axis_au, :star

    def initialize(semi_major_axis_au:, star:) # Expect a star object
      @semi_major_axis_au = semi_major_axis_au
      @star = star
    end

    def classify
      hz_calculator = HabitableZoneCalculator.new(star)
      inner = hz_calculator.inner_boundary
      outer = hz_calculator.outer_boundary

      if semi_major_axis_au < inner
        :inner_zone
      elsif semi_major_axis_au <= outer
        :habitable_zone
      else
        :outer_zone
      end
    end

    private

    # The habitable_zone_range method is no longer needed here
    # def habitable_zone_range
    #   inner = (0.75 * Math.sqrt(star_luminosity)).round(3)
    #   outer = (1.77 * Math.sqrt(star_luminosity)).round(3)
    #   [inner, outer]
    # end
  end
end