class Game
  attr_accessor :elapsed_time, :tasks, :game_state

  def initialize(game_state: nil)
    @game_state = game_state || GameState.first || GameState.create!
    @elapsed_time = @game_state.year * 365 + @game_state.day
    @tasks = []
  end

  # Advances the simulation by a given number of game days
  def advance_by_days(days, update_planets: false)
    return if days <= 0

    # Handle fractional days by converting to integer iterations
    # Process the whole game tick for the entire duration at once
    process_settlements(days)
    process_manufacturing_jobs(days)
    process_free_crafts(days)
    
    @elapsed_time += days
    persist_time!
  end

  # Save the current simulation time to GameState
  def persist_time!
    @game_state.year = (@elapsed_time / 365).to_i
    @game_state.day = @elapsed_time % 365
    @game_state.last_updated_at = Time.current
    @game_state.save!
  end

  private

  # Process all settlements and their contents
  def process_settlements(time_skipped)
    Settlement::BaseSettlement.find_each do |settlement|
      # 1. Process settlement's own units
      settlement.base_units.each do |unit|
        unit.consume_resources(time_skipped) if unit.respond_to?(:consume_resources)
      end

      # 2. Process all structures (with access to settlement shared services)
      settlement.structures.each do |structure|
        structure.process_tick(time_skipped, settlement: settlement)
      end

      # 3. Process all docked crafts (with access to settlement shared services)
      settlement.docked_crafts.each do |craft|
        craft.process_tick(time_skipped, settlement: settlement)
      end

      # 4. Manage shared services (power, data, robots, etc.)
      settlement.manage_shared_services!(time_skipped)
    end
  end

  # Process all crafts that are not docked at a settlement (standalone, e.g. deployed satellites/ships)
  def process_free_crafts(time_skipped)
    Craft::BaseCraft.where(docked_at: nil).find_each do |craft|
      next unless craft.deployed?

      # Power and mining logic should be encapsulated in the craft
      craft.process_tick(time_skipped)
    end
  end

  # Process planets that need frequent updates (not TerraSim, just game-loop relevant)
  def process_planets(time_skipped)
    CelestialBodies::CelestialBody.find_each do |planet|
      next unless planet.should_simulate?

      PlanetUpdateService.new(planet, time_skipped).run
    end
  end

  def process_manufacturing_jobs(time_skipped)
    # Convert days to hours
    hours_elapsed = time_skipped * 24
    
    # Process material processing jobs
    # MaterialProcessingJob.active.each do |job|
    #   job.process_tick(hours_elapsed)
    # end
    
    # Process component production jobs
    ComponentProductionJob.active.each do |job|
      job.process_tick(hours_elapsed)
      
      if job.status == 'completed'
        settlement = job.settlement
        service = Manufacturing::ComponentProductionService.new(settlement)
        service.complete_job(job)
      end
    end
    
    # Process shell printing jobs (NEW!)
    # ShellPrintingJob.active.each do |job|
    #   job.process_tick(hours_elapsed)
      
    #   if job.reload.status == 'completed'
    #     settlement = job.settlement
    #     service = Manufacturing::ShellPrintingService.new(settlement)
    #     service.complete_job(job)
    #   end
    # end
  end
end
