# lib/tasks/ai_manager_tuning.rake
# Rake tasks for AI Manager decision logic tuning and testing

namespace :ai do
  namespace :manager do
    desc "Tune AI Manager resource acquisition decisions"
    task :tune_resource_acquisition, [:settlement_id, :resource, :quantity, :logic_file] => :environment do |t, args|
      settlement_id = args[:settlement_id]
      resource = args[:resource] || 'ibeam'
      quantity = (args[:quantity] || 1000).to_i
      logic_file = args[:logic_file] || 'resource_acquisition_logic_v1.json'

      # Load decision logic
      logic_path = Rails.root.join('data', 'json-data', 'ai-manager', logic_file)
      unless File.exist?(logic_path)
        puts "❌ Decision logic file not found: #{logic_path}"
        exit 1
      end

      logic = JSON.parse(File.read(logic_path))
      puts "🤖 === AI MANAGER RESOURCE ACQUISITION TUNING ==="
      puts "Testing resource: #{resource} (#{quantity} units)"
      puts "Using logic: #{logic['name']}"
      puts "Settlement: #{settlement_id || 'test settlement'}"
      puts ""

      # Create or find settlement
      settlement = if settlement_id
                     Settlement.find(settlement_id)
                   else
                     create_test_settlement_for_tuning
                   end

      # Take initial snapshot
      initial_stats = capture_settlement_stats(settlement)
      puts "📊 INITIAL SETTLEMENT STATE:"
      puts "  Import ratio: #{initial_stats[:import_ratio].round(3)}"
      puts "  Total materials used: #{initial_stats[:total_materials]}"
      puts "  Materials imported: #{initial_stats[:imported_materials]}"
      puts ""

      # Simulate resource request
      puts "🔧 SIMULATING RESOURCE REQUEST: #{quantity} #{resource}"
      decision_outcomes = simulate_decision_tree(logic['decision_tree']['resource_request'], settlement, resource, quantity)

      # Show decision path
      puts "\n🧠 DECISION PATH TAKEN:"
      decision_outcomes.each do |step|
        status = step[:success] ? "✅" : "❌"
        puts "  #{status} #{step[:step_name]}: #{step[:log_message]}"
      end

      # Final stats
      final_stats = capture_settlement_stats(settlement)
      puts "\n📈 FINAL RESULTS:"
      puts "  Import ratio: #{final_stats[:import_ratio].round(3)} (target: #{logic['tuning_parameters']['import_dependency_threshold']})"
      puts "  Self-sufficiency: #{(1 - final_stats[:import_ratio]).round(3)}"
      puts "  Decision time: #{decision_outcomes.sum { |s| s[:time_ms] }}ms"

      # Performance check
      if final_stats[:import_ratio] > logic['tuning_parameters']['import_dependency_threshold']
        puts "⚠️  WARNING: Import dependency exceeded threshold!"
      else
        puts "✅ Import dependency within acceptable range"
      end

      puts "\n🎯 TUNING COMPLETE"
    end

    desc "Run comprehensive AI Manager tuning suite"
    task :tuning_suite, [:iterations] => :environment do |t, args|
      iterations = (args[:iterations] || 10).to_i

      puts "🧪 === AI MANAGER TUNING SUITE ==="
      puts "Running #{iterations} iterations of resource acquisition scenarios"
      puts ""

      results = []
      test_scenarios = [
        { resource: 'ibeam', quantity: 1000 },
        { resource: 'regolith_panel', quantity: 500 },
        { resource: 'circuit_board', quantity: 200 },
        { resource: 'oxygen', quantity: 1000 },
        { resource: 'water', quantity: 500 }
      ]

      iterations.times do |i|
        puts "Iteration #{i + 1}/#{iterations}:"
        scenario = test_scenarios.sample
        settlement = create_test_settlement_for_tuning

        # Run tuning
        Rake::Task['ai:manager:tune_resource_acquisition'].invoke(settlement.id, scenario[:resource], scenario[:quantity])
        Rake::Task['ai:manager:tune_resource_acquisition'].reenable

        # Capture results
        final_stats = capture_settlement_stats(settlement)
        results << {
          iteration: i + 1,
          resource: scenario[:resource],
          quantity: scenario[:quantity],
          final_import_ratio: final_stats[:import_ratio],
          self_sufficiency: 1 - final_stats[:import_ratio]
        }

        puts ""
      end

      # Summary
      avg_import_ratio = results.sum { |r| r[:final_import_ratio] } / results.size
      avg_self_sufficiency = results.sum { |r| r[:self_sufficiency] } / results.size

      puts "📊 TUNING SUITE SUMMARY:"
      puts "  Average import ratio: #{avg_import_ratio.round(3)}"
      puts "  Average self-sufficiency: #{avg_self_sufficiency.round(3)}"
      puts "  Scenarios tested: #{test_scenarios.size}"
      puts "  Total iterations: #{iterations}"

      if avg_self_sufficiency >= 0.8
        puts "✅ Target self-sufficiency achieved!"
      else
        puts "⚠️  Self-sufficiency below target - consider tuning parameters"
      end
    end

    desc "Benchmark AI Manager decision performance"
    task :benchmark_decisions, [:runs] => :environment do |t, args|
      runs = (args[:runs] || 100).to_i

      puts "⚡ === AI MANAGER DECISION BENCHMARK ==="
      puts "Running #{runs} decision simulations..."
      puts ""

      times = []
      runs.times do
        settlement = create_test_settlement_for_tuning
        start_time = Time.now

        # Simulate a decision
        simulate_decision_tree(
          JSON.parse(File.read(Rails.root.join('data', 'json-data', 'ai-manager', 'resource_acquisition_logic_v1.json')))['decision_tree']['resource_request'],
          settlement,
          'ibeam',
          1000
        )

        times << (Time.now - start_time) * 1000 # ms
      end

      avg_time = times.sum / times.size
      min_time = times.min
      max_time = times.max
      p95_time = times.sort[ (times.size * 0.95).to_i ]

      puts "⏱️  PERFORMANCE RESULTS:"
      puts "  Average decision time: #{avg_time.round(2)}ms"
      puts "  Min time: #{min_time.round(2)}ms"
      puts "  Max time: #{max_time.round(2)}ms"
      puts "  95th percentile: #{p95_time.round(2)}ms"

      if avg_time > 500
        puts "⚠️  WARNING: Average decision time exceeds 500ms target"
      else
        puts "✅ Decision performance within acceptable range"
      end
    end
  end
end

# Helper methods
def create_test_settlement_for_tuning
  settlement = Settlement::BaseSettlement.create!(
    name: "AI Tuning Test Settlement #{Time.now.to_i}",
    settlement_type: "base",
    current_population: 0,
    operational_data: {},
    owner: Player.create!(name: "AI Test Player #{Time.now.to_i}", active_location: "Test"),
    location: Location::CelestialLocation.create!(
      name: "Test Location #{Time.now.to_i}",
      coordinates: "#{rand(0.00..90.00).round(2)}°N #{rand(0.00..180.00).round(2)}°E",
      celestial_body: CelestialBodies::Satellites::LargeMoon.find_or_create_by!(name: "Luna Test") do |moon|
        moon.identifier = "LUNA-TEST"
        moon.size = 0.273
        moon.gravity = 1.62
        moon.density = 3.344
        moon.mass = 7.342e22
        moon.radius = 1.737e6
        moon.orbital_period = 27.322
        moon.albedo = 0.12
        moon.insolation = 1361
        moon.surface_temperature = 250
        moon.known_pressure = 0.0
        moon.properties = {}
      end
    )
  )

  # Add some basic resources
  settlement.inventory.add_item("regolith", 1000)
  settlement.inventory.add_item("oxygen", 100)
  settlement.inventory.add_item("water", 50)
  settlement.save!

  settlement
end

def capture_settlement_stats(settlement)
  total_used = settlement.try(:materials_used_this_month) || 0
  imported = settlement.try(:materials_imported_from_earth_this_month) || 0

  {
    total_materials: total_used,
    imported_materials: imported,
    import_ratio: total_used.zero? ? 0 : imported.to_f / total_used
  }
end

def simulate_decision_tree(decision_tree, settlement, resource, quantity)
  outcomes = []

  decision_tree['steps'].each do |step|
    start_time = Time.now
    success = simulate_step_logic(step, settlement, resource, quantity)
    time_ms = ((Time.now - start_time) * 1000).round(2)

    log_message = success ? step['success_log'] : (step['failure_log'] || "#{step['name']} failed")

    outcomes << {
      step_id: step['step_id'],
      step_name: step['name'],
      success: success,
      log_message: log_message,
      time_ms: time_ms
    }

    break if success # Stop at first successful step
  end

  outcomes
end

def simulate_step_logic(step, settlement, resource, quantity)
  case step['step_id']
  when 'check_local_production'
    # Simulate: can produce if settlement has regolith and printing unit
    (settlement.inventory.try(:items) || []).any? { |i| i['name'] == 'regolith' && i['quantity'] >= quantity * 10 } && rand > 0.3 # 70% success rate
  when 'check_player_market'
    # Simulate: player orders exist
    rand > 0.5 # 50% chance of available orders
  when 'check_npc_supply'
    # Simulate: NPC surplus available
    rand > 0.6 # 40% chance
  when 'check_wormhole_network'
    # Simulate: wormhole-connected surplus
    rand > 0.7 # 30% chance
  when 'earth_import_last_resort'
    # Simulate: can afford import
    (settlement.owner.try(:balance) || 10000) >= 1000 + (quantity * 10) # Assume $10/unit + $1000 fee
  else
    false
  end
end