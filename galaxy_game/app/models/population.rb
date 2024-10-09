class Population
    attr_accessor :total_population, :growth_rate, :arrival_rate, :departure_rate, :birth_rate, :death_rate
  
    def initialize(initial_population, growth_rate = 0.05, arrival_rate = 0, departure_rate = 0, birth_rate = 0.02, death_rate = 0.01)
      @total_population = initial_population
      @growth_rate = growth_rate  # Natural growth rate
      @arrival_rate = arrival_rate  # Incoming people per year
      @departure_rate = departure_rate  # Outgoing people per year
      @birth_rate = birth_rate  # Births per year as a fraction of total population
      @death_rate = death_rate  # Deaths per year as a fraction of total population
    end
  
    def update_population(years)
      # Calculate natural growth (births)
      natural_growth = @total_population * @growth_rate * years
      # Calculate births and deaths
      total_births = (@total_population * @birth_rate * years).to_i
      total_deaths = (@total_population * @death_rate * years).to_i
  
      # Update total population
      @total_population += natural_growth + total_births - total_deaths
      @total_population += @arrival_rate * years
      @total_population -= @departure_rate * years
  
      # Output population change details
      puts "Population updated: Births: #{total_births}, Deaths: #{total_deaths}, New Population: #{@total_population}."
    end
  end
  