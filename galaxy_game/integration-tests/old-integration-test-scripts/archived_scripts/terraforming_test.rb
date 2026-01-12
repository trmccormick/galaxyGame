class TerraformingTest
  def initialize
    @mars = CelestialBodies::TerrestrialPlanet.find_by(name: "Mars")
    @simulator = TerraSim::Simulator.new(@mars)
    
    @data = {
      cycles: [],
      temperature: [],
      pressure: [],
      co2_atmosphere: [],
      co2_regolith: [],
      water_vapor: [],
      water_ice: [],
      water_liquid: []
    }
  end
  
  def run(cycles = 100)
    print_initial_status
    
    cycles.times do |i|
      puts "\n\nCycle #{i+1}:"
      
      # Run the simulator
      @simulator.calc_current
      
      # Record data
      record_data(i)
      
      # Print status every 10 cycles
      print_status if (i+1) % 10 == 0
    end
    
    print_final_results
  end
  
  private
  
  def print_initial_status
    puts "Initial Mars Status:"
    puts "Temperature: #{@mars.surface_temperature.round(2)}K"
    puts "Pressure: #{(@mars.atmosphere.pressure).round(4)} atm"
    
    puts "\nAtmospheric Composition:"
    @mars.atmosphere.gases.each do |gas|
      puts "  #{gas.name}: #{gas.percentage.round(2)}% (#{gas.mass.round(2)} kg)"
    end
    
    puts "\nVolatiles in Regolith:"
    if @mars.geosphere&.crust_composition&.dig("volatiles")
      @mars.geosphere.crust_composition["volatiles"].each do |name, percentage|
        volatile_mass = @mars.geosphere.total_crust_mass * (percentage.to_f / 100.0)
        puts "  #{name}: #{percentage.to_f.round(2)}% (#{volatile_mass.round(2)} kg)"
      end
    end
    
    puts "\nWater Distribution:"
    if @mars.hydrosphere&.state_distribution
      total_water = @mars.hydrosphere.total_hydrosphere_mass
      state_dist = @mars.hydrosphere.state_distribution
      
      solid_mass = total_water * (state_dist["solid"].to_f / 100.0)
      liquid_mass = total_water * (state_dist["liquid"].to_f / 100.0)
      vapor_mass = total_water * (state_dist["vapor"].to_f / 100.0)
      
      puts "  Ice: #{state_dist["solid"].to_f.round(2)}% (#{solid_mass.round(2)} kg)"
      puts "  Liquid: #{state_dist["liquid"].to_f.round(2)}% (#{liquid_mass.round(2)} kg)"
      puts "  Vapor: #{state_dist["vapor"].to_f.round(2)}% (#{vapor_mass.round(2)} kg)"
    end
  end
  
  def record_data(cycle)
    @data[:cycles] << cycle
    @data[:temperature] << @mars.surface_temperature
    @data[:pressure] << @mars.atmosphere.pressure
    
    # Track CO2
    co2_gas = @mars.atmosphere.gases.find_by(name: 'CO2')
    @data[:co2_atmosphere] << (co2_gas&.mass || 0)
    
    co2_regolith = 0
    if @mars.geosphere&.crust_composition&.dig("volatiles", "CO2")
      co2_percentage = @mars.geosphere.crust_composition["volatiles"]["CO2"].to_f
      co2_regolith = @mars.geosphere.total_crust_mass * (co2_percentage / 100.0)
    end
    @data[:co2_regolith] << co2_regolith
    
    # Track water
    water_vapor = 0
    h2o_gas = @mars.atmosphere.gases.find_by(name: 'H2O')
    water_vapor = h2o_gas&.mass || 0
    @data[:water_vapor] << water_vapor
    
    if @mars.hydrosphere&.state_distribution
      total_water = @mars.hydrosphere.total_hydrosphere_mass
      state_dist = @mars.hydrosphere.state_distribution
      
      water_ice = total_water * (state_dist["solid"].to_f / 100.0)
      water_liquid = total_water * (state_dist["liquid"].to_f / 100.0)
      
      @data[:water_ice] << water_ice
      @data[:water_liquid] << water_liquid
    else
      @data[:water_ice] << 0
      @data[:water_liquid] << 0
    end
  end
  
  def print_status
    cycle = @data[:cycles].last
    puts "\nStatus at cycle #{cycle}:"
    puts "Temperature: #{@data[:temperature].last.round(2)}K"
    puts "Pressure: #{(@data[:pressure].last).round(4)} atm"
    puts "CO2 in atmosphere: #{@data[:co2_atmosphere].last.round(2)} kg"
    puts "CO2 in regolith: #{@data[:co2_regolith].last.round(2)} kg"
    puts "Water vapor: #{@data[:water_vapor].last.round(2)} kg"
    puts "Water ice: #{@data[:water_ice].last.round(2)} kg"
    puts "Liquid water: #{@data[:water_liquid].last.round(2)} kg"
  end
  
  def print_final_results
    puts "\n\nFinal Results:"
    puts "Temperature change: #{(@data[:temperature].last - @data[:temperature].first).round(2)}K"
    puts "Pressure change: #{(@data[:pressure].last - @data[:pressure].first).round(4)} atm"
    
    puts "\nMaterial Transfers:"
    co2_regolith_change = @data[:co2_regolith].first - @data[:co2_regolith].last
    co2_atmo_change = @data[:co2_atmosphere].last - @data[:co2_atmosphere].first
    puts "CO2 released from regolith: #{co2_regolith_change.round(2)} kg"
    puts "CO2 added to atmosphere: #{co2_atmo_change.round(2)} kg"
    
    ice_melted = @data[:water_ice].first - @data[:water_ice].last
    liquid_increase = @data[:water_liquid].last - @data[:water_liquid].first
    vapor_increase = @data[:water_vapor].last - @data[:water_vapor].first
    puts "Ice melted: #{ice_melted.round(2)} kg"
    puts "Liquid water increase: #{liquid_increase.round(2)} kg"
    puts "Water vapor increase: #{vapor_increase.round(2)} kg"
    
    # Calculate when habitability thresholds might be reached
    pressure_rate = (@data[:pressure].last - @data[:pressure].first) / @data[:cycles].size
    temp_rate = (@data[:temperature].last - @data[:temperature].first) / @data[:cycles].size
    
    cycles_to_01_atm = pressure_rate > 0 ? (0.1 - @data[:pressure].last) / pressure_rate : Float::INFINITY
    cycles_to_273k = temp_rate > 0 ? (273 - @data[:temperature].last) / temp_rate : Float::INFINITY
    
    puts "\nProjected Cycles to Habitability Thresholds:"
    puts "0.1 atm pressure: #{cycles_to_01_atm.round} cycles"
    puts "273K temperature (water freezing point): #{cycles_to_273k.round} cycles"
  end
end

# Run the test
test = TerraformingTest.new
test.run(100)