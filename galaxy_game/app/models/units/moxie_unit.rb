module Units
    class MoxieUnit < BaseUnit
    
    attr_accessor :energy_consumption, :output_resources
  
    def initialize
      super()                                       # Initialize as a BaseUnit
      @energy_consumption = 100                     # Energy required to operate the MOXIE unit
      @output_resources = { oxygen: 10 }            # Example output of oxygen
    end
  
    def activate
      # Logic to produce oxygen using electrical energy
      puts "MOXIE unit activated. Producing #{output_resources[:oxygen]} units of oxygen."
    end
  end
end