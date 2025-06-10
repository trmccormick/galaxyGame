class Game
  attr_accessor :elapsed_time, :tasks

  def initialize
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

  private

  # Simulate resource usage, growth, etc., at all settlements
  def process_settlements(time_skipped)
    # Use Settlement::BaseSettlement instead of just Settlement
    Settlement::BaseSettlement.all.each do |settlement|
      settlement.consume_resources(time_skipped)
      puts "#{settlement.name} updated for #{time_skipped} days."
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



