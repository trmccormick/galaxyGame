# app/models/units/greenhouse.rb
module Units
  class Greenhouse < BaseUnit
    attr_accessor :crop_yield_increase

    def initialize(name, base_materials, operating_requirements, input_resources, output_resources)
      super(name, base_materials, operating_requirements, input_resources, output_resources)
      @crop_yield_increase = 0
    end
  
    protected
  
    def produce_resources
      # Crop yield increase based on compost use
      if Resource.resources[:compost] > 0
        compost_used = 2  # Example amount
        if Resource.resources[:compost] >= compost_used
          Resource.consume(:compost, compost_used)
          puts "#{name} uses #{compost_used} units of compost for enhanced crop yields."
          @crop_yield_increase += compost_used * 2  # Enhance yield based on compost used
        else
          puts "Not enough compost available!"
        end
      end
  
      # Optionally use sludge if available to enhance growth
      if Resource.resources[:sludge] > 0
        puts "#{name} can use available sludge to enhance crop growth."
        # Logic to utilize sludge directly if necessary
        # For example, this could be a minor boost to the crop yield
      end
  
      # Produce other resources like food and biomass
      # (Implementation remains the same)
    end
  end
end
  