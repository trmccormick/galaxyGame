class SupplyChain
    attr_accessor :resources, :delivery_time, :disruptions
  
    def initialize
      @resources = {}
      @delivery_time = 0  # Time in years for supply deliveries
      @disruptions = 0  # Number of disruptions in the supply chain
    end
  
    def add_resource(resource, amount)
      @resources[resource] ||= 0
      @resources[resource] += amount
    end
  
    def disrupt_supply
      @disruptions += 1
      @delivery_time += rand(1..3)  # Randomly extend delivery time due to disruption
      puts "Supply chain disrupted! New delivery time: #{@delivery_time} years."
    end
  
    def check_supply(colony)
      # Check if the colony is facing supply issues
      if @resources.empty? || @delivery_time > 0
        colony.decrease_resources
        puts "Supply issues detected at #{colony.name}!"
      end
    end
  end
  