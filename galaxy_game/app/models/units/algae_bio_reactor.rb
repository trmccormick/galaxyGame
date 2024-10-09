# app/models/algae_bio_reactor.rb
module Units
  class AlgaeBioreactor < BaseUnit
    attr_accessor :capacity, :energy_consumption, :water_consumption, :food_output, :biomass_output, :oxygen_output
  
    def initialize
      super()
      @capacity = 1000  # capacity in liters of algae culture
      @energy_consumption = 50  # energy required in kWh per day
      @water_consumption = 200  # water required in liters per day
      @food_output = 100  # food produced in kg per day
      @biomass_output = 150  # biomass produced in kg per day
      @oxygen_output = 200  # oxygen produced in liters per day
    end
  
    # Operate method to consume resources and produce outputs
    def operate(resources)
      return unless resources[:water] >= @water_consumption && resources[:energy] >= @energy_consumption
  
      # Consume resources
      resources[:water] -= @water_consumption
      resources[:energy] -= @energy_consumption
  
      # Produce outputs
      resources[:food] += @food_output
      resources[:biomass] += @biomass_output
      resources[:oxygen] += @oxygen_output
  
      # Optionally handle waste materials (e.g., sludge)
      handle_sludge(resources)
    end
  
    private
  
    # Method to handle sludge production
    def handle_sludge(resources)
      sludge_produced = @biomass_output * 0.1  # 10% of biomass output is sludge
      resources[:sludge] += sludge_produced
    end
  end
end
  