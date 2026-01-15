module Admin
  class SimulationController < ApplicationController
    def index
      # Load solar system and celestial bodies for simulation control
      @solar_system = SolarSystem.includes(:stars, :celestial_bodies).first
      
      if @solar_system.nil?
        @celestial_bodies = CelestialBodies::CelestialBody.all
      else
        @celestial_bodies = @solar_system.celestial_bodies
        @star = @solar_system.primary_star
      end
    end

    def run
      @celestial_body = CelestialBodies::CelestialBody.find(params[:id])
      
      # Run the simulator for this body
      simulator = TerraSim::Simulator.new(@celestial_body)
      simulator.calc_current
      
      redirect_to admin_simulation_path, notice: "Simulation completed for #{@celestial_body.name}!"
    rescue => e
      redirect_to admin_simulation_path, alert: "Simulation failed: #{e.message}"
    end
    
    def run_all
      # Run simulation for all bodies in our solar system
      @solar_system = SolarSystem.first
      
      if @solar_system
        @solar_system.celestial_bodies.each do |body|
          simulator = TerraSim::Simulator.new(body)
          simulator.calc_current
        end
        redirect_to admin_simulation_path, notice: "Simulation completed for all celestial bodies!"
      else
        redirect_to admin_simulation_path, alert: "No solar system found to simulate!"
      end
    end
    
    def spheres
      # Sphere simulation controls
      @celestial_bodies = CelestialBodies::CelestialBody.includes(:atmosphere, :hydrosphere, :geosphere, :biosphere).all
    end
    
    def time_control
      # Time advancement controls
    end
    
    def testing
      # Scenario testing tools
    end
  end
end
