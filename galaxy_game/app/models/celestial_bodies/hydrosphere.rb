module CelestialBodies
  class Hydrosphere < ApplicationRecord
    belongs_to :celestial_body
    has_many :liquid_materials, dependent: :destroy

    attr_accessor :simulation_running

    # Validations for hydrosphere attributes
    validates :liquid_volume, :lakes, :rivers, :oceans, :ice, numericality: true

    # Callbacks
    after_create :set_defaults
    after_update :run_simulation

    private

    # Set default values for the hydrosphere attributes
    def set_defaults
      self.liquid_name ||= 'unknown'
      self.liquid_volume ||= 0
      self.oceans ||= 0
      self.lakes ||= 0
      self.rivers ||= 0
      self.ice ||= 0
    end

    # Run the hydrosphere simulation after the model has been updated (but not on creation)
    def run_simulation
      return if new_record? || simulation_running # Skip if it's a new record or simulation is already running
  
      self.simulation_running = true
      TerraSim::HydrosphereSimulationService.new(celestial_body).simulate
    ensure
      self.simulation_running = false
    end
  end
end



