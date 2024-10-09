class SimulationController < ApplicationController
    def index
      @plants = Plant.all
      @environments = Environment.all
    end
  
    def run_simulation
      Environment.all.each(&:simulate_environmental_changes)
      Plant.all.each(&:simulate_growth_and_death)
  
      redirect_to simulation_index_path, notice: 'Simulation run completed.'
    end
  end
  