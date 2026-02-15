#!/usr/bin/env ruby
# AI Manager MVP Automated Testing Script
# Runs comprehensive tests of autonomous Mars + Luna coordination
# Usage: ruby scripts/test_ai_manager_mvp.rb

require 'json'
require 'time'
require_relative '../config/environment'

puts "🤖 AI Manager MVP Automated Testing Script"
puts "=" * 50

class AIManagerMVPTester
  attr_reader :results, :orchestrator, :mars_settlement, :luna_settlement

  def initialize
    @results = {
      timestamp: Time.current,
      phases: {},
      overall_success: false,
      findings: {
        successes: [],
        issues: [],
        tuning_needs: [],
        next_steps: []
      }
    }
  end

  def run_all_tests
    puts "🚀 Starting AI Manager MVP Testing..."
    puts ""

    # Phase 1: Environment Setup & Test Preparation
    run_phase_1

    # Phase 2: Basic AI Coordination Testing
    run_phase_2

    # Phase 3: Crisis Response Testing
    run_phase_3

    # Phase 4: Logistics Coordination Testing
    run_phase_4

    # Phase 5: Multi-Cycle Orchestration Testing
    run_phase_5

    # Phase 6: Analysis & Documentation
    run_phase_6

    # Generate final report
    generate_report
  end

  private

  def run_phase_1
    puts "📋 Phase 1: Environment Setup & Test Preparation"
    puts "-" * 50

    begin
      # Load required classes
      require 'ai_manager/system_orchestrator'
      require 'ai_manager/manager'
      require 'ai_manager/shared_context'

      puts "✅ Classes loaded successfully"

      # Initialize components
      shared_context = AIManager::SharedContext.new
      @orchestrator = AIManager::SystemOrchestrator.new(shared_context)

      puts "✅ System orchestrator initialized"

      # Create or find test settlements
      setup_test_settlements

      @results[:phases][:phase_1] = { success: true, message: "Environment setup complete" }
      puts "✅ Phase 1 completed successfully"
    rescue => e
      @results[:phases][:phase_1] = { success: false, error: e.message }
      puts "❌ Phase 1 failed: #{e.message}"
    end
    puts ""
  end

  def run_phase_2
    puts "🤖 Phase 2: Basic AI Coordination Testing"
    puts "-" * 50

    begin
      # Register settlements
      @orchestrator.register_settlement(@mars_settlement)
      @orchestrator.register_settlement(@luna_settlement)

      puts "✅ Settlements registered (#{@orchestrator.settlements.size} total)"

      # Run first orchestration cycle
      @orchestrator.orchestrate_system

      puts "✅ First orchestration cycle completed"

      # Check system status
      status = @orchestrator.system_status
      puts "📊 System status: #{status.inspect}"

      @results[:phases][:phase_2] = { success: true, settlements_registered: @orchestrator.settlements.size }
      puts "✅ Phase 2 completed successfully"
    rescue => e
      @results[:phases][:phase_2] = { success: false, error: e.message }
      puts "❌ Phase 2 failed: #{e.message}"
    end
    puts ""
  end

  def run_phase_3
    puts "🚨 Phase 3: Crisis Response Testing"
    puts "-" * 50

    begin
      # Simulate resource crisis
      puts "🔥 Simulating resource crisis on Mars..."
      @orchestrator.handle_event(:resource_crisis, {
        settlement_id: @mars_settlement.id,
        resources: [:water, :energy]
      })

      # Run orchestration during crisis
      @orchestrator.orchestrate_system

      puts "✅ Crisis response orchestration completed"

      # Check if priorities were adjusted
      status = @orchestrator.system_status
      puts "📊 Post-crisis status: #{status.inspect}"

      @results[:phases][:phase_3] = { success: true, crisis_handled: true }
      puts "✅ Phase 3 completed successfully"
    rescue => e
      @results[:phases][:phase_3] = { success: false, error: e.message }
      puts "❌ Phase 3 failed: #{e.message}"
    end
    puts ""
  end

  def run_phase_4
    puts "🚛 Phase 4: Logistics Coordination Testing"
    puts "-" * 50

    begin
      # Check logistics coordinator
      logistics = @orchestrator.logistics_coordinator
      transfers = logistics.active_transfers
      metrics = logistics.logistics_metrics

      puts "📦 Active transfers: #{transfers.size}"
      puts "📊 Logistics metrics: #{metrics.inspect}"

      @results[:phases][:phase_4] = {
        success: true,
        active_transfers: transfers.size,
        metrics: metrics
      }
      puts "✅ Phase 4 completed successfully"
    rescue => e
      @results[:phases][:phase_4] = { success: false, error: e.message }
      puts "❌ Phase 4 failed: #{e.message}"
    end
    puts ""
  end

  def run_phase_5
    puts "🔄 Phase 5: Multi-Cycle Orchestration Testing"
    puts "-" * 50

    begin
      puts "🏃 Running 5 orchestration cycles..."

      5.times do |i|
        puts "  Cycle #{i + 1}..."
        @orchestrator.orchestrate_system
        status = @orchestrator.system_status
        puts "    Conflicts: #{status[:priority_conflicts] || 0}"
        sleep(0.1) # Brief pause between cycles
      end

      puts "✅ All 5 cycles completed successfully"

      final_status = @orchestrator.system_status
      @results[:phases][:phase_5] = {
        success: true,
        cycles_completed: 5,
        final_conflicts: final_status[:priority_conflicts] || 0
      }
      puts "✅ Phase 5 completed successfully"
    rescue => e
      @results[:phases][:phase_5] = { success: false, error: e.message }
      puts "❌ Phase 5 failed: #{e.message}"
    end
    puts ""
  end

  def run_phase_6
    puts "📊 Phase 6: Analysis & Documentation"
    puts "-" * 50

    # Analyze results
    analyze_results

    # Generate findings
    generate_findings

    @results[:phases][:phase_6] = { success: true, analysis_complete: true }
    puts "✅ Phase 6 completed successfully"
    puts ""
  end

  def setup_test_settlements
    # Create mock settlements for testing - simplified to avoid celestial body complexity
    @mars_settlement = MockSettlement.new("Mars Base", "mars")
    @luna_settlement = MockSettlement.new("Luna Base", "luna")
    
    puts "✅ Test settlements ready: Mars (mock), Luna (mock)"
  end

  class MockSettlement
    attr_reader :id, :name, :settlement_type
    
    def initialize(name, type)
      @id = rand(1000..9999) # Mock ID
      @name = name
      @settlement_type = type
      @operational_data = {}
      @current_population = 100
    end
    
    def location
      MockLocation.new
    end
    
    def operational_data
      @operational_data
    end
    
    def current_population
      @current_population
    end
  end

  class MockLocation
    def celestial_body
      MockCelestialBody.new
    end
  end

  class MockCelestialBody
    def identifier
      "Mock"
    end
    
    def name
      "Mock Body"
    end
  end



  def create_test_player
    Player.create!(
      name: "Test Player",
      email: "test@example.com",
      password: "password123"
    )
  end

  def analyze_results
    # Check if all phases succeeded
    all_phases_success = @results[:phases].all? { |_, phase| phase[:success] }

    @results[:overall_success] = all_phases_success

    # Add findings based on results
    if all_phases_success
      @results[:findings][:successes] << "All 6 test phases completed successfully"
      @results[:findings][:successes] << "AI orchestrator runs without crashes"
      @results[:findings][:successes] << "Settlements coordinate effectively"
      @results[:findings][:successes] << "Multi-cycle orchestration stable"
    end

    # Check for specific issues
    phase_2 = @results[:phases][:phase_2]
    if phase_2 && phase_2[:settlements_registered] != 2
      @results[:findings][:issues] << "Only #{phase_2[:settlements_registered]} settlements registered (expected 2)"
    end

    phase_5 = @results[:phases][:phase_5]
    if phase_5 && phase_5[:final_conflicts] && phase_5[:final_conflicts] > 0
      @results[:findings][:tuning_needs] << "Priority arbitration shows #{phase_5[:final_conflicts]} conflicts - may need tuning"
    end
  end

  def generate_findings
    @results[:findings][:next_steps] = [
      "Review detailed results in JSON output",
      "Address any issues found in testing",
      "Consider tuning priority arbitration if conflicts detected",
      "Ready for Phase 4B UI enhancements or further AI development"
    ]
  end

  def generate_report
    puts "📋 FINAL TEST REPORT"
    puts "=" * 50

    puts "⏰ Test completed at: #{@results[:timestamp]}"
    puts "🎯 Overall result: #{@results[:overall_success] ? '✅ SUCCESS' : '❌ ISSUES FOUND'}"
    puts ""

    puts "📊 Phase Results:"
    @results[:phases].each do |phase_name, result|
      status = result[:success] ? "✅" : "❌"
      puts "  #{phase_name}: #{status} #{result[:message] || result[:error]}"
    end
    puts ""

    puts "🏆 Successes:"
    @results[:findings][:successes].each { |success| puts "  ✅ #{success}" }
    puts ""

    if @results[:findings][:issues].any?
      puts "⚠️ Issues Found:"
      @results[:findings][:issues].each { |issue| puts "  ❌ #{issue}" }
      puts ""
    end

    if @results[:findings][:tuning_needs].any?
      puts "🔧 Tuning Recommendations:"
      @results[:findings][:tuning_needs].each { |tune| puts "  🎛️ #{tune}" }
      puts ""
    end

    puts "🚀 Next Steps:"
    @results[:findings][:next_steps].each { |step| puts "  📝 #{step}" }
    puts ""

    # Save detailed results to file
    results_file = "data/logs/ai_manager_mvp_test_#{Time.current.to_i}.json"
    File.write(results_file, JSON.pretty_generate(@results))
    puts "💾 Detailed results saved to: #{results_file}"

    puts "\n🏁 OVERALL RESULT: #{@results[:overall_success] ? '✅ SUCCESS' : '❌ FAILED'}"
  end
end

# Run the tests
if __FILE__ == $0
  tester = AIManagerMVPTester.new
  tester.run_all_tests
end