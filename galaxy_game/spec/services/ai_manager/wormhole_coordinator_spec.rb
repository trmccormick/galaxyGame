# spec/services/ai_manager/wormhole_coordinator_spec.rb
require 'rails_helper'
require './app/services/ai_manager/wormhole_coordinator'

RSpec.describe AIManager::WormholeCoordinator do
  let(:shared_context) { double('SharedContext') }
  let(:coordinator) { described_class.new(shared_context) }

  let(:current_system) do
    {
      id: 1,
      identifier: 'SOL',
      wormhole_capacity: 1000000
    }
  end

  let(:expansion_targets) do
    [
      {
        id: 2,
        identifier: 'ALPHA_CENTAURI',
        economic_value: 200000,
        strategic_value: 1.5
      },
      {
        id: 3,
        identifier: 'PROXIMA_B',
        economic_value: 150000,
        strategic_value: 1.2
      }
    ]
  end

  let(:available_resources) do
    {
      mass_requirements: 50000,
      available_budget: 100000000
    }
  end

  describe '#calculate_optimal_routes' do
    let(:mock_wormhole) do
      double('Wormhole',
        id: 1,
        solar_system_a: double(identifier: 'SOL', wormhole_capacity: 1000000),
        solar_system_b: double(identifier: 'ALPHA_CENTAURI', wormhole_capacity: 500000),
        wormhole_type: 'traversable',
        stability: 'stable',
        mass_limit: 100000,
        safe_for_travel?: true
      )
    end

    before do
      mock_relation = double('ActiveRecordRelation')
      allow(mock_relation).to receive(:or).and_return([mock_wormhole])
      allow(Wormhole).to receive(:where).and_return(mock_relation)
    end

    it 'calculates optimal routes for multiple targets' do
      result = coordinator.calculate_optimal_routes(current_system, expansion_targets, available_resources)

      expect(result).to have_key(:route_options)
      expect(result).to have_key(:optimized_routes)
      expect(result).to have_key(:economic_analysis)
      expect(result).to have_key(:network_utilization)
      expect(result).to have_key(:coordination_plan)
    end

    it 'includes route options for each target' do
      result = coordinator.calculate_optimal_routes(current_system, expansion_targets, available_resources)

      expect(result[:route_options].length).to eq(2)
      result[:route_options].each do |option|
        expect(option).to have_key(:target_system)
        expect(option).to have_key(:direct_connection)
        expect(option).to have_key(:route_count)
        expect(option).to have_key(:best_route)
      end
    end

    it 'provides economic analysis of routes' do
      result = coordinator.calculate_optimal_routes(current_system, expansion_targets, available_resources)

      economic = result[:economic_analysis]
      expect(economic).to have_key(:total_transport_cost)
      expect(economic).to have_key(:total_time_cost)
      expect(economic).to have_key(:total_cost)
      expect(economic).to have_key(:economic_benefits)
      expect(economic).to have_key(:net_present_value)
      expect(economic).to have_key(:benefit_cost_ratio)
    end

    it 'calculates network utilization metrics' do
      result = coordinator.calculate_optimal_routes(current_system, expansion_targets, available_resources)

      utilization = result[:network_utilization]
      expect(utilization).to have_key(:wormhole_usage)
      expect(utilization).to have_key(:utilization_stats)
      expect(utilization).to have_key(:bottleneck_wormholes)
      expect(utilization).to have_key(:average_utilization)
    end

    it 'generates coordination plan with phases' do
      result = coordinator.calculate_optimal_routes(current_system, expansion_targets, available_resources)

      plan = result[:coordination_plan]
      expect(plan).to have_key(:phases)
      expect(plan).to have_key(:coordination_requirements)
      expect(plan).to have_key(:critical_path)
      expect(plan).to have_key(:resource_dependencies)
    end
  end

  describe '#coordinate_parallel_development' do
    let(:settlement_plans) do
      [
        {
          settlement_id: 'sol_base',
          target_system: current_system,
          economic_value: 100000,
          estimated_completion_days: 300
        },
        {
          settlement_id: 'alpha_base',
          target_system: expansion_targets.first,
          economic_value: 200000,
          estimated_completion_days: 400
        }
      ]
    end

    let(:wormhole_network) do
      {
        nodes: {
          'SOL' => { connected_systems: ['ALPHA_CENTAURI'] },
          'ALPHA_CENTAURI' => { connected_systems: ['SOL'] }
        },
        edges: [
          {
            from: 'SOL',
            to: 'ALPHA_CENTAURI',
            traversable: true,
            cost: 15000
          }
        ]
      }
    end

    it 'analyzes settlement interdependencies' do
      result = coordinator.coordinate_parallel_development(settlement_plans, wormhole_network)

      expect(result).to have_key(:interdependencies)
      expect(result).to have_key(:development_sequence)
      expect(result).to have_key(:resource_sharing)
      expect(result).to have_key(:coordination_timeline)
      expect(result).to have_key(:parallel_efficiency)
    end

    it 'optimizes development sequencing' do
      result = coordinator.coordinate_parallel_development(settlement_plans, wormhole_network)

      sequence = result[:development_sequence]
      expect(sequence.length).to eq(2)
      expect(sequence.first).to have_key(:settlement)
      expect(sequence.first).to have_key(:sequence_position)
      expect(sequence.first).to have_key(:dependencies_satisfied)
    end

    it 'calculates parallel efficiency metrics' do
      result = coordinator.coordinate_parallel_development(settlement_plans, wormhole_network)

      efficiency = result[:parallel_efficiency]
      expect(efficiency).to have_key(:total_duration)
      expect(efficiency).to have_key(:sequential_duration)
      expect(efficiency).to have_key(:efficiency_ratio)
      expect(efficiency).to have_key(:time_saved_percentage)
    end

    it 'generates coordination timeline' do
      result = coordinator.coordinate_parallel_development(settlement_plans, wormhole_network)

      timeline = result[:coordination_timeline]
      expect(timeline).to be_an(Array)
      expect(timeline.first).to have_key(:settlement)
      expect(timeline.first).to have_key(:start_time)
      expect(timeline.first).to have_key(:end_time)
    end
  end

  describe 'private methods' do
    describe '#build_wormhole_network_graph' do
      let(:mock_wormhole) do
        double('Wormhole',
          solar_system_a: double(identifier: 'SOL', wormhole_capacity: 1000000),
          solar_system_b: double(identifier: 'ALPHA_CENTAURI', wormhole_capacity: 500000),
          wormhole_type: 'traversable',
          stability: 'stable',
          mass_limit: 100000,
          safe_for_travel?: true
        )
      end

      before do
        mock_relation = double('ActiveRecordRelation')
        allow(mock_relation).to receive(:or).and_return([mock_wormhole])
        allow(Wormhole).to receive(:where).and_return(mock_relation)
      end

      it 'builds network graph with nodes and edges' do
        graph = coordinator.send(:build_wormhole_network_graph, current_system)

        expect(graph).to have_key(:nodes)
        expect(graph).to have_key(:edges)
        expect(graph[:nodes]).to have_key('SOL')
        expect(graph[:nodes]).to have_key('ALPHA_CENTAURI')
        expect(graph[:edges].length).to eq(1)
      end

      it 'includes wormhole properties in edges' do
        graph = coordinator.send(:build_wormhole_network_graph, current_system)

        edge = graph[:edges].first
        expect(edge).to have_key(:from)
        expect(edge).to have_key(:to)
        expect(edge).to have_key(:wormhole)
        expect(edge).to have_key(:capacity)
        expect(edge).to have_key(:stability)
        expect(edge).to have_key(:traversable)
      end
    end

    describe '#calculate_route_options' do
      let(:network_graph) do
        {
          nodes: {
            'SOL' => { connected_systems: ['ALPHA_CENTAURI'] },
            'ALPHA_CENTAURI' => { connected_systems: ['SOL'] }
          },
          edges: [{
            from: 'SOL',
            to: 'ALPHA_CENTAURI',
            wormhole: double('Wormhole', id: 1),
            distance: 1,
            capacity: 100000,
            stability: 'stable',
            traversable: true,
            cost: 15000
          }]
        }
      end

      it 'finds direct routes when available' do
        allow(coordinator).to receive(:find_all_routes).and_return([['SOL', 'ALPHA_CENTAURI']])

        result = coordinator.send(:calculate_route_options, current_system, expansion_targets.first, network_graph, available_resources)

        expect(result[:direct_connection]).to be true
        expect(result[:route_count]).to eq(1)
      end

      it 'evaluates route feasibility' do
        allow(coordinator).to receive(:find_all_routes).and_return([['SOL', 'ALPHA_CENTAURI']])

        result = coordinator.send(:calculate_route_options, current_system, expansion_targets.first, network_graph, available_resources)

        best_route = result[:best_route]
        expect(best_route).to have_key(:route)
        expect(best_route).to have_key(:total_distance)
        expect(best_route).to have_key(:total_cost)
        expect(best_route).to have_key(:feasible)
      end
    end

    describe '#evaluate_route' do
      let(:route) { ['SOL', 'ALPHA_CENTAURI'] }
      let(:graph) do
        {
          edges: [{
            from: 'SOL',
            to: 'ALPHA_CENTAURI',
            wormhole: double('Wormhole', id: 1),
            distance: 1,
            capacity: 100000,
            stability: 'stable',
            traversable: true,
            cost: 15000
          }]
        }
      end

      it 'calculates route metrics' do
        result = coordinator.send(:evaluate_route, route, graph, available_resources)

        expect(result).to have_key(:route)
        expect(result).to have_key(:total_distance)
        expect(result).to have_key(:total_cost)
        expect(result).to have_key(:total_time)
        expect(result).to have_key(:reliability_score)
        expect(result).to have_key(:preference_score)
        expect(result).to have_key(:feasible)
      end

      it 'identifies bottlenecks' do
        high_mass_requirements = { mass_requirements: 200000 } # Exceeds capacity

        result = coordinator.send(:evaluate_route, route, graph, high_mass_requirements)

        expect(result[:bottlenecks]).to be_an(Array)
        expect(result[:bottlenecks].length).to eq(1)
      end
    end

    describe '#optimize_multi_system_routes' do
      let(:route_options) do
        [
          {
            target_system: expansion_targets.first,
            best_route: {
              route: ['SOL', 'ALPHA_CENTAURI'],
              total_cost: 15000,
              total_time: 24,
              reliability_score: 0.95,
              feasible: true
            }
          }
        ]
      end

      it 'selects optimal routes without conflicts' do
        result = coordinator.send(:optimize_multi_system_routes, route_options, available_resources)

        expect(result).to be_an(Array)
        expect(result.length).to eq(1)
        expect(result.first).to have_key(:target)
        expect(result.first).to have_key(:route)
        expect(result.first).to have_key(:scheduled_time)
      end

      it 'schedules routes to avoid conflicts' do
        allow(coordinator).to receive(:can_schedule_concurrently).and_return(false)

        result = coordinator.send(:optimize_multi_system_routes, route_options, available_resources)

        expect(result.first[:scheduled_time]).to be >= 0
      end
    end

    describe '#calculate_route_economics' do
      let(:routes) do
        [
          {
            route: {
              total_cost: 15000,
              total_time: 24
            },
            target: { economic_value: 200000 }
          }
        ]
      end

      it 'calculates comprehensive economic metrics' do
        result = coordinator.send(:calculate_route_economics, routes, available_resources)

        expect(result).to have_key(:total_transport_cost)
        expect(result).to have_key(:total_time_cost)
        expect(result).to have_key(:total_cost)
        expect(result).to have_key(:economic_benefits)
        expect(result).to have_key(:net_present_value)
        expect(result).to have_key(:benefit_cost_ratio)
      end

      it 'calculates positive NPV for profitable routes' do
        result = coordinator.send(:calculate_route_economics, routes, available_resources)

        expect(result[:net_present_value]).to be > 0
        expect(result[:benefit_cost_ratio]).to be > 1
      end
    end
  end
end