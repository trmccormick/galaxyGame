class GasGiant < CelestialBody
    # Specific attributes for gas giants
    validates :hydrogen_concentration, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
    validates :helium_concentration, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  
    # Gas giants can't be terraformed in the traditional sense
    def terraformed?
      false
    end
  
    # Overriding habitability score for gas giants
    def habitability_score
      "Gas giants are not habitable."
    end
end