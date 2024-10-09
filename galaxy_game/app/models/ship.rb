class Ship
    attr_accessor :arrival_capacity, :departure_capacity
  
    def initialize(arrival_capacity, departure_capacity)
      @arrival_capacity = arrival_capacity  # Max number of people arriving
      @departure_capacity = departure_capacity  # Max number of people departing
    end
  
    def arrive(colony)
      # Add people to the colony's population
      colony.population.arrival_rate += [@arrival_capacity, colony.population.total_population].min
      puts "#{@arrival_capacity} people arrived at #{colony.name}."
    end
  
    def depart(colony)
      # Remove people from the colony's population
      colony.population.departure_rate += [@departure_capacity, colony.population.total_population].min
      puts "#{@departure_capacity} people departed from #{colony.name}."
    end
  end
  