class WormholeShiftJob
  include Sidekiq::Job
  queue_as :default

  def perform(wormhole_id)
    wormhole = Wormhole.find_by(id: wormhole_id)

    return unless wormhole&.fluctuating?

    wormhole.shift_location
  rescue StandardError => e
    Rails.logger.error("Failed to shift wormhole #{wormhole_id}: #{e.message}")
    # Optionally, add retry logic or monitoring hooks here
  end
end
  