class SimulationController < ApplicationController
  def index
    # Default to our current solar system
    @solar_system = SolarSystem.includes(:stars, :celestial_bodies).first
    
    if @solar_system.nil?
      # If no solar system exists, show all celestial bodies
      @celestial_bodies = CelestialBodies::CelestialBody.all
    else
      # Otherwise, show bodies in our current system
      @celestial_bodies = @solar_system.celestial_bodies
      @star = @solar_system.primary_star  # Use primary_star method instead of .star
    end
    
    # Set @plants to empty array to prevent error in old view
    @plants = []
  end

  def run
    @celestial_body = CelestialBodies::CelestialBody.find(params[:id])
    
    # Run the simulator for this body
    simulator = TerraSim::Simulator.new(@celestial_body)
    simulator.calc_current
    
    # Redirect with success message
    redirect_to simulation_path, notice: "Simulation completed for #{@celestial_body.name}!"
  rescue => e
    # Handle errors
    redirect_to simulation_path, alert: "Simulation failed: #{e.message}"
  end
  
  def run_all
    # Run simulation for all bodies in our solar system
    @solar_system = SolarSystem.first
    
    if @solar_system
      @solar_system.celestial_bodies.each do |body|
        simulator = TerraSim::Simulator.new(body)
        simulator.calc_current
      end
      redirect_to simulation_path, notice: "Simulation completed for all celestial bodies!"
    else
      redirect_to simulation_path, alert: "No solar system found to simulate!"
    end
  end
end
