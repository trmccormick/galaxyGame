class LocationOperationsJob
  include Sidekiq::Job
  queue_as :operations

  def perform(location_id)
    location = CelestialBodies::CelestialBody.find(location_id)
    settlements = Settlement::BaseSettlement.where(location_id: location_id)

    Rails.logger.info("Processing concurrent operations for #{location.name}")

    # Process all settlements at this location concurrently
    settlement_operations = settlements.map do |settlement|
      Thread.new do
        process_settlement_operations(settlement)
      end
    end

    # Wait for all settlement operations to complete
    settlement_operations.each(&:join)

    # Process location-wide operations (orbital construction, atmospheric processing, etc.)
    process_location_wide_operations(location)

    # Check for resource shortages and trigger logistics contracts
    check_resource_shortages(location, settlements)

    # Update location-specific market conditions
    update_local_market(location)
  end

  private

  def process_settlement_operations(settlement)
    # Manufacturing operations
    process_manufacturing(settlement)

    # Construction projects
    process_construction(settlement)

    # Resource extraction
    process_extraction(settlement)

    # Mission task execution
    process_mission_tasks(settlement)

    # NPC automation responses
    process_automated_responses(settlement)
  end

  def process_manufacturing(settlement)
    settlement.structures.where(structure_type: 'manufacturing').each do |structure|
      ManufacturingJob.perform_async(settlement.id, structure.id)
    end
  end

  def process_construction(settlement)
    active_projects = settlement.orbital_construction_projects.where(status: ['in_progress', 'materials_pending'])
    active_projects.each do |project|
      ConstructionJob.perform_async(project.id)
    end
  end

  def process_extraction(settlement)
    settlement.structures.where(structure_type: 'extraction').each do |structure|
      ExtractionJob.perform_async(settlement.id, structure.id)
    end
  end

  def process_mission_tasks(settlement)
    active_missions = settlement.missions.where(status: 'active')
    active_missions.each do |mission|
      MissionTaskExecutionJob.perform_async(mission.id)
    end
  end

  def process_automated_responses(settlement)
    # Check for critical resource shortages
    critical_resources = ['O2', 'H2O', 'power', 'CNT']
    shortages = critical_resources.select do |resource|
      settlement.inventory.current_storage_of(resource) < settlement.inventory.capacity_of(resource) * 0.1
    end

    if shortages.any?
      AutomatedResponseJob.perform_async(settlement.id, shortages)
    end
  end

  def process_location_wide_operations(location)
    case location.identifier
    when 'venus'
      # Venus-specific operations: atmospheric processing, orbital foundry
      VenusOperationsJob.perform_async(location.id)
    when 'mars'
      # Mars-specific operations: terraforming, elevator construction
      MarsOperationsJob.perform_async(location.id)
    when 'earth_l1'
      # L1-specific operations: construction yard, logistics hub
      L1OperationsJob.perform_async(location.id)
    when 'luna'
      # Lunar operations: mining, helium-3 extraction
      LunarOperationsJob.perform_async(location.id)
    end
  end

  def check_resource_shortages(location, settlements)
    # Aggregate resource demands across all settlements at location
    total_demand = settlements.sum do |settlement|
      settlement.inventory.resource_demands
    end

    # Check for systemic shortages that could create logistics opportunities
    systemic_shortages = total_demand.select do |resource, demand|
      available = settlements.sum { |s| s.inventory.current_storage_of(resource) }
      available < demand * 1.5 # 50% buffer
    end

    if systemic_shortages.any?
      LogisticsContractGenerationJob.perform_async(location.id, systemic_shortages.keys)
    end
  end

  def update_local_market(location)
    # Update location-specific market conditions based on local production/consumption
    MarketUpdateJob.perform_async(location.id)
  end
end