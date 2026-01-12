class SatelliteMiningSchedulerJob
  include Sidekiq::Job
  queue_as :scheduling

  def perform
    # Find all operational mining satellites
    mining_satellites = Craft::Satellite::BaseSatellite
      .joins(:base_units)
      .where(deployed: true)
      .where(base_units: { unit_type: ['advanced_computer', 'basic_computer'] })
      .includes(:owner, :base_units, :modules, :rigs)

    Rails.logger.info("SatelliteMiningScheduler: Found #{mining_satellites.count} mining satellites")

    mining_satellites.find_each do |satellite|
      # Check if mining job already queued for this satellite
      next if mining_job_queued?(satellite.id)

      # Queue mining job with satellite-specific options
      MineGccJob.perform_later(
        satellite.id,
        {
          mining_interval: 4.hours,
          max_consecutive_failures: 3,
          owner_id: satellite.owner.id
        }
      )
    end

    # Schedule next scheduler run
    SatelliteMiningSchedulerJob.set(wait: 1.hour).perform_later
  end

  private

  def mining_job_queued?(satellite_id)
    # Check if there's already a pending mining job for this satellite
    # Implementation depends on your job queue system (Sidekiq, etc.)
    false # Simplified - implement based on your queue backend
  end
end