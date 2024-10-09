class Hazard
    attr_accessor :name, :radiation_exposure, :mortality_rate_increase, :birth_rate_decrease
  
    def initialize(name, radiation_exposure = 0, mortality_rate_increase = 0, birth_rate_decrease = 0)
      @name = name
      @radiation_exposure = radiation_exposure  # e.g., rad exposure per year
      @mortality_rate_increase = mortality_rate_increase  # Fractional increase in death rate
      @birth_rate_decrease = birth_rate_decrease  # Fractional decrease in birth rate
    end
  
    def apply_hazards(population)
      # Adjust birth and death rates based on hazards
      population.death_rate += @mortality_rate_increase
      population.birth_rate -= @birth_rate_decrease
    end
  end
  