# app/jobs/idle_terrasim_job.rb
class IdleTerraSimJob
  include Sidekiq::Job
  queue_as :low_priority

  def perform
    body = CelestialBodies::CelestialBody.random_body_needing_simulation
    return unless body

    TerraSim::Simulator.new(body).calc_current
    body.last_simulated_at = Time.now
    body.save(validate: false)
  end
end