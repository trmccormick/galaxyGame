# app/models/composting.rb
module Units
    class Composting < BaseUnit
    attr_accessor :compost_yield
  
    def initialize(name, base_materials, operating_requirements, input_resources, output_resources)
      super(name, base_materials, operating_requirements, input_resources, output_resources)
      @compost_yield = 0
    end
  
    protected
  
    def consume_resources
      # Check if sludge is available
      sludge_needed = 5  # Example amount
  
      if Resource.resources[:sludge] >= sludge_needed
        puts "#{name} is composting #{sludge_needed} units of sludge."
        Resource.consume(:sludge, sludge_needed)
  
        # Produce compost
        compost_produced = sludge_needed * 0.8  # Assume 80% conversion rate
        puts "#{name} produces #{compost_produced} units of compost."
        Resource.add(:compost, compost_produced)  # Add compost to resources
      else
        puts "Not enough sludge available for composting, operation continues without it!"
        # Optional: Handle the scenario when there's no sludge (e.g., lower compost yield)
      end
    end
  end
end
  