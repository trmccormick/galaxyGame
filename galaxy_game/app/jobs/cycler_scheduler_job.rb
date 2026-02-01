class CyclerSchedulerJob
  include Sidekiq::Job
  queue_as :logistics

  def perform(origin_identifier, destination_identifier, transfer_data = nil)
    Rails.logger.info("Scheduling cycler from #{origin_identifier} to #{destination_identifier}")

    # Calculate transfer data if not provided
    transfer_data ||= OrbitalMechanics::TransferCalculator.calculate_transfer_time(
      origin_identifier,
      destination_identifier,
      Time.current,
      :nuclear_thermal
    )

    return unless transfer_data

    # Check if we have suitable spacecraft available
    cycler_route = find_suitable_cycler_route(origin_identifier, destination_identifier)
    return unless cycler_route

    # Check launch window
    launch_window = check_launch_window(transfer_data)
    return unless launch_window[:available]

    # Calculate cargo requirements
    cargo_manifest = calculate_cargo_requirements(origin_identifier, destination_identifier)

    # Create cycler transport record
    cycler = CyclerTransport.create!(
      origin_location: find_location(origin_identifier),
      destination_location: find_location(destination_identifier),
      spacecraft_type: cycler_route[:preferred_spacecraft].first,
      launch_date: launch_window[:optimal_date],
      estimated_arrival: launch_window[:optimal_date] + transfer_data[:transfer_time_days].days,
      cargo_manifest: cargo_manifest,
      status: 'scheduled',
      delta_v_required: transfer_data[:delta_v_required],
      transfer_type: transfer_data[:transfer_type]
    )

    Rails.logger.info("Cycler scheduled: #{cycler.id} - #{transfer_data[:transfer_time_days]} day transfer")

    # Schedule the actual launch
    CyclerLaunchJob.perform_at(launch_window[:optimal_date], cycler.id)
  end

  private

  def find_suitable_cycler_route(origin, destination)
    route_key = "#{origin}_#{destination}_cycler".to_sym
    Spacecraft::CapabilityService::CYCLER_TYPES[route_key]
  end

  def check_launch_window(transfer_data)
    launch_date = transfer_data[:launch_date]
    now = Time.current

    # Check if launch window is within reasonable timeframe (not too far in future)
    days_until_launch = (launch_date - now) / 1.day

    if days_until_launch.between?(0, 365) # Within next year
      {
        available: true,
        optimal_date: launch_date,
        days_until_launch: days_until_launch
      }
    else
      # Find next available window
      next_window = find_next_launch_window(transfer_data)
      if next_window && (next_window - now) / 1.day <= 365
        {
          available: true,
          optimal_date: next_window,
          days_until_launch: (next_window - now) / 1.day
        }
      else
        { available: false }
      end
    end
  end

  def find_next_launch_window(transfer_data)
    # Simplified - in reality would calculate next optimal orbital alignment
    synodic_period = transfer_data[:synodic_period_days]
    current_offset = (Time.current - Time.new(2024, 1, 1)) / 1.day

    # Find next optimal alignment
    next_alignment = current_offset + (synodic_period / 2.0) # Half synodic period for opposition
    next_alignment_days = next_alignment - current_offset

    Time.current + next_alignment_days.days
  end

  def calculate_cargo_requirements(origin, destination)
    origin_location = find_location(origin)
    destination_location = find_location(destination)

    return {} unless origin_location && destination_location

    # Get settlements at origin with export-ready cargo
    origin_settlements = Settlement::BaseSettlement.where(location_id: origin_location.id)

    cargo_manifest = {}
    total_cargo_weight = 0
    max_cargo = 50000 # kg for typical cycler

    origin_settlements.each do |settlement|
      # Check for critical shortages at destination that need supplies
      destination_shortages = identify_destination_shortages(destination_location)

      destination_shortages.each do |resource, shortage_amount|
        available = settlement.inventory.current_storage_of(resource)
        needed = [shortage_amount, available, max_cargo - total_cargo_weight].min

        if needed > 0
          cargo_manifest[resource] ||= 0
          cargo_manifest[resource] += needed
          total_cargo_weight += needed

          # Remove from settlement inventory (reserve for cycler)
          settlement.inventory.remove_item(resource, needed)
        end

        break if total_cargo_weight >= max_cargo
      end

      break if total_cargo_weight >= max_cargo
    end

    cargo_manifest
  end

  def identify_destination_shortages(destination_location)
    dest_settlements = Settlement::BaseSettlement.where(location_id: destination_location.id)

    shortages = {}
    critical_resources = ['O2', 'H2O', 'food', 'CNT', 'structural_materials']

    dest_settlements.each do |settlement|
      critical_resources.each do |resource|
        current = settlement.inventory.current_storage_of(resource)
        capacity = settlement.inventory.capacity_of(resource)

        if current < capacity * 0.2 # Less than 20% remaining
          shortage = capacity * 0.5 # Aim to bring to 50% capacity
          shortages[resource] ||= 0
          shortages[resource] += shortage
        end
      end
    end

    shortages
  end

  def find_location(identifier)
    CelestialBodies::CelestialBody.find_by(identifier: identifier.to_s.downcase)
  end
end