class IceGiant < CelestialBody
    # Specific attributes for ice giants
    validates :methane_concentration, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
    validates :ammonia_concentration, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  
    # Ice giants can't be terraformed in the traditional sense
    def terraformed?
      false
    end
  
    # Overriding habitability score for ice giants
    def habitability_score
      "Ice giants are not habitable."
    end
end