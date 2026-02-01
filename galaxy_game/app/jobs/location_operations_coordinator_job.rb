class LocationOperationsCoordinatorJob
  include Sidekiq::Job
  queue_as :coordination

  def perform
    # Coordinate concurrent operations across all active locations
    active_locations = Settlement::BaseSettlement.distinct.pluck(:location_id).compact

    active_locations.each do |location_id|
      # Queue location-specific operations
      LocationOperationsJob.perform_async(location_id)
    end

    # Queue inter-location logistics coordination
    InterLocationLogisticsJob.perform_async

    # Queue global resource market updates
    GlobalResourceMarketJob.perform_async

    # Schedule next coordination cycle
    self.class.perform_in(1.hour)
  end
end