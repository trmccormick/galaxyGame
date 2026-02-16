# app/services/ai_manager/testing/bootstrap_controller.rb
module AIManager
  module Testing
    class BootstrapController
      attr_reader :test_scenario, :settlement, :system_data, :resources, :missions

      def initialize(scenario_name = nil)
        @test_scenario = scenario_name || :default
        @settlement = nil
        @system_data = {}
        @resources = {}
        @missions = []
        @initialized = false
      end

      # Main bootstrap method - sets up complete test environment
      def bootstrap_test_environment(scenario_config = {})
        Rails.logger.info "[BootstrapController] Starting test environment bootstrap for scenario: #{@test_scenario}"

        # Load scenario configuration
        config = load_scenario_config(scenario_config)

        # Create isolated settlement
        @settlement = create_isolated_settlement(config[:settlement])

        # Initialize system data
        @system_data = generate_system_data(config[:system])

        # Set up initial resources
        @resources = initialize_resources(config[:resources])

        # Queue test missions
        @missions = queue_test_missions(config[:missions])

        # Configure AI services for testing
        configure_ai_services_for_testing

        @initialized = true
        Rails.logger.info "[BootstrapController] Test environment bootstrap completed"

        {
          settlement: @settlement,
          system_data: @system_data,
          resources: @resources,
          missions: @missions,
          scenario: @test_scenario
        }
      end

      # Reset test environment to clean state
      def reset_environment
        Rails.logger.info "[BootstrapController] Resetting test environment"

        # Clean up settlement if it exists
        if @settlement
          cleanup_settlement(@settlement)
          @settlement = nil
        end

        # Reset all state
        @system_data = {}
        @resources = {}
        @missions = []
        @initialized = false

        Rails.logger.info "[BootstrapController] Test environment reset completed"
      end

      # Check if environment is properly initialized
      def initialized?
        @initialized
      end

      # Get current test environment status
      def environment_status
        {
          initialized: @initialized,
          scenario: @test_scenario,
          settlement_id: @settlement&.id,
          system_bodies_count: @system_data[:celestial_bodies]&.size || 0,
          resource_types_count: @resources.size,
          queued_missions_count: @missions.size
        }
      end

      private

      # Load scenario configuration
      def load_scenario_config(overrides = {})
        default_config = {
          settlement: {
            name: "AI Test Settlement",
            type: "Outpost",
            population: 100,
            power_output: 500,
            resource_storage: 10000
          },
          system: {
            name: "Test System",
            star_type: "G-type",
            planet_count: 3,
            moon_count: 2,
            resource_rich_bodies: 1
          },
          resources: {
            'Iron' => 1000,
            'Water' => 500,
            'Oxygen' => 200,
            'Energy' => 1000
          },
          missions: [
            { type: 'resource_extraction', priority: 'high' },
            { type: 'infrastructure_building', priority: 'medium' }
          ]
        }

        # Apply scenario-specific overrides
        case @test_scenario
        when :resource_crisis
          default_config[:resources] = { 'Iron' => 10, 'Energy' => 50 } # Critical shortages
          default_config[:missions] = [{ type: 'emergency_resource_acquisition', priority: 'critical' }]
        when :expansion_ready
          default_config[:settlement][:population] = 500
          default_config[:settlement][:power_output] = 2000
          default_config[:missions] = [{ type: 'settlement_expansion', priority: 'high' }]
        when :scouting_priority
          default_config[:system][:planet_count] = 5
          default_config[:missions] = [{ type: 'system_scouting', priority: 'high' }]
        end

        # Apply user overrides
        deep_merge(default_config, overrides)
      end

      # Create isolated settlement for testing
      def create_isolated_settlement(config)
        # Create a test settlement that won't affect live game
        settlement = Settlement::BaseSettlement.new(
          name: "#{config[:name]} [TEST]",
          settlement_type: :outpost,
          location: generate_test_location,
          description: "Isolated test settlement for AI Manager testing",
          current_population: config[:population],
          power_output_mw: config[:power_output],
          resource_storage_cubic_meters: config[:resource_storage]
        )

        # Mock the save to avoid database writes in tests
        allow(settlement).to receive(:save).and_return(true)
        allow(settlement).to receive(:persisted?).and_return(true)
        allow(settlement).to receive(:id).and_return(rand(10000..99999))

        # Initialize mock inventory
        allow(settlement).to receive(:inventory).and_return(double('inventory'))

        settlement
      end

      # Generate test location coordinates
      def generate_test_location
        # Use coordinates far from live game areas
        { x: rand(10000..20000), y: rand(10000..20000), z: rand(10000..20000) }
      end

      # Generate system data for testing
      def generate_system_data(config)
        bodies = []

        # Add star
        bodies << {
          id: 'test_star',
          type: 'star',
          name: "#{config[:name]} Star",
          star_type: config[:star_type]
        }

        # Add planets
        config[:planet_count].times do |i|
          bodies << {
            id: "test_planet_#{i}",
            type: 'planet',
            name: "Test Planet #{i+1}",
            terraformable: i == 0, # First planet is terraformable
            resource_rich: i == 1  # Second planet is resource-rich
          }
        end

        # Add moons
        config[:moon_count].times do |i|
          bodies << {
            id: "test_moon_#{i}",
            type: 'moon',
            name: "Test Moon #{i+1}",
            terraformable: true,
            resource_rich: false
          }
        end

        {
          id: 'test_system',
          name: config[:name],
          celestial_bodies: bodies,
          wormhole_connections: [],
          em_signatures: []
        }
      end

      # Initialize test resources
      def initialize_resources(config)
        resources = {}
        config.each do |material, quantity|
          resources[material] = {
            available: quantity,
            reserved: 0,
            in_transit: 0
          }
        end
        resources
      end

      # Queue test missions
      def queue_test_missions(config)
        missions = []
        config.each do |mission_config|
          mission = {
            id: "test_mission_#{rand(1000..9999)}",
            type: mission_config[:type],
            priority: mission_config[:priority],
            status: :queued,
            created_at: Time.current
          }
          missions << mission
        end
        missions
      end

      # Configure AI services for testing mode
      def configure_ai_services_for_testing
        # Set services to test mode to prevent live game impact
        Rails.logger.info "[BootstrapController] Configuring AI services for testing mode"

        # This would configure services to use test data and avoid live operations
        # Implementation depends on how services handle test mode
      end

      # Clean up test settlement
      def cleanup_settlement(settlement)
        # In a real implementation, this would remove test data
        # For now, just log the cleanup
        Rails.logger.info "[BootstrapController] Cleaning up test settlement: #{settlement.name}"
      end

      # Deep merge for configuration overrides
      def deep_merge(hash1, hash2)
        hash1.merge(hash2) do |key, old_val, new_val|
          if old_val.is_a?(Hash) && new_val.is_a?(Hash)
            deep_merge(old_val, new_val)
          else
            new_val
          end
        end
      end
    end
  end
end