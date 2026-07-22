# lib/tasks/luna_operations_simulation.rake
# Standalone daily-tick simulation rake for deployed Luna base operations.
# NOT a modification of luna_mission.rake (integration test harness).
# NOT an extension of venus_mars:pipeline_v2 (different scale/domain).

namespace :luna do
  desc "Simulate Luna base operations for N days (default: 30) -- daily tick loop with inventory tracking and import decisions"
  task :simulate_operations, [:day_count] => :environment do
    day_count = (args[:day_count] || 30).to_i
    raise ArgumentError, "Day count must be positive (got #{day_count})" if day_count <= 0

    # Find a deployed Luna settlement.
    luna_body = CelestialBodies::CelestialBody.find_by(identifier: 'LUNA-01')
    if luna_body.nil?
      puts "\n[ERROR] Celestial body 'LUNA-01' not found in database."
      puts "Run `rake luna_mission:execute` first to deploy a Luna base."
      exit 1
    end

    settlement = Settlement::BaseSettlement.joins(:location)
      .where(location: { celestial_body: luna_body })
      .order(created_at: :desc)
      .first

    if settlement.nil?
      puts "\n[ERROR] No deployed Luna settlement found."
      puts "Run `rake luna_mission:execute` first to deploy a Luna base."
      exit 1
    end

    puts "\n" + "=" * 80
    puts "LUNA BASE OPERATIONS SIMULATION"
    puts "=" * 80
    puts "Settlement: #{settlement.name} (ID: #{settlement.id})"
    puts "Celestial body: #{luna_body.name}"
    puts "Population: #{settlement.current_population}"
    puts "Duration: #{day_count} days"
    puts "=" * 80

    # Run the simulation service.
    service = LunaOperationsSimulationService.new(settlement, day_count: day_count)
    service.run

    # Output the full log.
    puts "\n#{service.to_s}"

    # Summary of import decisions.
    import_decisions = service.decisions.select { |d| d.decision == 'IMPORT' }
    if import_decisions.any?
      puts "\n" + "-" * 80
      puts "IMPORT DECISIONS (#{import_decisions.count} total):"
      puts "-" * 80
      import_decisions.each do |d|
        cost_str = d.cost_per_kg ? " (cost: #{d.cost_per_kg} GCC/kg)" : ""
        puts "  [Day #{d.tick}] #{d.resource.upcase}: #{d.reason}#{cost_str}"
      end
    else
      puts "\nNo import decisions required during simulation window."
    end

    # Final inventory snapshot.
    if settlement.inventory
      puts "\n" + "-" * 80
      puts "FINAL INVENTORY SNAPSHOT:"
      puts "-" * 80
      LunaOperationsSimulationService::TRACKED_RESOURCES.each do |resource|
        amount = settlement.inventory.current_storage_of(resource)
        puts "  #{resource.ljust(12)}: #{amount.round(3)} kg"
      end
    end

    puts "\n" + "=" * 80
    puts "Simulation complete. Tick count persisted to settlement.operational_data."
    puts "=" * 80 + "\n"
  end
end
