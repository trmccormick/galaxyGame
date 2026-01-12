module RechargeBehavior
  extend ActiveSupport::Concern

  included do
    # Must define or inherit battery_level, battery_capacity
  end

  def needs_recharge?(threshold = 0.2)
    battery_percentage < (threshold * 100)
  end

  def power_source_location
    # For now, assume it's stored in operational_data or inherited from the deployment context
    operational_data['power_source_location']
  end

  def can_reach_power_source?
    return false unless power_source_location
    # Naive distance check, can expand later
    distance_to(power_source_location) <= max_recharge_distance
  end

  def max_recharge_distance
    # Assume robot can travel 5% battery per 1km, adjust as needed
    (battery_percentage / 5.0).floor
  end

  def distance_to(target_location)
    # Stub: Euclidean or surface path distance depending on your location system
    LocationService.distance(self.current_location, target_location)
  end

  def return_to_recharge
    return unless can_reach_power_source?

    move_to(power_source_location)
    recharge_battery(25) # or begin a recharge sequence
  end
end
