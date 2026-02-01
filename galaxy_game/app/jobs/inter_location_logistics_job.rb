class InterLocationLogisticsJob
  include Sidekiq::Job
  queue_as :logistics

  def perform
    Rails.logger.info("Coordinating inter-location logistics")

    # Check for cycler travel times and schedule deliveries
    process_cycler_schedules

    # Identify resource imbalances between locations
    identify_resource_imbalances

    # Generate logistics contracts for players
    generate_player_contracts

    # Schedule automated NPC logistics operations
    schedule_automated_logistics
  end

  private

  def process_cycler_schedules
    # Calculate realistic transfer times based on orbital mechanics
    # No more fixed travel times - depends on planetary positions and spacecraft capabilities

    active_cyclers = CyclerTransport.where(status: 'in_transit')

    active_cyclers.each do |cycler|
      # Update cycler position and check for arrivals
      update_cycler_progress(cycler)
    end

    # Schedule new cycler departures based on optimal transfer windows
    schedule_new_cycler_departures
  end

  def identify_resource_imbalances
    locations = CelestialBodies::CelestialBody.where(id: Settlement::BaseSettlement.distinct.pluck(:location_id))

    resource_imbalances = {}

    locations.each do |location|
      settlements = Settlement::BaseSettlement.where(location_id: location.id)
      next if settlements.empty?

      # Calculate net production/consumption for key resources
      imbalances = calculate_location_imbalances(settlements)
      resource_imbalances[location.id] = imbalances unless imbalances.empty?
    end

    # Store imbalances for logistics planning
    @resource_imbalances = resource_imbalances
  end

  def calculate_location_imbalances(settlements)
    imbalances = {}

    key_resources = ['CNT', 'O2', 'H2O', 'structural_materials', 'rare_metals']

    key_resources.each do |resource|
      total_production = settlements.sum { |s| s.production_rate(resource) }
      total_consumption = settlements.sum { |s| s.consumption_rate(resource) }

      net_balance = total_production - total_consumption

      if net_balance.abs > 100 # Significant imbalance threshold
        imbalances[resource] = net_balance
      end
    end

    imbalances
  end

  def generate_player_contracts
    return unless @resource_imbalances

    @resource_imbalances.each do |location_id, imbalances|
      imbalances.each do |resource, balance|
        if balance < 0 # Deficit - needs import
          # Create logistics contract for players
          LogisticsContract.create!(
            contract_type: 'resource_import',
            resource: resource,
            quantity: balance.abs,
            origin_location_id: find_surplus_location(resource),
            destination_location_id: location_id,
            reward_credits: calculate_contract_reward(resource, balance.abs),
            expires_at: 30.days.from_now
          )
        end
      end
    end
  end

  def find_surplus_location(resource)
    # Find location with surplus of this resource
    @resource_imbalances.find do |location_id, imbalances|
      imbalances[resource] && imbalances[resource] > 0
    end&.first
  end

  def schedule_automated_logistics
    # Schedule NPC automated transport for critical resources
    critical_transports = LogisticsContract.where(
      contract_type: 'resource_import',
      status: 'open',
      resource: ['O2', 'H2O', 'power_cells']
    )

    critical_transports.each do |contract|
      AutomatedTransportJob.perform_async(contract.id)
    end
  end

  def update_cycler_progress(cycler)
    # Calculate progress based on travel time
    departure_time = cycler.departure_time
    travel_days = cycler.travel_time_days
    elapsed_days = (Time.current - departure_time) / 1.day

    progress = (elapsed_days / travel_days.to_f) * 100

    if progress >= 100
      # Cycler has arrived
      complete_cycler_arrival(cycler)
    else
      cycler.update(progress: progress)
    end
  end

  def schedule_new_cycler_departures
    # Check demand and calculate optimal transfer windows
    routes_to_check = [
      { origin: 'earth', destination: 'venus' },
      { origin: 'earth', destination: 'mars' },
      { origin: 'venus', destination: 'mars' }
    ]

    routes_to_check.each do |route|
      origin_demand = calculate_location_demand(route[:origin])
      dest_demand = calculate_location_demand(route[:destination])

      if origin_demand > 1000 || dest_demand > 1000 # Significant cargo waiting
        # Calculate optimal transfer window using orbital mechanics
        transfer_data = OrbitalMechanics::TransferCalculator.calculate_transfer_time(
          route[:origin],
          route[:destination],
          Time.current,
          :nuclear_thermal # Assume advanced propulsion for cyclers
        )

        if transfer_data && transfer_data[:transfer_time_days] < 400 # Reasonable transfer time
          CyclerSchedulerJob.perform_async(route[:origin], route[:destination], transfer_data)
        end
      end
    end
  end

  def calculate_location_demand(location_identifier)
    location = CelestialBodies::CelestialBody.find_by(identifier: location_identifier)
    return 0 unless location

    settlements = Settlement::BaseSettlement.where(location_id: location.id)
    settlements.sum do |settlement|
      settlement.inventory.export_ready_cargo_volume
    end
  end

  def complete_cycler_arrival(cycler)
    Rails.logger.info("Cycler #{cycler.id} arrived at #{cycler.destination_location.name}")

    # Transfer cargo to destination settlement
    destination_settlement = Settlement::BaseSettlement.where(location_id: cycler.destination_location_id).first

    if destination_settlement
      cycler.cargo_manifest.each do |item, quantity|
        destination_settlement.inventory.add_item(item, quantity)
      end
    end

    cycler.update(status: 'arrived')
  end

  def calculate_contract_reward(resource, quantity)
    # Base reward calculation - could be more sophisticated
    base_rates = {
      'O2' => 10,
      'H2O' => 15,
      'CNT' => 1000,
      'structural_materials' => 50
    }

    (base_rates[resource] || 1) * quantity * 1.5 # 50% profit margin
  end
end