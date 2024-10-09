class SimulationsController < ApplicationController
  def run
    celestial_body = CelestialBody.find(params[:id])
    terra_sim = TerraSim.new(celestial_body)
    terra_sim.run_simulation

    redirect_to celestial_body_path(celestial_body), notice: "Simulation completed!"
  end
end
