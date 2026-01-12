# app/models/concerns/housing.rb
module Housing
    extend ActiveSupport::Concern
  
    included do
      attr_accessor :population_capacity
  
      # Ensure population_capacity has a default value
      after_initialize :set_default_population_capacity
    end
  
    def initialize_housing(capacity)
      @population_capacity = capacity
      puts "Housing unit initialized with capacity for #{capacity} people."
    end
  
    def allocate_space(num_people)
      if num_people <= population_capacity
        puts "#{num_people} people allocated space in the housing unit."
      else
        puts "Not enough space for #{num_people} people!"
      end
    end
  
    private
  
    def set_default_population_capacity
      @population_capacity ||= 100  # Default capacity can be set here
    end
end
  
  