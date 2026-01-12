class Game
  attr_accessor :elapsed_time, :tasks, :game_state

  def initialize(game_state: nil)
    @game_state = game_state
    @elapsed_time = 0.0
    @tasks = []
  end

  # Assigns a new task to the queue
  def assign_task(settlement, description, duration)
    task = {
      settlement: settlement,
      description: description,
      completion_time: @elapsed_time + duration
    }

    @tasks << task
    @tasks.sort_by! { |t| t[:completion_time] }

    puts "Task assigned: #{description} (Completion in #{duration} game-days)"
  end

  # Advances time to the next scheduled event/task
  def advance_time
    return puts "No active tasks." if @tasks.empty?

    next_task = @tasks.shift
    time_to_skip = next_task[:completion_time] - @elapsed_time
    @elapsed_time += time_to_skip

    # Simulate everything in-game for the time skipped
    process_settlements(time_to_skip)
    process_units(time_to_skip)
    process_planets(time_to_skip) # <- NEW: call to TerraSim or similar later

    puts "Time skipped by #{time_to_skip.round(2)} days. Now at day #{@elapsed_time.round(2)}"
    puts "Task completed: #{next_task[:description]} at #{next_task[:settlement].name}"
  end

  # Advance game by a specific number of days
  def advance_by_days(days)
    @elapsed_time += days

    # Update game_state if it exists
    if @game_state
      @game_state.update_time!
    end

    # Simulate everything in-game for the time skipped
    process_settlements(days)
    process_units(days)
    process_planets(days)

    puts "Time advanced by #{days} days. Now at day #{@elapsed_time.round(2)}"
  end

  private

  # Simulate resource usage, growth, etc., at all settlements
  def process_settlements(time_skipped)
    # Use Settlement::BaseSettlement instead of just Settlement
    Settlement::BaseSettlement.all.each do |settlement|
      settlement.base_units.each do |unit|
        unit.consume_resources(time_skipped) if unit.respond_to?(:consume_resources)
      end
      
      # Process active jobs
      process_jobs(settlement, time_skipped)
      
      puts "#{settlement.name} updated for #{time_skipped} days."
    end
  end

  def process_jobs(settlement, time_skipped)
    # Convert days to hours (assuming 24 hours per day)
    time_skipped_hours = time_skipped * 24
    
    # Process shell printing jobs
    ShellPrintingJob.where(settlement: settlement, status: 'in_progress').each do |job|
      job.progress_hours += time_skipped_hours
      job.save!
      
      # Check if job is complete
      if job.progress_hours >= job.production_time_hours
        Manufacturing::ShellPrintingService.new(settlement).complete_job(job)
      end
    end
  end

  # Simulate units doing their operations over time (e.g., mining, travel)
  def process_units(time_skipped)
    # Use Units::BaseUnit instead of just Unit
    Units::BaseUnit.all.each do |unit|
      unit.operate(time_skipped)
    end
  end

  # Simulate planetary systems and spheres
  def process_planets(time_skipped)
    CelestialBodies::CelestialBody.all.each do |planet|
      next unless planet.should_simulate?  # Optional helper if you want to skip dead or inactive planets

      PlanetUpdateService.new(planet, time_skipped).run
    end
  end
end



