class TerraSimJob
  include Sidekiq::Job
  queue_as :low_priority

  def perform
    CelestialBody.where(active: true).find_each do |body|
      TerraSim::Simulator.new(body).calc_current
    end
  end
end